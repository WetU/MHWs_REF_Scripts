local _G = _G;

local pairs = _G.pairs;
local string = _G.string;

local sdk = _G.sdk;
local thread = _G.thread;

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");
local GUIAppKey_type_def = GUIAppOnTimerKey_type_def:get_parent_type();
local Type_field = GUIAppKey_type_def:get_field("_Type");

local GenericList_type_def = sdk.find_type_definition("System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>");

local getCurrentUserSaveData_method = sdk.find_type_definition("app.SaveDataManager"):get_method("getCurrentUserSaveData");

local Constants = {
    pairs = pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    tonumber = _G.tonumber,
    type = _G.type,
    math = _G.math,
    string = string,
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
    GUIAppKey_type_def = GUIAppKey_type_def,
    GUIAppOnTimerKey_type_def = GUIAppOnTimerKey_type_def,
    GUIFunc_TYPE_type_def = Type_field:get_type(),
    GUIID_type_def = sdk.find_type_definition("app.GUIID.ID"),
    GUIManager_type_def = sdk.find_type_definition("app.GUIManager"),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),
    UserSaveParam_type_def = getCurrentUserSaveData_method:get_return_type(),

    addSystemLog_method = sdk.find_type_definition("app.ChatManager"):get_method("addSystemLog(System.String)"),
    GenericList_get_Count_method = GenericList_type_def:get_method("get_Count"),
    GenericList_get_Item_method = GenericList_type_def:get_method("get_Item(System.Int32)"),
    GenericList_set_Item_method = GenericList_type_def:get_method("set_Item"),
    GenericList_Clear_method = GenericList_type_def:get_method("Clear"),
    GenericList_RemoveAt_method = GenericList_type_def:get_method("RemoveAt(System.Int32)"),

    GUIAppKey_Type_field = Type_field,

    getThisPtr = function(args)
        thread.get_hook_storage()["this_ptr"] = args[2];
    end,

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end,

    getCallbackMethod = function(methods, name)
        for _, v in pairs(methods) do
            if string.match(v:get_name(), "^<" .. name .. ">.*") ~= nil then
                return v;
            end
        end
        return nil;
    end
};

local isInitialized = false;
Constants.init = function()
    if isInitialized == false then
        isInitialized = true;
        Constants.ChatManager = sdk.get_managed_singleton("app.ChatManager");
        Constants.FacilityManager = sdk.get_managed_singleton("app.FacilityManager");
        Constants.GUIManager = sdk.get_managed_singleton("app.GUIManager");
        Constants.UserSaveData = getCurrentUserSaveData_method:call(sdk.get_managed_singleton("app.SaveDataManager"));
    end
end

sdk.hook(sdk.find_type_definition("app.TitleState"):get_method("enter"), nil, function()
    if isInitialized == true then
        isInitialized = false;
        Constants.ChatManager = nil;
        Constants.FacilityManager = nil;
        Constants.GUIManager = nil;
        Constants.UserSaveData = nil;
    end
end);

local GameFlowManager = sdk.get_managed_singleton("app.GameFlowManager");
if GameFlowManager ~= nil then
    local GameFlowManager_type_def = GameFlowManager:get_type_definition();
    if GameFlowManager_type_def:get_method("getStateName(ace.GameStateType)"):call(GameFlowManager, GameFlowManager_type_def:get_method("get_CurrentGameStateType"):call(GameFlowManager)) == "IngameState" then
        Constants.init();
    end
    GameFlowManager = nil;
end

return Constants;