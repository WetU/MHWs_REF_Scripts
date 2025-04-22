local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local pairs = Constants.pairs;
local ipairs = Constants.ipairs;
local tostring = Constants.tostring;
local table = Constants.table;

local get_Fps_method = sdk.find_type_definition("via.dynamics.System"):get_method("get_Fps"); -- static

local PorterUtil_type_def = sdk.find_type_definition("app.PorterUtil");
local getCurrentEnvType_method = PorterUtil_type_def:get_method("getCurrentEnvType"); -- static
local getCurrentStageMasterPlayer_method = PorterUtil_type_def:get_method("getCurrentStageMasterPlayer"); -- static

local get_Option_method = Constants.GUIManager_type_def:get_method("get_Option");

local Option_type_def = get_Option_method:get_return_type();
local getValue_method = Option_type_def:get_method("getValue(app.Option.ID)");
local getResolutions_method = Option_type_def:get_method("getResolutions");
local setResolution_method = Option_type_def:get_method("setResolution(via.render.WindowMode, via.Size)");

local get_UpscaleSetting_method = Constants.GraphicsManager_type_def:get_method("get_UpscaleSetting");
local getResolution_method = Constants.GraphicsManager_type_def:get_method("getResolution");

local UpscaleSetting_type_def = get_UpscaleSetting_method:get_return_type();
local get_IsEnableUpscaling_method = UpscaleSetting_type_def:get_method("get_IsEnableUpscaling");
local get_Quality_method = UpscaleSetting_type_def:get_method("get_Quality");
local set_Quality_method = UpscaleSetting_type_def:get_method("set_Quality(ace.cUpscaleSetting.QUALITY)");
local updateRequest_method = UpscaleSetting_type_def:get_method("updateRequest");

local Size_type_def = getResolution_method:get_return_type();
local w_field = Size_type_def:get_field("w");
local h_field = Size_type_def:get_field("h");

local WindowMode_type_def = sdk.find_type_definition("via.render.WindowMode");
local WindowModeOption = {
    [0] = WindowMode_type_def:get_field("Borderless"):get_data(nil),
    [1] = WindowMode_type_def:get_field("Normal"):get_data(nil)
};

local OptionID_type_def = sdk.find_type_definition("app.Option.ID");
local Options = {
    SCREEN_MODE = OptionID_type_def:get_field("SCREEN_MODE"):get_data(nil),
    RESOLUTION_SETTING = OptionID_type_def:get_field("RESOLUTION_SETTING"):get_data(nil),
    FRAME_GENERATION = OptionID_type_def:get_field("FRAME_GENERATION"):get_data(nil),
    UPSCALE_MODE = OptionID_type_def:get_field("UPSCALE_MODE"):get_data(nil)
};

local STAGE_type_def = getCurrentStageMasterPlayer_method:get_return_type();
local stages = {
    STAGE_type_def:get_field("ST101"):get_data(nil),
    STAGE_type_def:get_field("ST102"):get_data(nil),
    STAGE_type_def:get_field("ST103"):get_data(nil),
    STAGE_type_def:get_field("ST104"):get_data(nil),
    STAGE_type_def:get_field("ST105"):get_data(nil),
    STAGE_type_def:get_field("ST401"):get_data(nil),
    STAGE_type_def:get_field("ST403"):get_data(nil),
    STAGE_type_def:get_field("ST503"):get_data(nil),
    INVALID = STAGE_type_def:get_field("INVALID"):get_data(nil)
};
local stageNames = {
    "경계의 모래 평원",
    "주홍빛 숲",
    "기름 솟는 계곡",
    "빙무의 절벽",
    "용도의 폐허",
    "용곡의 터",
    "용등의 사원",
    "수련장"
};

local ENVIRONMENT_type_def = getCurrentEnvType_method:get_return_type();
local environments = {
    ENVIRONMENT_type_def:get_field("RUIN"):get_data(nil),
    ENVIRONMENT_type_def:get_field("ABNORMAL"):get_data(nil),
    ENVIRONMENT_type_def:get_field("FERTILITY"):get_data(nil),
    INVALID = ENVIRONMENT_type_def:get_field("INVALID"):get_data(nil)
};
local environmentNames = {
    "황폐기",
    "이상 기변",
    "풍요기"
};

