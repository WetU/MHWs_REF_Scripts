local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

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

local HunterQuestActionController_type_def = sdk.find_type_definition("app.mcHunterQuestActionController");
local showStamp_method = HunterQuestActionController_type_def:get_method("showStamp(app.mcHunterQuestActionController.QUEST_ACTION_TYPE)");

local FALSE_ptr = sdk.to_ptr(false);

sdk.hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), nil, function(retval)
    return config.enableKillCam == true and FALSE_ptr or retval;
end);

sdk.hook(HunterQuestActionController_type_def:get_method("checkQuestActionEnable(app.mcHunterQuestActionController.QUEST_ACTION_TYPE)"), function(args)
    if config.enableEndCut == true then
        local storage = thread.get_hook_storage();
        storage["this"] = sdk.to_managed_object(args[2]);
        storage["actionType"] = sdk.to_int64(args[3]) & 0xFFFFFFFF;
    end
end, function(retval)
    if config.enableEndCut == true and (sdk.to_int64(retval) & 1) == 1 then
        local storage = thread.get_hook_storage();
        showStamp_method:call(storage["this"], storage["actionType"]);
    end
    return retval;
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if imgui.tree_node("Auto Skip Kill Cam") == true then
		local changed = false;
		changed, config.enableKillCam = imgui.checkbox("Enable Skip Kill-Cam", config.enableKillCam);
        changed, config.enableEndCut = imgui.checkbox("Enable Skip Quest End Cutscene", config.enableEndCut);

		if changed == true then
			saveConfig();
		end
		imgui.tree_pop();
	end
end);