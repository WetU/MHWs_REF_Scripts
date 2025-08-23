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

Constants.FALSE_ptr = Constants.sdk.to_ptr(false);

Constants.ActiveQuestData_type_def = Constants.sdk.find_type_definition("app.cActiveQuestData");
Constants.GUIAppOnTimerKey_type_def = Constants.sdk.find_type_definition("app.cGUIAppOnTimerKey");
Constants.GUIManager_type_def = Constants.sdk.find_type_definition("app.GUIManager");
Constants.ItemUtil_type_def = Constants.sdk.find_type_definition("app.ItemUtil");
Constants.QuestDirector_type_def = Constants.sdk.find_type_definition("app.cQuestDirector");

Constants.GUIAppOnTimerKey_onUpdate_method = Constants.GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)");
Constants.GUIAppKey_Type_field = Constants.GUIAppOnTimerKey_type_def:get_field("_Type");

Constants.GUIFunc_TYPE_type_def = Constants.GUIAppKey_Type_field:get_type();

Constants.getObject = function(args)
    Constants.thread.get_hook_storage()["this"] = Constants.sdk.to_managed_object(args[2]);
end

Constants.init = function()
    Constants.ChatManager = Constants.sdk.get_managed_singleton("app.ChatManager");
    Constants.FacilityManager = Constants.sdk.get_managed_singleton("app.FacilityManager");
    Constants.GUIManager = Constants.sdk.get_managed_singleton("app.GUIManager");
    Constants.SaveDataManager = Constants.sdk.get_managed_singleton("app.SaveDataManager");
end

local GameFlowManager = sdk.get_managed_singleton("app.GameFlowManager");
local GameFlowManager_type_def = GameFlowManager:get_type_definition();
local get_CurrentGameStateType_method = GameFlowManager_type_def:get_method("get_CurrentGameStateType");
local getStateName_method = GameFlowManager_type_def:get_method("getStateName(ace.GameStateType)");

if getStateName_method:call(GameFlowManager, get_CurrentGameStateType_method:call(GameFlowManager)) == "IngameState" then
    Constants.init();
end

return Constants;