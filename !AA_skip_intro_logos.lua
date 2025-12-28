local Constants = _G.require("Constants/Constants");

local hook = Constants.hook;
local find_type_definition = Constants.find_type_definition;
local set_native_field = Constants.set_native_field;

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local GUI010001_type_def = find_type_definition("app.GUI010001");

local GUI010100_type_def = find_type_definition("app.GUI010100");
local Input_field = GUI010100_type_def:get_field("_Input");

local BUTTON = find_type_definition("app.GUI010100.RNO"):get_field("BUTTON"):get_data(nil); -- static

local requestCallTrigger_method = Constants.requestCallTrigger_method;

local TITLE_START = Constants.GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil);

hook(GUI010001_type_def:get_method("onOpen"), getThisPtr, function()
    local GUI010001_ptr = get_hook_storage().this_ptr;
    set_native_field(GUI010001_ptr, GUI010001_type_def, "_Flow", 5);
    set_native_field(GUI010001_ptr, GUI010001_type_def, "_Skip", true);
end);

hook(find_type_definition("app.GUI010002"):get_method("onOpen"), Constants.getObject, function()
    local GUI010002 = get_hook_storage().this;
    GUI010002:write_float(0x220, GUI010002:read_float(0x224));
end);

hook(GUI010100_type_def:get_method("onOpen"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    set_native_field(this_ptr, GUI010100_type_def, "_Rno", BUTTON);
    requestCallTrigger_method:call(Input_field:get_data(this_ptr), TITLE_START);
end);