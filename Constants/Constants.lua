local _G = _G;

local type = _G.type;
local pairs = _G.pairs;
local string = _G.string;

local sdk = _G.sdk;
local thread = _G.thread;

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");
local Type_field = GUIAppOnTimerKey_type_def:get_field("_Type");

local GenericList_type_def = sdk.find_type_definition("System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>");

local Constants = {
    pairs = pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    tonumber = _G.tonumber,
    type = type,
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
    GUIAppOnTimerKey_type_def = GUIAppOnTimerKey_type_def,
    GUIFunc_TYPE_type_def = Type_field:get_type(),
    GUIManager_type_def = sdk.find_type_definition("app.GUIManager"),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    addSystemLog_method = sdk.find_type_definition("app.ChatManager"):get_method("addSystemLog(System.String)"),
    GenericList_get_Count_method = GenericList_type_def:get_method("get_Count"), -- 1437D2EC0
    GenericList_get_Item_method = GenericList_type_def:get_method("get_Item(System.Int32)"), -- 1437D2ED0
    GenericList_set_Item_method = GenericList_type_def:get_method("set_Item"), -- 144F88680
    GenericList_Clear_method = GenericList_type_def:get_method("Clear"),
    GenericList_RemoveAt_method = GenericList_type_def:get_method("RemoveAt(System.Int32)"), -- 144F88710
    GUIAppOnTimerKey_onUpdate_method = GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)"),

    GUIAppKey_Type_field = Type_field,

    getThisPtr = function(args)
        thread.get_hook_storage()["this_ptr"] = args[2];
    end,

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end,

    getCallbackMethod = function(methods, name)
        if methods ~= nil and name ~= nil and type(name) == "string" then
            for _, v in pairs(methods) do
                if string.match(v:get_name(), "^<" .. name .. ">.*") ~= nil then
                    return v;
                end
            end
        end
        return nil;
    end
};

Constants.init = function()
    Constants.ChatManager = sdk.get_managed_singleton("app.ChatManager");
    Constants.FacilityManager = sdk.get_managed_singleton("app.FacilityManager");
    Constants.GUIManager = sdk.get_managed_singleton("app.GUIManager");
    local SaveDataManager = sdk.get_managed_singleton("app.SaveDataManager");
    Constants.UserSaveData = SaveDataManager:get_type_definition():get_method("getCurrentUserSaveData"):call(SaveDataManager);
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
    GameFlowManager = nil;
end

return Constants;