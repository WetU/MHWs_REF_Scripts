local _G = _G;

local ipairs = _G.ipairs;

local string = _G.string;
local strmatch = string.match;

local math = _G.math;

local sdk = _G.sdk;
local call_object_func = sdk.call_object_func;
local hook = sdk.hook;
local find_type_definition = sdk.find_type_definition;
local to_managed_object = sdk.to_managed_object;
local float_to_ptr = sdk.float_to_ptr;

local get_hook_storage = _G.thread.get_hook_storage;

local imgui = _G.imgui;
local json = _G.json;
local re = _G.re;

local GA_type_def = find_type_definition("app.GA");
local get_Chat_method = GA_type_def:get_method("get_Chat");
local get_GUI_method = GA_type_def:get_method("get_GUI");
local get_Save_method = GA_type_def:get_method("get_Save");

local getCurrentUserSaveData_method = get_Save_method:get_return_type():get_method("getCurrentUserSaveData");

local UserSaveParam_type_def = getCurrentUserSaveData_method:get_return_type();
local get_Item_method = UserSaveParam_type_def:get_method("get_Item");

local get_ShortcutPallet_method = get_Item_method:get_return_type():get_method("get_ShortcutPallet");

local get_Chara_method = find_type_definition("app.cHunterActionBase"):get_method("get_Chara");

local HunterCharacter_type_def = get_Chara_method:get_return_type();

local GenericList_type_def = find_type_definition("System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>");

local GUI070000_type_def = find_type_definition("app.GUI070000");
local GUIBaseApp_type_def = GUI070000_type_def:get_parent_type();
local GUIBase_type_def = GUIBaseApp_type_def:get_parent_type();

local PlayObject_type_def = find_type_definition("via.gui.PlayObject");

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
    call_object_func = call_object_func,
    create_int32 = sdk.create_int32,
    to_float = sdk.to_float,
    to_ptr = sdk.to_ptr,
    to_int64 = sdk.to_int64,
    float_to_ptr = float_to_ptr,
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

    ZERO_float_ptr = float_to_ptr(0.0),

    STAGES = {},

    ChatManager = nil,
    GUIManager = nil,
    UserSaveData = nil,
    ShortcutPalletParam = nil,

    GUI070000_type_def = GUI070000_type_def,
    GUIID_type_def = find_type_definition("app.GUIID.ID"),
    GUIFunc_TYPE_type_def = find_type_definition("app.GUIFunc.TYPE"),
    GUIManager_type_def = get_GUI_method:get_return_type(),
    HunterCharacter_type_def = HunterCharacter_type_def,
    ItemUtil_type_def = find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = find_type_definition("app.cQuestDirector"),
    ShortcutPalletParam_type_def = get_ShortcutPallet_method:get_return_type(),
    UserSaveParam_type_def = UserSaveParam_type_def,

    addSystemLog_method = get_Chat_method:get_return_type():get_method("addSystemLog(System.String)"),
    get_ActualVisible_method = PlayObject_type_def:get_method("get_ActualVisible"),
    get_Chara_method = get_Chara_method,
    get_Component_method = PlayObject_type_def:get_method("get_Component"),
    get_CurCtrlInputPriority_method = GUIBase_type_def:get_method("get_CurCtrlInputPriority"),
    get_Facility_method = GA_type_def:get_method("get_Facility"),
    get_IDInt_method = GUIBase_type_def:get_method("get_IDInt"),
    get_IsMaster_method = HunterCharacter_type_def:get_method("get_IsMaster"),
    get_Network_method = GA_type_def:get_method("get_Network"),
    get_PlParam_method = GA_type_def:get_method("get_PlParam"),
    get_VariousData_method = GA_type_def:get_method("get_VariousData"),
    GenericList_get_Count_method = GenericList_type_def:get_method("get_Count"),
    GenericList_get_Item_method = GenericList_type_def:get_method("get_Item(System.Int32)"),
    GenericList_set_Item_method = GenericList_type_def:get_method("set_Item"),
    GenericList_Clear_method = GenericList_type_def:get_method("Clear"),
    GenericList_RemoveAt_method = GenericList_type_def:get_method("RemoveAt(System.Int32)"),
    isInput_method = GUIBaseApp_type_def:get_method("isInput(app.GUIFunc.TYPE)"),
    requestCallTrigger_method = find_type_definition("ace.cGUIInputCtrl`2<app.GUIID.ID,app.GUIFunc.TYPE>"):get_method("requestCallTrigger(app.GUIFunc.TYPE)"),
    requestClose_method = GUIBase_type_def:get_method("requestClose(System.Boolean)"),

    getThisPtr = function(args)
        get_hook_storage().this_ptr = args[2];
    end,

    getObject = function(args)
        get_hook_storage().this = to_managed_object(args[2]);
    end,

    getMethod = function(methods, name, isCallback)
        if isCallback then
            for _, v in ipairs(methods) do
                if strmatch(v:get_name(), "^<" .. name .. ">.*$") ~= nil then
                    return v;
                end
            end
        else
            for _, v in ipairs(methods) do
                if v:get_name() == name then
                    return v;
                end
            end
        end
        return nil;
    end
};

for _, v in ipairs(find_type_definition("app.FieldDef.STAGE"):get_fields()) do
    if v:is_static() then
        local name = v:get_name();
        if name ~= "INVALID" and name ~= "MAX" then
            Constants.STAGES[name] = v:get_data(nil);
        end
    end
end

local isInitialized = false;
Constants.init = function()
    if not isInitialized then
        isInitialized = true;
        Constants.ChatManager = get_Chat_method:call(nil);
        Constants.GUIManager = get_GUI_method:call(nil);
        local SaveDataManager = get_Save_method:call(nil);
        if SaveDataManager ~= nil then
            local UserSaveData = getCurrentUserSaveData_method:call(SaveDataManager);
            if UserSaveData ~= nil then
                Constants.UserSaveData = UserSaveData;
                Constants.ShortcutPalletParam = get_ShortcutPallet_method:call(get_Item_method:call(UserSaveData));
            end
        end
    end
end

hook(find_type_definition("app.TitleState"):get_method("enter"), nil, function()
    if isInitialized then
        isInitialized = false;
        Constants.ChatManager = nil;
        Constants.GUIManager = nil;
        Constants.UserSaveData = nil;
        Constants.ShortcutPalletParam = nil;
    end
end);

local GameFlowManager = GA_type_def:get_method("get_GameFlow"):call(nil);
if GameFlowManager ~= nil then
    if call_object_func(GameFlowManager, "getStateName(ace.GameStateType)", call_object_func(GameFlowManager, "get_CurrentGameStateType")) == "IngameState" then
        Constants.init();
    end
    GameFlowManager = nil;
end

return Constants;