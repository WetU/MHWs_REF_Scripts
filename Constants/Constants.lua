local _G = _G;

local pairs = _G.pairs;
local string = _G.string;

local sdk = _G.sdk;
local thread = _G.thread;

local GA_type_def = sdk.find_type_definition("app.GA");
local get_Chat_method = GA_type_def:get_method("get_Chat"); -- static
local get_GameFlow_method = GA_type_def:get_method("get_GameFlow"); -- static
local get_GUI_method = GA_type_def:get_method("get_GUI"); -- static
local get_Save_method = GA_type_def:get_method("get_Save"); -- static
local get_Pl_method = GA_type_def:get_method("get_Pl"); -- static

local GameFlowManager_type_def = get_GameFlow_method:get_return_type();
local getStateName_method = GameFlowManager_type_def:get_method("getStateName(ace.GameStateType)");
local get_CurrentGameStateType_method = GameFlowManager_type_def:get_method("get_CurrentGameStateType");

local getCurrentUserSaveData_method = get_Save_method:get_return_type():get_method("getCurrentUserSaveData");

local UserSaveParam_type_def = getCurrentUserSaveData_method:get_return_type();
local get_Item_method = UserSaveParam_type_def:get_method("get_Item");
local get_Pugee_method = UserSaveParam_type_def:get_method("get_Pugee");

local get_ShortcutPallet_method = get_Item_method:get_return_type():get_method("get_ShortcutPallet");

local getMasterPlayer_method = get_Pl_method:get_return_type():get_method("getMasterPlayer");

local get_Character_method = getMasterPlayer_method:get_return_type():get_method("get_Character");

local GenericList_type_def = sdk.find_type_definition("System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>");

local Constants = {
    pairs = pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    tonumber = _G.tonumber,
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
    GUIManager = nil,
    UserSaveData = nil,
    PugeeParam = nil,
    ShortcutPalletParam = nil,
    HunterCharacter = nil,

    ActiveQuestData_type_def = sdk.find_type_definition("app.cActiveQuestData"),
    GUIID_type_def = sdk.find_type_definition("app.GUIID.ID"),
    GUIManager_type_def = get_GUI_method:get_return_type(),
    HunterCharacter_type_def = get_Character_method:get_return_type(),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    PugeeParam_type_def  = get_Pugee_method:get_return_type(),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),
    ShortcutPalletParam_type_def = get_ShortcutPallet_method:get_return_type(),
    UserSaveParam_type_def = UserSaveParam_type_def,

    addSystemLog_method = get_Chat_method:get_return_type():get_method("addSystemLog(System.String)"),
    get_Facility_method = GA_type_def:get_method("get_Facility"),
    get_Various_method = GA_type_def:get_method("get_Various"),
    GenericList_get_Count_method = GenericList_type_def:get_method("get_Count"),
    GenericList_get_Item_method = GenericList_type_def:get_method("get_Item(System.Int32)"),
    GenericList_set_Item_method = GenericList_type_def:get_method("set_Item"),
    GenericList_Clear_method = GenericList_type_def:get_method("Clear"),
    GenericList_RemoveAt_method = GenericList_type_def:get_method("RemoveAt(System.Int32)"),

    getThisPtr = function(args)
        thread.get_hook_storage()["this_ptr"] = args[2];
    end,

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end,

    getCallbackMethod = function(methods, name)
        for _, v in pairs(methods) do
            if string.match(v:get_name(), "^<" .. name .. ">.*$") ~= nil then
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
        Constants.ChatManager = get_Chat_method:call(nil);
        Constants.GUIManager = get_GUI_method:call(nil);
        local SaveDataManager = get_Save_method:call(nil);
        if SaveDataManager ~= nil then
            local UserSaveData = getCurrentUserSaveData_method:call(SaveDataManager);
            if UserSaveData ~= nil then
                Constants.UserSaveData = UserSaveData;
                Constants.PugeeParam = get_Pugee_method:call(UserSaveData);
                Constants.ShortcutPalletParam = get_ShortcutPallet_method:call(get_Item_method:call(UserSaveData));
            end
        end
        local PlayerManager = get_Pl_method:call(nil);
        if PlayerManager ~= nil then
            local MasterPlayer = getMasterPlayer_method:call(PlayerManager);
            if MasterPlayer ~= nil then
                Constants.HunterCharacter = get_Character_method:call(MasterPlayer);
            end
        end
    end
end

sdk.hook(sdk.find_type_definition("app.TitleState"):get_method("enter"), nil, function()
    if isInitialized == true then
        isInitialized = false;
        Constants.ChatManager = nil;
        Constants.GUIManager = nil;
        Constants.UserSaveData = nil;
        Constants.PugeeParam = nil;
        Constants.ShortcutPalletParam = nil;
        Constants.HunterCharacter = nil;
    end
end);

local GameFlowManager = get_GameFlow_method:call(nil);
if GameFlowManager ~= nil then
    if getStateName_method:call(GameFlowManager, get_CurrentGameStateType_method:call(GameFlowManager)) == "IngameState" then
        Constants.init();
    end
    GameFlowManager = nil;
end

return Constants;