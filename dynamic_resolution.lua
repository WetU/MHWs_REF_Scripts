local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local pairs = Constants.pairs;
local ipairs = Constants.ipairs;
local string = Constants.string;
local tostring = Constants.tostring;
local table = Constants.table;
local os = Constants.os;

local getOptionValue_method = sdk.find_type_definition("app.OptionUtil"):get_method("getOptionValue(app.Option.ID)"); -- static

local PorterUtil_type_def = sdk.find_type_definition("app.PorterUtil");
local getCurrentEnvType_method = PorterUtil_type_def:get_method("getCurrentEnvType"); -- static
local getCurrentStageMasterPlayer_method = PorterUtil_type_def:get_method("getCurrentStageMasterPlayer"); -- static

local get_GUI_method = Constants.GA_type_def:get_method("get_GUI"); -- static

local get_Option_method = get_GUI_method:get_return_type():get_method("get_Option");

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

local max_upscale_mode = 4;
local stage = nil;
local env = nil;
local graphicLevel = 0;

local autoAdjustDurationBegin = 0;
local autoAdjustFrames = 0;
local autoAdjustLastReduceTime = nil;

local questFrames = 0;
local questBeginTime = 0;

local function sendMsg(msg)
    local ChatManager = Constants.get_Chat_method:call(nil);
    if ChatManager ~= nil then
        Constants.addSystemLog_method:call(ChatManager, msg);
    end
end

local GraphicOptions = {
    "업스케일",
    "해상도"
};
local GraphicOptionValues = {
    0, -- Upscale
    1 -- Resolution
};

local settings = {
    enabled = true,
    fps_message = false,
    max_resolution = nil,
    min_resolution = 0,
    max_upscale_mode = max_upscale_mode,
    min_upscale_mode = 0,
    up_level_prefered_option = GraphicOptionValues[1],
    down_level_prefered_option = GraphicOptionValues[1],
    auto_adjust = true,
    auto_adjust_fps_target = 30,
    auto_adjust_fps_reduce_threshold = 3,
    auto_adjust_fps_increase_threshold = 6,
    auto_adjust_max_level = 3,
    auto_adjust_reduce_duration = 5,
    auto_adjust_increase_duration = 10,
    auto_adjust_recover_interval = 100
};

local WindowMode_type_def = sdk.find_type_definition("via.render.WindowMode");
local WindowModeOption = {
    [0] = WindowMode_type_def:get_field("Borderless"):get_data(nil),
    [1] = WindowMode_type_def:get_field("Normal"):get_data(nil)
};

local Option_ID_type_def = sdk.find_type_definition("app.Option.ID");
local Options = {
    SCREEN_MODE = Option_ID_type_def:get_field("SCREEN_MODE"):get_data(nil),
    RESOLUTION_SETTING = Option_ID_type_def:get_field("RESOLUTION_SETTING"):get_data(nil),
    FRAME_GENERATION = Option_ID_type_def:get_field("FRAME_GENERATION"):get_data(nil),
    UPSCALE_MODE = Option_ID_type_def:get_field("UPSCALE_MODE"):get_data(nil)
};

local STAGE_type_def = getCurrentStageMasterPlayer_method:get_return_type();
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
            sendMsg("알 수 없는 지역: " .. name);
        end
    end
    return name;
end

local ENVIRONMENT_type_def = getCurrentEnvType_method:get_return_type();
local environmentNames = {
    "황폐기",
    "이상 기후",
    "풍요기"
};
local environments = {
    ENVIRONMENT_type_def:get_field("RUIN"):get_data(nil),
    ENVIRONMENT_type_def:get_field("ABNORMAL"):get_data(nil),
    ENVIRONMENT_type_def:get_field("FERTILITY"):get_data(nil),
    INVALID = ENVIRONMENT_type_def:get_field("INVALID"):get_data(nil)
};

local function getEnvName(envNo)
    local name = "기본값";
    for i, v in ipairs(environments) do
        if envNo == v then
            name = environmentNames[i];
        end
    end
    return name;
end

