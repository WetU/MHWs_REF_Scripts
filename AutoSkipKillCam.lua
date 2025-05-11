local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local get_Param_method = Constants.QuestDirector_type_def:get_method("get_Param");

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");
local isOn_method = GUIAppOnTimerKey_type_def:get_method("isOn");
local Type_field = GUIAppOnTimerKey_type_def:get_field("_Type");

local RETURN_TIME_SKIP = Type_field:get_type():get_field("RETURN_TIME_SKIP"):get_data(nil);

local HunterQuestActionController_type_def = sdk.find_type_definition("app.mcHunterQuestActionController");
local showStamp_method = HunterQuestActionController_type_def:get_method("showStamp(app.mcHunterQuestActionController.QUEST_ACTION_TYPE)");

local GUI020201_type_def = sdk.find_type_definition("app.GUI020201");
local CurType_field = GUI020201_type_def:get_field("_CurType");
local GUI_field = GUI020201_type_def:get_field("_GUI");

local GUI020201TYPE_CLEAR = CurType_field:get_type():get_field("CLEAR"):get_data(nil);

local GUI_type_def = GUI_field:get_type();
local get_PlaySpeed_method = GUI_type_def:get_method("get_PlaySpeed");
local set_PlaySpeed_method = GUI_type_def:get_method("set_PlaySpeed(System.Single)");

local offsets = {
    Timer = 0xC8,
    Limit = 0xCC,
    Enabled = 0xD3,
    IsTimeOut = 0xD6
};

local config = json.load_file("AutoSkipKillCam.json") or {skipKillCam = true, autoEndQuest = false, enableInstantQuit = false, instantKey = false, skipEndScene = true};
if config.skipKillCam == nil then
    config.skipKillCam = true;
end
if config.autoEndQuest == nil then
    config.autoEndQuest = false;
end
if config.enableInstantQuit == nil then
    config.enableInstantQuit = false;
end
if config.instantKey == nil then
    config.instantKey = true;
end
if config.skipEndScene == nil then
    config.skipEndScene = true;
end

local function saveConfig()
    json.dump_file("AutoSkipKillCam.json", config);
end

sdk.hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), nil, function(retval)
    return config.skipKillCam == true and Constants.FALSE_ptr or retval;
end);

sdk.hook(GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    if config.autoEndQuest == true or config.instantKey == true then
        local GUIAppOnTimerKey = sdk.to_managed_object(args[2]);
        if Type_field:get_data(GUIAppOnTimerKey) == RETURN_TIME_SKIP then
            thread.get_hook_storage()["this"] = GUIAppOnTimerKey;
        end
    end
end, function()
    local GUIAppOnTimerKey = thread.get_hook_storage()["this"];
    if GUIAppOnTimerKey ~= nil and (config.autoEndQuest == true or (config.instantKey == true and isOn_method:call(GUIAppOnTimerKey) == true)) then
        GUIAppOnTimerKey:set_field("_Success", true);
    end
end);

local isSkipped = nil;
sdk.hook(Constants.QuestDirector_type_def:get_method("QuestReturnSkip"), nil, function()
    if config.enableInstantQuit == true then
        isSkipped = true;
    end
end);

sdk.hook(Constants.QuestDirector_type_def:get_method("update"), function(args)
    if config.enableInstantQuit == true and isSkipped == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    if config.enableInstantQuit == true and isSkipped == true then
        local QuestFlowParam = get_Param_method:call(thread.get_hook_storage()["this"]);
        if QuestFlowParam:read_byte(offsets.Enabled) == 1 and QuestFlowParam:read_byte(offsets.IsTimeOut) == 0 then
            QuestFlowParam:write_float(offsets.Timer, QuestFlowParam:read_float(offsets.Limit));
            QuestFlowParam:write_byte(offsets.IsTimeOut, 1);
        end
        isSkipped = false;
    end
end);

sdk.hook(HunterQuestActionController_type_def:get_method("checkQuestActionEnable(app.mcHunterQuestActionController.QUEST_ACTION_TYPE)"), function(args)
    if config.skipEndScene == true then
        local storage = thread.get_hook_storage();
        storage.this = sdk.to_managed_object(args[2]);
        storage.actionType = sdk.to_int64(args[3]) & 0xFFFFFFFF;
    end
end, function(retval)
    if config.skipEndScene == true and sdk.to_int64(retval) & 1 == 1 then
        local storage = thread.get_hook_storage();
        showStamp_method:call(storage.this, storage.actionType);
    end
    return retval;
end);

local function get_GUI020201(args)
    if config.skipEndScene == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end

sdk.hook(GUI020201_type_def:get_method("guiVisibleUpdate"), get_GUI020201, function()
    if config.skipEndScene == true then
        local GUI020201 = thread.get_hook_storage()["this"];
        if CurType_field:get_data(GUI020201) == GUI020201TYPE_CLEAR then
            local GUI = GUI_field:get_data(GUI020201);
            if GUI ~= nil and get_PlaySpeed_method:call(GUI) ~= 10.0 then
                set_PlaySpeed_method:call(GUI, 10.0);
            end
        end
    end
end);

sdk.hook(GUI020201_type_def:get_method("onCloseApp"), get_GUI020201, function()
    if config.skipEndScene == true then
        local GUI = GUI_field:get_data(thread.get_hook_storage()["this"]);
        if GUI ~= nil and get_PlaySpeed_method:call(GUI) ~= 1.0 then
            set_PlaySpeed_method:call(GUI, 1.0);
        end
    end
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if imgui.tree_node("Auto Skip Kill Cam") == true then
		local changed = false;
        local reqSave = false;
		changed, config.skipKillCam = imgui.checkbox("Enable skip kill-Cam", config.skipKillCam);
        if changed == true and reqSave ~= true then
            reqSave = true;
        end
        changed, config.autoEndQuest = imgui.checkbox("Enable auto skip carve timer", config.autoEndQuest);
        if changed == true and reqSave ~= true then
            reqSave = true;
        end
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("If it's not a Field Survey quest, Can't carve a slain monster.");
        end
        if config.autoEndQuest ~= true then
            changed, config.instantKey = imgui.checkbox("Remove skip key delay", config.instantKey);
            if changed == true and reqSave ~= true then
                reqSave = true;
            end
            if imgui.is_item_hovered() == true then
                imgui.set_tooltip("Change the 'End quest immediately' key input method from long press to single press.");
            end
        end
        changed, config.enableInstantQuit = imgui.checkbox("Enable instant skip carve timer in multiplay", config.enableInstantQuit);
        if changed == true and reqSave ~= true then
            reqSave = true;
        end
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("End quest immediately without waiting for other players in multiplay.");
        end
        changed, config.skipEndScene = imgui.checkbox("Enable skip quest end scene", config.skipEndScene);
        if changed == true and reqSave ~= true then
            reqSave = true;
        end
		if reqSave == true then
			saveConfig();
		end
		imgui.tree_pop();
	end
end);