local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");
local Type_field = GUIAppOnTimerKey_type_def:get_field("_Type");

local getCurrentUserSaveData_method = sdk.find_type_definition("app.SaveDataManager"):get_method("getCurrentUserSaveData");

local SupportShipData_List_type_def = sdk.find_type_definition("System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>");

local Constants = {
    pairs = _G.pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    tonumber = _G.tonumber,
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
    UserSaveData = nil,

    ActiveQuestData_type_def = sdk.find_type_definition("app.cActiveQuestData"),
    GUIAppOnTimerKey_type_def = GUIAppOnTimerKey_type_def,
    GUIFunc_TYPE_type_def = Type_field:get_type(),
    GUIManager_type_def = sdk.find_type_definition("app.GUIManager"),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),
    SupportShipData_List_type_def = SupportShipData_List_type_def,

    addSystemLog_method = sdk.find_type_definition("app.ChatManager"):get_method("addSystemLog(System.String)"),
    GenericList_get_Count_method = SupportShipData_List_type_def:get_method("get_Count"),
    GUIAppOnTimerKey_onUpdate_method = GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)"),

    GUIAppKey_Type_field = Type_field,

    getThisPtr = function(args)
        thread.get_hook_storage()["this_ptr"] = args[2];
    end,

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
};

Constants.init = function()
    Constants.ChatManager = sdk.get_managed_singleton("app.ChatManager");
    Constants.FacilityManager = sdk.get_managed_singleton("app.FacilityManager");
    Constants.GUIManager = sdk.get_managed_singleton("app.GUIManager");
    Constants.UserSaveData = getCurrentUserSaveData_method:call(sdk.get_managed_singleton("app.SaveDataManager"));
end

sdk.hook(sdk.find_type_definition("app.TitleState"):get_method("enter"), function(args)
    Constants.ChatManager = nil;
    Constants.FacilityManager = nil;
    Constants.GUIManager = nil;
    Constants.UserSaveData = nil;
end);

local GameFlowManager = sdk.get_managed_singleton("app.GameFlowManager");
if GameFlowManager ~= nil then
    local GameFlowManager_type_def = GameFlowManager:get_type_definition();
    if GameFlowManager_type_def:get_method("getStateName(ace.GameStateType)"):call(GameFlowManager, GameFlowManager_type_def:get_method("get_CurrentGameStateType"):call(GameFlowManager)) == "IngameState" then
        Constants.init();
    end
end
GameFlowManager = nil;

return Constants;