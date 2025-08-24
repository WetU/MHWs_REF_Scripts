local _G = _G;

local Constants = {
    pairs = _G.pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    type = _G.type,
    math = _G.math,
    string = _G.string,
    table = _G.table,

    sdk = _G.sdk,
    re = _G.re,
    thread = _G.thread,
    json = _G.json,
    imgui = _G.imgui,
    draw = _G.draw
};

Constants.ActiveQuestData_type_def = Constants.sdk.find_type_definition("app.cActiveQuestData");
Constants.GUIAppOnTimerKey_type_def = Constants.sdk.find_type_definition("app.cGUIAppOnTimerKey");
Constants.GUIManager_type_def = Constants.sdk.find_type_definition("app.GUIManager");
Constants.ItemUtil_type_def = Constants.sdk.find_type_definition("app.ItemUtil");
Constants.QuestDirector_type_def = Constants.sdk.find_type_definition("app.cQuestDirector");

Constants.GUIAppOnTimerKey_onUpdate_method = Constants.GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)");
Constants.GUIAppKey_Type_field = Constants.GUIAppOnTimerKey_type_def:get_field("_Type");

Constants.GUIFunc_TYPE_type_def = Constants.GUIAppKey_Type_field:get_type();

Constants.getThisPtr = function(args)
    Constants.thread.get_hook_storage()["this_ptr"] = args[2];
end

Constants.getObject = function(args)
    Constants.thread.get_hook_storage()["this"] = Constants.sdk.to_managed_object(args[2]);
end

Constants.init = function()
    Constants.ChatManager = Constants.sdk.get_managed_singleton("app.ChatManager");
    Constants.FacilityManager = Constants.sdk.get_managed_singleton("app.FacilityManager");
    Constants.GUIManager = Constants.sdk.get_managed_singleton("app.GUIManager");
    Constants.SaveDataManager = Constants.sdk.get_managed_singleton("app.SaveDataManager");
end

local function destroy()
    Constants.ChatManager = nil;
    Constants.FacilityManager = nil;
    Constants.GUIManager = nil;
    Constants.SaveDataManager = nil;
end

local GameFlowManager = sdk.get_managed_singleton("app.GameFlowManager");
if GameFlowManager:call("getStateName(ace.GameStateType)", GameFlowManager:get_CurrentGameStateType()) == "IngameState" then
    Constants.init();
end

Constants.sdk.hook(Constants.sdk.find_type_definition("app.TitleState"):get_method("enter"), destroy);

return Constants;