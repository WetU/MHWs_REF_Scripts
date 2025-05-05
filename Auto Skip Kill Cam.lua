local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local HunterQuestActionController_type_def = sdk.find_type_definition("app.mcHunterQuestActionController");
local showStamp_method = HunterQuestActionController_type_def:get_method("showStamp(app.mcHunterQuestActionController.QUEST_ACTION_TYPE)");

local GUI020201_type_def = sdk.find_type_definition("app.GUI020201");
local CurType_field = GUI020201_type_def:get_field("_CurType");

local TYPE_type_def = CurType_field:get_type();
local TYPE = {
    START = TYPE_type_def:get_field("START"):get_data(nil),
    MAX = TYPE_type_def:get_field("MAX"):get_data(nil)
};

local config = json.load_file("AutoSkipKillCam.json") or {enableKillCam = true};
if config.enableKillCam == nil then
    config.enableKillCam = true;
end

local function saveConfig()
    json.dump_file("AutoSkipKillCam.json", config);
end

sdk.hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), nil, function(retval)
    return config.enableKillCam == true and Constants.FALSE_ptr or retval;
end);

sdk.hook(HunterQuestActionController_type_def:get_method("checkQuestActionEnable(app.mcHunterQuestActionController.QUEST_ACTION_TYPE)"), function(args)
    if config.enableKillCam == true then
        local storage = thread.get_hook_storage();
        storage.this = sdk.to_managed_object(args[2]);
        storage.actionType = sdk.to_int64(args[3]) & 0xFFFFFFFF;
    end
end, function(retval)
    if config.enableKillCam == true and sdk.to_int64(retval) & 1 == 1 then
        local storage = thread.get_hook_storage();
        showStamp_method:call(storage.this, storage.actionType);
    end
    return retval;
end);

sdk.hook(GUI020201_type_def:get_method("guiVisibleUpdate"), Constants.getObject, function()
    local GUI020201 = thread.get_hook_storage()["this"];
    local CurType = CurType_field:get_data(GUI020201);
    if CurType ~= nil and CurType ~= TYPE.MAX and CurType ~= TYPE.START then
        Constants.requestClose_method:call(GUI020201, false);
    end
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if imgui.tree_node("Auto Skip Kill Cam") == true then
		local changed = false;
		changed, config.enableKillCam = imgui.checkbox("Enable Skip Kill-Cam", config.enableKillCam);
        if changed == true then
            saveConfig();
        end
		imgui.tree_pop();
	end
end);