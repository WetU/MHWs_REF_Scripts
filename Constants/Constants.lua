local _G = _G;

local ipairs = _G.ipairs;

local string = _G.string;
local strmatch = string.match;

local math = _G.math;

local sdk = _G.sdk;
local hook = sdk.hook;
local find_type_definition = sdk.find_type_definition;
local to_managed_object = sdk.to_managed_object;

local get_hook_storage = _G.thread.get_hook_storage;

local imgui = _G.imgui;
local json = _G.json;
local re = _G.re;

local GA_type_def = find_type_definition("app.GA");
local get_Chat_method = GA_type_def:get_method("get_Chat"); -- static
local get_GameFlow_method = GA_type_def:get_method("get_GameFlow"); -- static
local get_GUI_method = GA_type_def:get_method("get_GUI"); -- static
local get_Save_method = GA_type_def:get_method("get_Save"); -- static
local get_Various_method = GA_type_def:get_method("get_Various"); -- static

local GameFlowManager_type_def = get_GameFlow_method:get_return_type();
local getStateName_method = GameFlowManager_type_def:get_method("getStateName(ace.GameStateType)");
local get_CurrentGameStateType_method = GameFlowManager_type_def:get_method("get_CurrentGameStateType");

local getCurrentUserSaveData_method = get_Save_method:get_return_type():get_method("getCurrentUserSaveData");

local UserSaveParam_type_def = getCurrentUserSaveData_method:get_return_type();
local get_Item_method = UserSaveParam_type_def:get_method("get_Item");
local get_Pugee_method = UserSaveParam_type_def:get_method("get_Pugee");

local get_ShortcutPallet_method = get_Item_method:get_return_type():get_method("get_ShortcutPallet");

local get_Setting_method = get_Various_method:get_return_type():get_method("get_Setting");

local GenericList_type_def = find_type_definition("System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>");

local GUI070000_type_def = find_type_definition("app.GUI070000");

local Constants = {
    pairs = _G.pairs,
    ipairs = ipairs,
    tostring = _G.tostring,
    tonumber = _G.tonumber,

    strmatch = strmatch,
    strformat = string.format,
    strgsub = string.gsub,

    tinsert = _G.table.insert,

    mathmodf = math.modf,
    mathfloor = math.floor,

    hook = hook,
    find_type_definition = find_type_definition,
    to_ptr = sdk.to_ptr,
    to_int64 = sdk.to_int64,
    to_valuetype = sdk.to_valuetype,
    float_to_ptr = sdk.float_to_ptr,
    set_native_field = sdk.set_native_field,
    SKIP_ORIGINAL = sdk.PreHookResult.SKIP_ORIGINAL,

    get_hook_storage = get_hook_storage,

    dump_file = json.dump_file,
    load_file = json.load_file,

    on_config_save = re.on_config_save,
    on_script_reset = re.on_script_reset,
    on_frame = re.on_frame,

    load_font = imgui.load_font,
    push_font = imgui.push_font,
    pop_font = imgui.pop_font,

    drawtext = _G.draw.text,

    ChatManager = nil,
    GUIManager = nil,
    UserSaveData = nil,
    PugeeParam = nil,
    ShortcutPalletParam = nil,

    GUI070000_type_def = GUI070000_type_def,
    GUIID_type_def = find_type_definition("app.GUIID.ID"),
    GUIFunc_TYPE_type_def = find_type_definition("app.GUIFunc.TYPE"),
    GUIManager_type_def = get_GUI_method:get_return_type(),
    ItemUtil_type_def = find_type_definition("app.ItemUtil"),
    PugeeParam_type_def  = get_Pugee_method:get_return_type(),
    QuestDirector_type_def = find_type_definition("app.cQuestDirector"),
    ShortcutPalletParam_type_def = get_ShortcutPallet_method:get_return_type(),
    UserSaveParam_type_def = UserSaveParam_type_def,
    VariousDataManagerSetting_type_def = get_Setting_method:get_return_type(),

    addSystemLog_method = get_Chat_method:get_return_type():get_method("addSystemLog(System.String)"),
    get_Facility_method = GA_type_def:get_method("get_Facility"),
    GenericList_get_Count_method = GenericList_type_def:get_method("get_Count"),
    GenericList_get_Item_method = GenericList_type_def:get_method("get_Item(System.Int32)"),
    GenericList_set_Item_method = GenericList_type_def:get_method("set_Item"),
    GenericList_Clear_method = GenericList_type_def:get_method("Clear"),
    GenericList_RemoveAt_method = GenericList_type_def:get_method("RemoveAt(System.Int32)"),
    requestCallTrigger_method = find_type_definition("ace.cGUIInputCtrl`2<app.GUIID.ID,app.GUIFunc.TYPE>"):get_method("requestCallTrigger(app.GUIFunc.TYPE)"),
    requestClose_method = GUI070000_type_def:get_method("requestClose(System.Boolean)"),

    getThisPtr = function(args)
        get_hook_storage().this_ptr = args[2];
    end,

    getObject = function(args)
        get_hook_storage().this = to_managed_object(args[2]);
    end,

    getCallbackMethod = function(methods, name)
        for _, v in ipairs(methods) do
            if strmatch(v:get_name(), "^<" .. name .. ">.*$") ~= nil then
                return v;
            end
        end
        return nil;
    end,

    getVariousDataManagerSetting = function()
        return get_Setting_method:call(get_Various_method:call(nil));
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
    end
end

hook(find_type_definition("app.TitleState"):get_method("enter"), nil, function()
    if isInitialized == true then
        isInitialized = false;
        Constants.ChatManager = nil;
        Constants.GUIManager = nil;
        Constants.UserSaveData = nil;
        Constants.PugeeParam = nil;
        Constants.ShortcutPalletParam = nil;
    end
end);

local GameFlowManager = get_GameFlow_method:call(nil);
if GameFlowManager ~= nil then
    if getStateName_method:call(GameFlowManager, get_CurrentGameStateType_method:call(GameFlowManager)) == "IngameState" then
        Constants.init();
    end
    GameFlowManager = nil;
end
get_GameFlow_method = nil;
getStateName_method = nil;
get_CurrentGameStateType_method = nil;

return Constants;