local QUALITY_type_def = get_Quality_method:get_return_type();
local UpscaleNames = {
    "DLAA",
    "품질 우선",
    "균형",
    "성능 우선",
    "성능 최우선"
};
local UpscaleQuality = {
    QUALITY_type_def:get_field("NativeAA"):get_data(nil),
    QUALITY_type_def:get_field("Quality"):get_data(nil),
    QUALITY_type_def:get_field("Balanced"):get_data(nil),
    QUALITY_type_def:get_field("Performance"):get_data(nil),
    QUALITY_type_def:get_field("UltraPerformance"):get_data(nil)
};

local function getUpscaleName(mode)
    local name = nil;
    for i, v in ipairs(UpscaleQuality) do
        if mode == v then
            name = UpscaleNames[i];
        end
    end
    return name;
end

local function saveConfig() 
    json.dump_file("dynamic_resolution.json", settings);
end

local loaded = json.load_file("dynamic_resolution.json");
if loaded ~= nil then
    for k, v in pairs(loaded) do
        settings[k] = v;
    end
end

local function resolutionEqual(a, b)
    if a == nil or b == nil then
        return false;
    end
    if a == b or (a.w == b.w and a.h == b.h) then
        return true;
    end
    return false;
end

local function resolutionIndexOf(rs, r)
    if rs == nil or r == nil then
        return nil;
    end
    for k, v in pairs(rs) do
        if resolutionEqual(v, r) == true then
            return k;
        end
    end
    return nil;
end

local function indexOf(t, a)
    for k, v in pairs(t) do
        if v == a then
            return k;
        end
    end
    return nil;
end

local function autoAdjustReset()
    autoAdjustDurationBegin = 0;
    autoAdjustFrames = 0;
end

local function resolutionString(r)
    return string.format("%dx%d", r.w, r.h);
end

local function getStageDefaultGraphicLevel(stageNo)
    if settings.items ~= nil then
        for _, item in pairs(settings.items) do
            if item.matcher ~= nil and item.matcher.stage == stageNo and (item.matcher.env == nil or item.matcher.env == environments.INVALID) then
                return item.level;
            end
        end
    end
    return 0;
end

local function calculateGraphicLevel(stageNo, envNo)
    if settings.items == nil then
        return 0;
    end
    for _, item in pairs(settings.items) do
        if item.matcher ~= nil and item.matcher.stage == stageNo and item.matcher.env == envNo then
            return item.level;
        end
    end
    return getStageDefaultGraphicLevel(stageNo);
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

local function applyGraphicLevel()
    if settings.enabled == true then
        local GraphicsManager = Constants.get_Graphics_method:call(nil);
        local UpscaleSetting = get_UpscaleSetting_method:call(GraphicsManager);
        local nowResolution = getResolution_method:call(GraphicsManager);

        local upscaleEnabled = get_IsEnableUpscaling_method:call(UpscaleSetting);

        local Option = get_Option_method:call(get_GUI_method:call(nil));
        local resolutions = getResolutions_method:call(Option);
        local oriResolution = getValue_method:call(Option, Options.RESOLUTION_SETTING);
        local oriUpscaleMode = getValue_method:call(Option, Options.UPSCALE_MODE);

        local resolution_max = settings.max_resolution == nil and #resolutions - 1 or settings.max_resolution;
        local upscale_increase_step = upscaleEnabled == false and 0 or -1;
        local prefered_option = graphicLevel < 0 and settings.down_level_prefered_option or settings.up_level_prefered_option;

        local prevResolutionIndex = resolutionIndexOf(resolutions, nowResolution);
        local msg = "";

        local upscale = oriUpscaleMode;
        local resolution = oriResolution;
        if prefered_option == GraphicOptionValues[1] then
            upscale, resolution = caculateGraphicOptions(oriUpscaleMode, oriResolution, settings.min_upscale_mode, settings.max_upscale_mode, settings.min_resolution, resolution_max, upscale_increase_step, 1);
        else
            resolution, upscale = caculateGraphicOptions(oriResolution, oriUpscaleMode, settings.min_resolution, resolution_max, settings.min_upscale_mode, settings.max_upscale_mode, 1, upscale_increase_step);
        end

        if resolution ~= prevResolutionIndex then
            nowResolution.w = resolutions[resolution].w;
            nowResolution.h = resolutions[resolution].h;
            setResolution_method:call(Option, WindowModeOption[getValue_method:call(Option, Options.SCREEN_MODE)], nowResolution);
            msg = "해상도: " .. resolutionString(resolutions[prevResolutionIndex]) .. " -> " .. resolutionString(nowResolution);
        end

        if upscale_increase_step == -1 then
            local nowUpscale = get_Quality_method:call(UpscaleSetting);
            nowUpscale = indexOf(UpscaleQuality, nowUpscale) - 1;
            if upscale ~= nowUpscale then
                set_Quality_method:call(UpscaleSetting, UpscaleQuality[upscale + 1]);
                updateRequest_method:call(UpscaleSetting);
                if msg ~= "" then
                    msg = msg .. "\n";
                end
                msg = msg .. "업스케일: " .. getUpscaleName(UpscaleQuality[nowUpscale + 1]) .. " -> " .. getUpscaleName(UpscaleQuality[upscale + 1]);
            end
        end
        if msg ~= "" then
            autoAdjustReset();
            msg = "그래픽 강도: " .. tostring(graphicLevel)  .. getStageName(stage) .. ": " .. getEnvName(env) .. ":\n" .. msg;
            sendMsg(msg);
        end
    end