local QUALITY_type_def = get_Quality_method:get_return_type();
local UpscaleQuality = {
    QUALITY_type_def:get_field("Quality"):get_data(nil),
    QUALITY_type_def:get_field("Balanced"):get_data(nil),
    QUALITY_type_def:get_field("Performance"):get_data(nil),
    QUALITY_type_def:get_field("UltraPerformance"):get_data(nil)
};
local UpscaleNames = {
    "품질 우선",
    "균형",
    "성능 우선",
    "성능 최우선"
};

local settings = {
    enabled = true,
    max_resolution = nil,
    min_resolution = 0,
    max_upscale_mode = UpscaleQuality[1],
    min_upscale_mode = UpscaleQuality[4],
    up_level_prefered_option = 1,
    down_level_prefered_option = 1,
    auto_adjust = true,
    auto_adjust_fps_target = 30,
    auto_adjust_fps_reduce_threshold = 3,
    auto_adjust_fps_increase_threshold = 6,
    auto_adjust_max_level = 3,
    auto_adjust_reduce_duration = 5,
    auto_adjust_increase_duration = 10,
    auto_adjust_recover_interval = 100
};

local function saveConfig() 
    json.dump_file("dynamic_resolution.json", settings);
end

local loaded = json.load_file("dynamic_resolution.json");
if loaded ~= nil then
    for k, v in pairs(loaded) do
        settings[k] = v;
    end
end
local fpsLowTrigger = settings.auto_adjust_fps_target - settings.auto_adjust_fps_reduce_threshold;
local fpsHighTrigger = settings.auto_adjust_fps_target + settings.auto_adjust_fps_increase_threshold;

local max_upscale_mode = UpscaleQuality[1];
local stage = nil;
local env = nil;
local graphicLevel = 0;

local autoAdjustDurationBegin = 0;
local autoAdjustLastReduceTime = nil;
local autoAdjustFpsTable = {};

local GraphicOptions = {
    "업스케일",
    "해상도"
};

local function getStageName(stageNo)
    local name = nil;
    for i, v in ipairs(stages) do
        if v == stageNo then
            name = stageNames[i];
            break;
        end
    end
    if name == nil then
        name = tostring(stageNo);
        if stageNo ~= stages.INVALID then
            Constants.addSystemLog("알 수 없는 지역: " .. name);
        end
    end
    return name;
end

local function getEnvName(envNo)
    for i, v in ipairs(environments) do
        if envNo == v then
            return environmentNames[i];
        end
    end
    return nil;
end

local function getUpscaleName(mode)
    for i, v in ipairs(UpscaleQuality) do
        if mode == v then
            return UpscaleNames[i];
        end
    end
    return nil;
end

local function resolutionEqual(a, b)
    return a ~= nil and b ~= nil and (a == b or (w_field:get_data(a) == w_field:get_data(b) and h_field:get_data(a) == h_field:get_data(b)));
end

local function resolutionIndexOf(rs, r)
    if rs ~= nil and r ~= nil then
        for k, v in pairs(rs) do
            if resolutionEqual(v, r) == true then
                return k;
            end
        end
    end
    return nil;
end

local function indexOf(t, a)
    for i, v in ipairs(t) do
        if v == a then
            return i;
        end
    end
    return nil;
end

local function resolutionString(r)
    return Constants.string.format("%dx%d", w_field:get_data(r), h_field:get_data(r));
end

local function calculateGraphicLevel(stageNo, envNo)
    if settings.items ~= nil then
        for _, item in pairs(settings.items) do
            if item.matcher ~= nil and item.matcher.stage == stageNo and item.matcher.env == envNo then
                return item.level;
            end
        end
    end
    return 0;
end

