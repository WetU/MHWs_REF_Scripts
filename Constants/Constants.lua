local _G = _G;

local string = _G.string;

local math = _G.math;

local sdk = _G.sdk;
local call_native_func = sdk.call_native_func;
local call_object_func = sdk.call_object_func;
local find_type_definition = sdk.find_type_definition;
local to_managed_object = sdk.to_managed_object;
local float_to_ptr = sdk.float_to_ptr;

local get_hook_storage = _G.thread.get_hook_storage;

local imgui = _G.imgui;

local GA_type_def = find_type_definition("app.GA");
local ChatManager = GA_type_def:get_method("get_Chat"):call(nil);
local GUIManager = GA_type_def:get_method("get_GUI"):call(nil);

local CurrentUserSaveData = call_object_func(GA_type_def:get_method("get_Save"):call(nil), "getCurrentUserSaveData");
local UserSaveParam_type_def = CurrentUserSaveData:get_type_definition();
local ShortcutPalletParam = call_object_func(call_native_func(CurrentUserSaveData, UserSaveParam_type_def, "get_Item"), "get_ShortcutPallet");

local GenericList_type_def = find_type_definition("System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>");

local GUI000002_type_def = find_type_definition("app.GUI000002");
local GUIBaseApp_type_def = GUI000002_type_def:get_parent_type();
local GUIBase_type_def = GUIBaseApp_type_def:get_parent_type();

local requestClose_method = GUIBase_type_def:get_method("requestClose(System.Boolean)");

local InputCtrl_type_def = find_type_definition("ace.cGUIInputCtrl`2<app.GUIID.ID,app.GUIFunc.TYPE>");

local Constants = {
    pairs = _G.pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    tonumber = _G.tonumber,

    strmatch = string.match,
    strformat = string.format,
    strgsub = string.gsub,

    tinsert = _G.table.insert,

    mathmodf = math.modf,
    mathfloor = math.floor,

    hook = sdk.hook,
    find_type_definition = find_type_definition,
    call_native_func = call_native_func,
    call_object_func = call_object_func,
    set_native_field = sdk.set_native_field,
    create_int32 = sdk.create_int32,
    to_ptr = sdk.to_ptr,
    to_int64 = sdk.to_int64,
    to_float = sdk.to_float,
    SKIP_ORIGINAL = sdk.PreHookResult.SKIP_ORIGINAL,

    get_hook_storage = get_hook_storage,

    on_frame = _G.re.on_frame,

    load_font = imgui.load_font,
    push_font = imgui.push_font,
    pop_font = imgui.pop_font,

    drawtext = _G.draw.text,

    ZERO_float_ptr = float_to_ptr(0.0),
    SMALL_float_ptr = float_to_ptr(0.01),

    STAGES = {},

    ChatManager = ChatManager,
    GUIManager = GUIManager,
    UserSaveData = CurrentUserSaveData,
    ShortcutPalletParam = ShortcutPalletParam,

    FacilitySupplyItems_type_def = find_type_definition("app.FacilitySupplyItems"),
    GUI000002_type_def = GUI000002_type_def,
    GUIID_type_def = find_type_definition("app.GUIID.ID"),
    GUIFunc_TYPE_type_def = find_type_definition("app.GUIFunc.TYPE"),
    GUIManager_type_def = GUIManager:get_type_definition(),
    ItemUtil_type_def = find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = find_type_definition("app.cQuestDirector"),
    ShortcutPalletParam_type_def = ShortcutPalletParam:get_type_definition(),
    UserSaveParam_type_def = UserSaveParam_type_def,

    addSystemLog_method = ChatManager:get_type_definition():get_method("addSystemLog(System.String)"),
    get_ActualVisible_method = find_type_definition("via.gui.PlayObject"):get_method("get_ActualVisible"),
    get_Facility_method = GA_type_def:get_method("get_Facility"),
    get_IDInt_method = GUIBase_type_def:get_method("get_IDInt"),
    get_InputPriority_method = InputCtrl_type_def:get_method("get_InputPriority"),
    get_PlParam_method = GA_type_def:get_method("get_PlParam"),
    get_VariousData_method = GA_type_def:get_method("get_VariousData"),
    GenericList_get_Count_method = GenericList_type_def:get_method("get_Count"),
    GenericList_get_Item_method = GenericList_type_def:get_method("get_Item(System.Int32)"),
    GenericList_set_Item_method = GenericList_type_def:get_method("set_Item"),
    GenericList_Clear_method = GenericList_type_def:get_method("Clear"),
    GenericList_RemoveAt_method = GenericList_type_def:get_method("RemoveAt(System.Int32)"),
    isInput_method = GUIBaseApp_type_def:get_method("isInput(app.GUIFunc.TYPE)"),
    requestCallTrigger_method = InputCtrl_type_def:get_method("requestCallTrigger(app.GUIFunc.TYPE)"),

    getThisPtr = function(args)
        get_hook_storage().this_ptr = args[2];
    end,

    getObject = function(args)
        get_hook_storage().this = to_managed_object(args[2]);
    end,

    requestClose = function()
        requestClose_method:call(get_hook_storage().this_ptr, true);
    end
};

do
    for _, v in Constants.ipairs(find_type_definition("app.FieldDef.STAGE"):get_fields()) do
        if v:is_static() then
            local name = v:get_name();
            if name ~= "INVALID" and name ~= "MAX" then
                Constants.STAGES[name] = v:get_data(nil);
            end
        end
    end
end

return Constants;