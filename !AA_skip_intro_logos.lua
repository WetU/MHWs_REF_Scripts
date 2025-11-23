local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI010001_type_def = sdk.find_type_definition("app.GUI010001");

sdk.hook(GUI010001_type_def:get_method("onOpen"), Constants.getThisPtr, function()
    local GUI010001_ptr = thread.get_hook_storage()["this_ptr"];
    sdk.set_native_field(GUI010001_ptr, GUI010001_type_def, "_Flow", 5);
    sdk.set_native_field(GUI010001_ptr, GUI010001_type_def, "_Skip", true);
end);

sdk.hook(sdk.find_type_definition("app.GUI010002"):get_method("onOpen"), Constants.getObject, function()
    local GUI010002 = thread.get_hook_storage()["this"];
    GUI010002:write_float(0x220, GUI010002:read_float(0x224));
end);