local function caculateGraphicOptions(firstOri, secondOri, firstMin, firstMax, secondMin, secondMax, firstIncreaseStep, secondIncreaseStep)
    local first = firstOri;
    local second = secondOri;
    if graphicLevel < 0 then
        for i = -1, graphicLevel, -1 do
            if (firstIncreaseStep > 0 and first > firstMin) or (firstIncreaseStep < 0 and first < firstMax) then
                first = first - firstIncreaseStep;
            else
                if (secondIncreaseStep > 0 and second > secondMin) or (secondIncreaseStep < 0 and second < secondMax) then
                    second = second - secondIncreaseStep;
                else
                    break;
                end
            end
        end
    elseif graphicLevel > 0 then
        for i = 1, graphicLevel, 1 do
            if (firstIncreaseStep > 0 and first < firstMax) or (firstIncreaseStep < 0 and first > firstMin) then
                first = first + firstIncreaseStep;
            else
                if (secondIncreaseStep > 0 and second < secondMax) or (secondIncreaseStep < 0 and second > secondMin) then
                    second = second + secondIncreaseStep;
                else
                    break;
                end
            end
        end
    end
    return first, second;
end

local function autoAdjustReset()
    autoAdjustDurationBegin = 0;
    autoAdjustFpsTable = {};
    autoAdjustLastReduceTime = nil;
end

local function applyGraphicLevel()
    if Constants.GraphicsManager == nil then
        Constants.GraphicsManager = sdk.get_managed_singleton("app.GraphicsManager");
    end
    if Constants.GUIManager == nil then
        Constants.GUIManager = sdk.get_managed_singleton("app.GUIManager");
    end
    local UpscaleSetting = get_UpscaleSetting_method:call(Constants.GraphicsManager);
    local nowResolution = getResolution_method:call(Constants.GraphicsManager);
    local Option = get_Option_method:call(Constants.GUIManager);

    local resolutions = getResolutions_method:call(Option);
    local oriResolution = getValue_method:call(Option, Options.RESOLUTION_SETTING);
    local oriUpscaleMode = getValue_method:call(Option, Options.UPSCALE_MODE);

    local resolution_max = settings.max_resolution or resolutions:get_size() - 1;
    local upscale_increase_step = get_IsEnableUpscaling_method:call(UpscaleSetting) == true and -1 or 0;
    local prefered_option = graphicLevel < 0 and settings.down_level_prefered_option or settings.up_level_prefered_option;

    local prevResolutionIndex = resolutionIndexOf(resolutions, nowResolution);
    local msg = "";

    local upscale = oriUpscaleMode;
    local resolution = oriResolution;
    if prefered_option == 1 then
        upscale, resolution = caculateGraphicOptions(oriUpscaleMode, oriResolution, settings.min_upscale_mode, settings.max_upscale_mode, settings.min_resolution, resolution_max, upscale_increase_step, 1);
    else
        resolution, upscale = caculateGraphicOptions(oriResolution, oriUpscaleMode, settings.min_resolution, resolution_max, settings.min_upscale_mode, settings.max_upscale_mode, 1, upscale_increase_step);
    end
    if resolution ~= prevResolutionIndex then
        local newResolution = resolutions[resolution];
        nowResolution:set_field("w", w_field:get_data(newResolution));
        nowResolution:set_field("h", h_field:get_data(newResolution));
        setResolution_method:call(Option, WindowModeOption[getValue_method:call(Option, Options.SCREEN_MODE)], nowResolution);
        msg = "해상도: " .. resolutionString(resolutions[prevResolutionIndex]) .. " -> " .. resolutionString(nowResolution);
    end
    if upscale_increase_step == -1 then
        local nowUpscale = indexOf(UpscaleQuality, get_Quality_method:call(UpscaleSetting));
        if upscale ~= nowUpscale then
            local newUpscale = UpscaleQuality[upscale];
            set_Quality_method:call(UpscaleSetting, newUpscale);
            updateRequest_method:call(UpscaleSetting);
            if msg ~= "" then
                msg = msg .. "\n";
            end
            msg = msg .. "업스케일: " .. getUpscaleName(UpscaleQuality[nowUpscale]) .. " -> " .. getUpscaleName(newUpscale);
        end
    end
    if msg ~= "" then
        autoAdjustReset();
        msg = "그래픽 강도: " .. tostring(graphicLevel) .. ", " .. getStageName(stage) .. ": " .. getEnvName(env) .. "\n" .. msg;
        Constants.addSystemLog(msg);
    end
end

local function resetGraphics()
    graphicLevel = 0;
    if settings.enabled == true then
        applyGraphicLevel();
    end
end

