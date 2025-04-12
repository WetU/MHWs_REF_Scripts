local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local PlayerGlobalParam_type_def = sdk.find_type_definition("app.user_data.PlayerGlobalParam");

local HunterQuestActionController_type_def = sdk.find_type_definition("app.mcHunterQuestActionController");
local Timer_field = HunterQuestActionController_type_def:get_field("_Timer");
local TimerType_field = HunterQuestActionController_type_def:get_field("_TimerType");

local TIMER_TYPE_type_def = sdk.find_type_definition("app.mcHunterQuestActionController.TIMER_TYPE");
local BEFORE_ACTION = TIMER_TYPE_type_def:get_field("BEFORE_ACTION"):get_data(nil); -- static
local STAMP = TIMER_TYPE_type_def:get_field("STAMP"):get_data(nil); -- static

local config = nil;

local function loadConfig()
    config = json.load_file("AutoSkipKillCam.json") or {enableKillCam = true, enableEndCut = true};
    if config.enableKillCam == nil then
        config.enableKillCam = true;
    end
    if config.enableEndCut == nil then
        config.enableEndCut = true;
    end
end

local function saveConfig()
    json.dump_file("AutoSkipKillCam.json", config);
end

loadConfig();

local zero_ptr = sdk.float_to_ptr(0.0);

local function skipTime(retval)
    return config.enableEndCut == true and zero_ptr or retval;
end

sdk.hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), nil, function(retval)
    return config.enableKillCam == true and Constants.FALSE_ptr or retval;
end);

sdk.hook(HunterQuestActionController_type_def:get_method("updateMain"), function(args)
    if config.enableEndCut == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function(retval)
    local HunterQuestActionController = thread.get_hook_storage()["this"];
    if HunterQuestActionController ~= nil then
        local TimerType = TimerType_field:get_data(HunterQuestActionController);
        if (TimerType == BEFORE_ACTION or TimerType == STAMP) and Timer_field:get_data(HunterQuestActionController) ~= 0.0 then
            HunterQuestActionController:set_field("_Timer", 0.0);
        end
    end
    return retval;
end);

sdk.hook(sdk.find_type_definition("app.GUI020201"):get_method("request"), Constants.getObject, function()
    local GUI020201 = thread.get_hook_storage()["this"];
    if GUI020201 ~= nil then
        if Constants.requestClose_method == nil then
            Constants.requestClose_method = GUI020201:get_type_definition():get_method("requestClose(System.Boolean)");
        end
        Constants.requestClose_method:call(GUI020201, false);
    end
end);

sdk.hook(PlayerGlobalParam_type_def:get_method("get_QuestClearActionWaitTime"), nil, skipTime);
sdk.hook(PlayerGlobalParam_type_def:get_method("get_QuestRetireActionWaitTime"), nil, skipTime);
sdk.hook(PlayerGlobalParam_type_def:get_method("get_QuestFailedActionWaitTime"), nil, skipTime);
sdk.hook(PlayerGlobalParam_type_def:get_method("get_QuestReplicaLeaveActionWaitTime"), nil, skipTime);
sdk.hook(PlayerGlobalParam_type_def:get_method("get_QuestClearStampTime"), nil, skipTime);
sdk.hook(PlayerGlobalParam_type_def:get_method("get_QuestRetireStampTime"), nil, skipTime);
sdk.hook(PlayerGlobalParam_type_def:get_method("get_QuestFailedStampTime"), nil, skipTime);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if imgui.tree_node("Auto Skip Kill Cam") == true then
		local changed = false;
        local requireSave = false;
		changed, config.enableKillCam = imgui.checkbox("Enable Skip Kill-Cam", config.enableKillCam);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, config.enableEndCut = imgui.checkbox("Enable Skip Quest End Cutscene", config.enableEndCut);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
		if requireSave == true then
			saveConfig();
		end
		imgui.tree_pop();
	end
end);