end

local function resetGraphics()
    graphicLevel = 0;
    applyGraphicLevel();
end

local function autoAdjust()
    if settings.enabled == true and settings.auto_adjust == true and env ~= nil and env ~= environments.INVALID and stage ~= nil and stage ~= stages.INVALID then
        local now = os.time();
        if autoAdjustDurationBegin > 0 then
            autoAdjustFrames = autoAdjustFrames + 1;
            local duration = now - autoAdjustDurationBegin;
            local fps = getOptionValue_method:call(nil, Options.FRAME_GENERATION) == 0 and (autoAdjustFrames / duration) * 2 or autoAdjustFrames / duration;
            if duration >= settings.auto_adjust_increase_duration then
                if fps < settings.auto_adjust_fps_target - settings.auto_adjust_fps_reduce_threshold then
                    local newGraphicLevel = graphicLevel - 1;
                    local recommandLevel = calculateGraphicLevel(stage, env);
                    if recommandLevel - newGraphicLevel > settings.auto_adjust_max_level then
                        newGraphicLevel = recommandLevel - settings.auto_adjust_max_level;
                    end
                    if newGraphicLevel ~= graphicLevel then
                        graphicLevel = newGraphicLevel;
                        autoAdjustLastReduceTime = now;
                        applyGraphicLevel();
                    end
                elseif fps > settings.auto_adjust_fps_target + settings.auto_adjust_fps_increase_threshold then
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
            else
                if duration >= settings.auto_adjust_reduce_duration and fps < (settings.auto_adjust_fps_target - settings.auto_adjust_fps_reduce_threshold) then
                    local newGraphicLevel = graphicLevel - 1;
                    local recommandLevel = calculateGraphicLevel(stage, env);
                    if recommandLevel - newGraphicLevel > settings.auto_adjust_max_level then
                        newGraphicLevel = recommandLevel - settings.auto_adjust_max_level;
                    end
                    if newGraphicLevel ~= graphicLevel then
                        graphicLevel = newGraphicLevel;
                        autoAdjustLastReduceTime = now;
                        applyGraphicLevel();
                    end
                end
            end
        end
        autoAdjustDurationBegin = now;
        autoAdjustFrames = 0;
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

sdk.hook(sdk.find_type_definition("app.cQuestPlaying"):get_method("enter"), nil, function(retval)
    if settings.enabled == true then
        autoAdjustLastReduceTime = nil;
        if settings.fps_message == true then
            questFrames = 0;
            questBeginTime = os.time();
        end
    end
    return retval;
end);

for _, t in pairs({"app.cQuestCancel", "app.cQuestClear", "app.cQuestFailed", "app.cQuestResult", "app.cQuestReward"}) do
    sdk.hook(sdk.find_type_definition(t):get_method("enter"), nil, function(retval)
        if settings.enabled == true then
            autoAdjustLastReduceTime = nil;
            if settings.fps_message == true and questFrames > 0 and questBeginTime > 0 then
                local questEndTime = os.time();
                local questDuration = questEndTime - questBeginTime;
                questBeginTime = 0;
                if questDuration <= 0 then
                    questFrames = 0;
                else
                    local frameGen = getOptionValue_method:call(nil, Options.FRAME_GENERATION) == 0;
                    if frameGen == true then
                        questFrames = questFrames * 2;
                    end
                    local fps = questFrames / questDuration;
                    questFrames = 0;
                    local GraphicsManager = Constants.get_Graphics_method:call(nil);
                    local msg = string.format(
                        "%s %s 그래픽 강도: %d, FPS: %.2f\n해상도: %s\n업스케일: %d",
                        getStageName(stage),
                        getEnvName(env),
                        graphicLevel,
                        fps,
                        resolutionString(getResolution_method:call(GraphicsManager)),
                        getUpscaleName(get_Quality_method:call(get_UpscaleSetting_method:call(GraphicsManager)))
                    );
                    sendMsg(msg);
                end
            end
        end
        return retval;
    end);