local function getAvgFps()
    local fps = 0;
    for _, v in ipairs(autoAdjustFpsTable) do
        fps = fps + v;
    end
    return fps / #autoAdjustFpsTable;
end

local function reduceGraphicLevel(nowTime)
    local newGraphicLevel = graphicLevel - 1;
    local recommendLevel = calculateGraphicLevel(stage, env);
    if recommendLevel - newGraphicLevel > settings.auto_adjust_max_level then
        newGraphicLevel = recommendLevel - settings.auto_adjust_max_level;
    end
    if newGraphicLevel ~= graphicLevel then
        graphicLevel = newGraphicLevel;
        autoAdjustLastReduceTime = nowTime;
        applyGraphicLevel();
    end
end

local function autoAdjust()
    if env ~= nil and env ~= environments.INVALID and stage ~= nil and stage ~= stages.INVALID then
        local now = Constants.os.time();
        table.insert(autoAdjustFpsTable, get_Fps_method:call(nil));
        if autoAdjustDurationBegin == 0 then
            autoAdjustDurationBegin = now;
        elseif autoAdjustDurationBegin > 0 then
            local duration = now - autoAdjustDurationBegin;
            if duration >= settings.auto_adjust_increase_duration then
                local fps = getAvgFps();
                if fps < fpsLowTrigger then
                    reduceGraphicLevel(now);
                elseif fps > fpsHighTrigger then
                    if autoAdjustLastReduceTime == nil or now - autoAdjustLastReduceTime >= settings.auto_adjust_recover_interval then
                        local newGraphicLevel = graphicLevel + 1;
                        local newLevel = calculateGraphicLevel(stage, env) + settings.auto_adjust_max_level;
                        if newGraphicLevel > newLevel then
                            newGraphicLevel = newLevel;
                        end
                        if newGraphicLevel ~= graphicLevel then
                            graphicLevel = newGraphicLevel;
                            applyGraphicLevel();
                        end
                    end
                end
                if duration >= settings.auto_adjust_reduce_duration then
                    autoAdjustDurationBegin = now;
                end
            else
                if duration >= settings.auto_adjust_reduce_duration then
                    if getAvgFps() < fpsLowTrigger then
                        reduceGraphicLevel(now);
                    end
                end
            end
        end
    end
end

local function changeCondition(stageNo, envNo)
    if settings.enabled == true then
        local newStage = stageNo or getCurrentStageMasterPlayer_method:call(nil);
        local newEnv = envNo or getCurrentEnvType_method:call(nil);
        local isUpdateRequired = false;
        if newStage ~= nil and newStage ~= stages.INVALID and (stage == nil or newStage ~= stage) then
            stage = newStage;
            if isUpdateRequired == false then
                isUpdateRequired = true;
            end
        end
        if newEnv ~= nil and newEnv ~= environments.INVALID and (env == nil or newEnv ~= env) then
            env = newEnv;
            if isUpdateRequired == false then
                isUpdateRequired = true;
            end
        end
        if isUpdateRequired == true then
            autoAdjustReset();
            local newGraphicLevel = calculateGraphicLevel(stage, env);
            if newGraphicLevel ~= graphicLevel then
                graphicLevel = newGraphicLevel;
                applyGraphicLevel();
            end
        end
    end
end

changeCondition(nil, nil);

local function questPostHook(retval)
    if settings.enabled == true then
        autoAdjustLastReduceTime = nil;
    end
    return retval;
end

sdk.hook(sdk.find_type_definition("app.MasterFieldManager"):get_method("onChangedStage(app.FieldDef.STAGE)"), function(args)
    if settings.enabled == true then
        thread.get_hook_storage()["newStage"] = sdk.to_int64(args[3]) & 0xFFFFFFFF;
    end
end, function()
    changeCondition(thread.get_hook_storage()["newStage"], nil);
end);

sdk.hook(sdk.find_type_definition("app.EnemyManager"):get_method("onChangedEnvironment(app.FieldDef.STAGE, app.EnvironmentType.ENVIRONMENT, app.EnvironmentType.ENVIRONMENT)"), function(args)
    if settings.enabled == true then
        thread.get_hook_storage()["env"] = sdk.to_int64(args[5]) & 0xFFFFFFFF;
    end
end, function()
    changeCondition(nil, thread.get_hook_storage()["env"]);
end);

