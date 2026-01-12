local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;

local hook = Constants.hook;
local find_type_definition = Constants.find_type_definition;
local set_native_field = Constants.set_native_field;

local get_hook_storage = Constants.get_hook_storage;

local getObject = Constants.getObject;
local getThisPtr = Constants.getThisPtr;

local GUI010001_type_def = find_type_definition("app.GUI010001");
local Flow_field = GUI010001_type_def:get_field("_Flow");
local Skip_field = GUI010001_type_def:get_field("_Skip");
local EnableSkip_field = GUI010001_type_def:get_field("_EnableSkip");

local lastFlow = nil;
for _, v in ipairs(Flow_field:get_type():get_fields()) do
    if v:is_static() then
        local enum_value = v:get_data(nil);
        if lastFlow == nil or enum_value > lastFlow then
            lastFlow = enum_value;
        end
    end
end

local GUI010100_type_def = find_type_definition("app.GUI010100");
local Input_field = GUI010100_type_def:get_field("_Input");

local BUTTON = find_type_definition("app.GUI010100.RNO"):get_field("BUTTON"):get_data(nil); -- static

local requestCallTrigger_method = Constants.requestCallTrigger_method;

local TITLE_START = Constants.GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil);

hook(GUI010001_type_def:get_method("guiVisibleUpdate"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    if Flow_field:get_data(this_ptr) < lastFlow then
        set_native_field(this_ptr, GUI010001_type_def, "_Flow", lastFlow);
    end
    if EnableSkip_field:get_data(this_ptr) and Skip_field:get_data(this_ptr) == false then
        set_native_field(this_ptr, GUI010001_type_def, "_Skip", true);
    end
end);

hook(find_type_definition("app.GUI010002"):get_method("onOpen"), getObject, function()
    local this = get_hook_storage().this;
    this:write_float(0x220, this:read_float(0x224));
end);

hook(GUI010100_type_def:get_method("onOpen"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    set_native_field(this_ptr, GUI010100_type_def, "_Rno", BUTTON);
    requestCallTrigger_method:call(Input_field:get_data(this_ptr), TITLE_START);
end);