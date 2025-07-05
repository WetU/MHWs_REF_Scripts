local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

sdk.hook(sdk.find_type_definition("app.GUI020600"):get_method("execute(System.Int32)"), Constants.getObject, function()
	thread.get_hook_storage()["this"]:write_float(0x344, 0.5);
end);