for _, t in pairs({"app.cQuestPlaying", "app.cQuestCancel", "app.cQuestClear", "app.cQuestFailed", "app.cQuestResult", "app.cQuestReward"}) do
    sdk.hook(sdk.find_type_definition(t):get_method("enter"), nil, questPostHook);
end

re.on_config_save(saveConfig);

re.on_script_reset(function()
    if settings.enabled == true then
        resetGraphics();
    end
end);

re.on_frame(function()
    if settings.enabled == true and settings.auto_adjust == true then
        autoAdjust();
    end
end);

local uiCurrentStageIdx = 0;
local uiCurrentEnvIdx = 0;
re.on_draw_ui(function()
    if imgui.tree_node("Dynamic Resolution") == true then
        local changed = false;
        local requireSave = false;
        changed, settings.enabled = imgui.checkbox("사용", settings.enabled);
        if changed == true and requireSave ~= true then
            requireSave = true;
            if settings.enabled == false then
                resetGraphics();
            end
            changeCondition(nil, nil);
        end
        if settings.enabled == true then
            if Constants.GUIManager == nil then
                Constants.GUIManager = sdk.get_managed_singleton("app.GUIManager");
            end
            local Option = get_Option_method:call(Constants.GUIManager);
            local resolutions = getResolutions_method:call(Option);
            local resolutionSettingValue = getValue_method:call(Option, Options.RESOLUTION_SETTING);
            local resolutionCount = resolutions:get_size() - 1;
            local max_resolution = resolutionCount;
            imgui.text("그래픽 강도 0: ");
            imgui.same_line();
            imgui.text(resolutionString(resolutions[resolutionSettingValue]));
            imgui.same_line();
            imgui.text("업스케일: " .. getUpscaleName(UpscaleQuality[getValue_method:call(Option, Options.UPSCALE_MODE)]));
            changed, uiCurrentStageIdx = imgui.combo("지역", uiCurrentStageIdx, stageNames);
            if changed == true then
                uiCurrentEnvIdx = 0;
            end
            _, uiCurrentEnvIdx = imgui.combo("환경", uiCurrentEnvIdx, environmentNames);
            local selectedStage = stages[uiCurrentStageIdx];
            local selectedEnv = environments[uiCurrentEnvIdx];
            if selectedStage ~= nil and selectedEnv ~= nil then
                local graphicLevel = calculateGraphicLevel(selectedStage, selectedEnv);
                local thisChanged, value = imgui.slider_int("그래픽 강도", graphicLevel, 0 - max_resolution - max_upscale_mode, max_resolution + max_upscale_mode);
                if thisChanged == true then
                    local found_idx = nil;
                    if settings.items == nil then
                        settings.items = {};
                    else
                        for k, item in pairs(settings.items) do
                            if item.matcher.stage == selectedStage and item.matcher.env == selectedEnv then
                                found_idx = k;
                                break;
                            end
                        end
                    end
                    if found_idx ~= nil then
                        if value == 0 then
                            table.remove(settings.items, found_idx);
                        else
                            settings.items[found_idx].level = value;
                        end
                    else
                        if value ~= 0 then
                            table.insert(settings.items, {matcher = {stage = selectedStage, env = selectedEnv}, level = value});
                        end
                    end
                    if selectedStage == stage and selectedEnv == env then
                        graphicLevel = value;
                        applyGraphicLevel();
                    end
                    if requireSave ~= true then
                        requireSave = true;
                    end
                end
            end
            changed, settings.auto_adjust = imgui.checkbox("자동 조정", settings.auto_adjust);
            if changed == true then
                if requireSave ~= true then
                    requireSave = true;
                end
                autoAdjustReset();
            end
            if settings.auto_adjust == true and imgui.tree_node("자동 조정 설정") == true then
                changed, settings.auto_adjust_fps_target = imgui.slider_int("목표 FPS", settings.auto_adjust_fps_target, 30, 144);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
                    fpsLowTrigger = settings.auto_adjust_fps_target - settings.auto_adjust_fps_reduce_threshold;
                    fpsHighTrigger = settings.auto_adjust_fps_target + settings.auto_adjust_fps_increase_threshold;
                    autoAdjustReset();
                end
                changed, settings.auto_adjust_fps_reduce_threshold = imgui.slider_int("FPS 하락 한계치", settings.auto_adjust_fps_reduce_threshold, 1, 20);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
                    fpsLowTrigger = settings.auto_adjust_fps_target - settings.auto_adjust_fps_reduce_threshold;
                    autoAdjustReset();
                end
                changed, settings.auto_adjust_fps_increase_threshold = imgui.slider_int("FPS 초과 한계치", settings.auto_adjust_fps_increase_threshold, 0, 20);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
                    fpsHighTrigger = settings.auto_adjust_fps_target + settings.auto_adjust_fps_increase_threshold;
                    autoAdjustReset();
                end
                changed, settings.auto_adjust_reduce_duration = imgui.slider_int("하락 인터벌", settings.auto_adjust_reduce_duration, 1, 15);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
                    if settings.auto_adjust_reduce_duration > settings.auto_adjust_increase_duration then
                        settings.auto_adjust_increase_duration = settings.auto_adjust_reduce_duration;
                    end
                    autoAdjustReset();
                end
                changed, settings.auto_adjust_increase_duration = imgui.slider_int("초과 인터벌", settings.auto_adjust_increase_duration, settings.auto_adjust_reduce_duration, 30);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
                    autoAdjustReset();
                end
                changed, settings.auto_adjust_max_level = imgui.slider_int("최대 조정 강도", settings.auto_adjust_max_level, 1, 5);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
                    autoAdjustReset();
                end
                changed, settings.auto_adjust_recover_interval = imgui.slider_int("Recover Interval", settings.auto_adjust_recover_interval, settings.auto_adjust_increase_duration, 300);
                if changed == true and requireSave ~= true then
                    requireSave = true;
                end
                imgui.tree_pop();
            end
            if imgui.tree_node("상세 설정") == true then
                if settings.max_resolution ~= nil then
                    max_resolution = settings.max_resolution;
                end
                local resolution_names = {};
                for i = resolutionSettingValue, resolutionCount do
                    table.insert(resolution_names, resolutionString(resolutions[i]));
                end
                local thisChanged, max_resolution_idx = imgui.combo("최대 해상도", max_resolution, resolution_names);
                if thisChanged == true then
                    max_resolution_idx = resolutionSettingValue + max_resolution_idx - 1;
                    settings.max_resolution = max_resolution_idx ~= resolutionCount and max_resolution_idx or nil;
                    if requireSave ~= true then
                        requireSave = true;
                    end
                end
                resolution_names = {};
                for i = 0, resolutionSettingValue do
                    table.insert(resolution_names, resolutionString(resolutions[i]));
                end
                local newValue = nil;
                changed, newValue = imgui.combo("최소 해상도", settings.min_resolution + 1, resolution_names);
                if changed == true then
                    settings.min_resolution = newValue - 1;
                    if requireSave ~= true then
                        requireSave = true;
                    end
                end
                changed, newValue = imgui.combo("최대 업스케일 모드", indexOf(UpscaleQuality, settings.max_upscale_mode), UpscaleNames);
                if changed == true then
                    settings.max_upscale_mode = UpscaleQuality[newValue];
                    if requireSave ~= true then
                        requireSave = true;
                    end
                end
                changed, newValue = imgui.combo("최소 업스케일 모드", indexOf(UpscaleQuality, settings.min_upscale_mode), UpscaleNames);
                if changed == true then
                    settings.min_upscale_mode = UpscaleQuality[newValue];
                    if requireSave ~= true then
                        requireSave = true;
                    end
                end
                changed, settings.up_level_prefered_option = imgui.combo("강도 상향 선호 옵션", settings.up_level_prefered_option, GraphicOptions);
                if changed == true and requireSave ~= true then
                    requireSave = true;
                end
                changed, settings.down_level_prefered_option = imgui.combo("강도 하향 선호 옵션", settings.down_level_prefered_option, GraphicOptions);
                if changed == true and requireSave ~= true then
                    requireSave = true;
                end
                imgui.tree_pop();
            end
        end
        imgui.tree_pop();
        if requireSave == true then
            saveConfig();
        end
    end
end);