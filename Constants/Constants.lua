local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");
local Type_field = GUIAppOnTimerKey_type_def:get_field("_Type");

local Constants = {
    pairs = _G.pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    type = _G.type,
    math = _G.math,
    string = _G.string,
    table = _G.table,

    sdk = sdk,
    re = _G.re,
    thread = thread,
    json = _G.json,
    imgui = _G.imgui,
    draw = _G.draw,

    ChatManager = nil,
    FacilityManager = nil,
    GUIManager = nil,
    SaveDataManager = nil,

    ActiveQuestData_type_def = sdk.find_type_definition("app.cActiveQuestData"),
    GUIAppOnTimerKey_type_def = GUIAppOnTimerKey_type_def,
    GUIFunc_TYPE_type_def = Type_field:get_type(),
    GUIManager_type_def = sdk.find_type_definition("app.GUIManager"),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    GUIAppOnTimerKey_onUpdate_method = GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)"),
    GUIAppKey_Type_field = Type_field,

    getThisPtr = function(args)
        thread.get_hook_storage()["this_ptr"] = args[2];
    end,

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
};

sdk.hook(sdk.find_type_definition("app.TitleState"):get_method("enter"), function(args)
    Constants.ChatManager = nil;
    Constants.FacilityManager = nil;
    Constants.GUIManager = nil;
    Constants.SaveDataManager = nil;
end);

Constants.init = function()
    Constants.ChatManager = sdk.get_managed_singleton("app.ChatManager");
    Constants.FacilityManager = sdk.get_managed_singleton("app.FacilityManager");
    Constants.GUIManager = sdk.get_managed_singleton("app.GUIManager");
    Constants.SaveDataManager = sdk.get_managed_singleton("app.SaveDataManager");
end

local GameFlowManager = sdk.get_managed_singleton("app.GameFlowManager");
if GameFlowManager:call("getStateName(ace.GameStateType)", GameFlowManager:get_CurrentGameStateType()) == "IngameState" then
    Constants.init();
end
GameFlowManager = nil;

return Constants;