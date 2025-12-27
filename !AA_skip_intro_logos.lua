local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local GUI010001_type_def = sdk.find_type_definition("app.GUI010001");

local GUI010100_type_def = sdk.find_type_definition("app.GUI010100");
local Input_field = GUI010100_type_def:get_field("_Input");

local requestCallTrigger_method = Constants.requestCallTrigger_method;

local TITLE_START = Constants.GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil);

sdk.hook(GUI010001_type_def:get_method("guiVisibleUpdate"), getThisPtr, function()
    local GUI010001_ptr = thread.get_hook_storage()["this_ptr"];
    sdk.set_native_field(GUI010001_ptr, GUI010001_type_def, "_Flow", 5);
    sdk.set_native_field(GUI010001_ptr, GUI010001_type_def, "_Skip", true);
end);

sdk.hook(sdk.find_type_definition("app.GUI010002"):get_method("onOpen"), Constants.getObject, function()
    local GUI010002 = thread.get_hook_storage()["this"];
    GUI010002:write_float(0x220, GUI010002:read_float(0x224));
end);

sdk.hook(GUI010100_type_def:get_method("guiVisibleUpdate"), getThisPtr, function()
    requestCallTrigger_method:call(Input_field:get_data(thread.get_hook_storage()["this_ptr"]), TITLE_START);
end);