end

re.on_config_save(saveConfig);

re.on_script_reset(function()
    if settings.enabled == true then
        resetGraphics();
    end
end);

re.on_frame(function()
    if settings.enabled == true then
        if settings.fps_message == true and questBeginTime > 0 then
            questFrames = questFrames + 1;
        end
        if settings.auto_adjust == true then
            autoAdjust();
        end
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
        if settings.enabled == false then
            imgui.tree_pop();
            return;
        end
        changed, settings.fps_message = imgui.checkbox("퀘스트 종료 시 평균 FPS 보고", settings.fps_message);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        local Option = get_Option_method:call(get_GUI_method:call(nil));
        local resolutions = getResolutions_method:call(Option);
        local resolutionSettingValue = getValue_method:call(Option, Options.RESOLUTION_SETTING);
        local upscaleValue = getValue_method:call(Option, Options.UPSCALE_MODE);
        local resolutionCount = #resolutions - 1;
        local max_resolution = resolutionCount;
        imgui.text("그래픽 강도 0: ");
        imgui.same_line();
        imgui.text(resolutionString(resolutions[resolutionSettingValue]));
        imgui.same_line();
        imgui.text("업스케일: " .. getUpscaleName(UpscaleQuality[upscaleValue + 1]));
    
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
                    for i, item in pairs(settings.items) do
                        if item.matcher.stage == selectedStage and item.matcher.env == selectedEnv then
                            item.level = value;
                            found_idx = i;
                            break;
                        end
                    end
                end
                local stageDefaultValue = getStageDefaultGraphicLevel(selectedStage);
                if found_idx ~= nil then
                    if selectedEnv == environments.INVALID then
                        if value == 0 then
                            table.remove(settings.items, found_idx);
                        end
                    else
                        if value == stageDefaultValue then
                            table.remove(settings.items, found_idx);
                        end
                    end
                else
                    if (value ~= 0 and selectedEnv == environments.INVALID) or (value ~= stageDefaultValue and selectedEnv ~= environments.INVALID) then 
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
        if settings.auto_adjust == true then
            if imgui.tree_node("자동 조정 설정") == true then
                changed, settings.auto_adjust_fps_target = imgui.slider_int("목표 FPS", settings.auto_adjust_fps_target, 30, 144);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
                    autoAdjustReset();
                end
                changed, settings.auto_adjust_fps_reduce_threshold = imgui.slider_int("FPS 하락 한계치", settings.auto_adjust_fps_reduce_threshold, 1, 20);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
                    autoAdjustReset();
                end
                changed, settings.auto_adjust_fps_increase_threshold = imgui.slider_int("FPS 초과 한계치", settings.auto_adjust_fps_increase_threshold, 0, 20);
                if changed == true then
                    if requireSave ~= true then
                        requireSave = true;
                    end
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
            changed, newValue = imgui.combo("강도 상향 선호 옵션", indexOf(GraphicOptionValues, settings.up_level_prefered_option), GraphicOptions);
            if changed == true then
                settings.up_level_prefered_option = GraphicOptionValues[newValue];
                if requireSave ~= true then
                    requireSave = true;
                end
            end
            changed, newValue = imgui.combo("강도 하향 선호 옵션", indexOf(GraphicOptionValues, settings.down_level_prefered_option), GraphicOptions);
            if changed == true then
                settings.down_level_prefered_option = GraphicOptionValues[newValue];
                if requireSave ~= true then
                    requireSave = true;
                end
            end
            imgui.tree_pop();
        end
        imgui.tree_pop();
        if requireSave == true then
            saveConfig();
        end
    end
end);