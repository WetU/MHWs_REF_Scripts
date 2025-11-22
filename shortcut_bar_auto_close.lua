local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI020600_type_def = sdk.find_type_definition("app.GUI020600");

sdk.hook(GUI020600_type_def:get_method("execute(System.Int32)"), Constants.getObject, function()
	thread.get_hook_storage()["this"]:write_float(0x344, 0.5);
end);