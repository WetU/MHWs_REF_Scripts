local Constants = _G.require("Constants/Constants");

local get_hook_storage = Constants.get_hook_storage;

Constants.hook(Constants.find_type_definition("app.GUI020600"):get_method("execute(System.Int32)"), Constants.getObject, function()
	get_hook_storage().this:write_float(0x344, 0.5);
end);