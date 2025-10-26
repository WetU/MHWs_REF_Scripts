local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI020600_type_def = sdk.find_type_definition("app.GUI020600");

local ShortcutPalletParam_type_def = Constants.ShortcutPalletParam_type_def;
local setCurrentIndex_method = ShortcutPalletParam_type_def:get_method("setCurrentIndex(app.ItemDef.PALLET_TYPE, System.Int32)");
local getCurrentIndex_method = ShortcutPalletParam_type_def:get_method("getCurrentIndex(app.ItemDef.PALLET_TYPE)");

local PC = sdk.find_type_definition("app.ItemDef.PALLET_TYPE"):get_field("PC"):get_data(nil); -- static

sdk.hook(GUI020600_type_def:get_method("execute(System.Int32)"), Constants.getObject, function()
	thread.get_hook_storage()["this"]:write_float(0x344, 0.5);
end);

sdk.hook(GUI020600_type_def:get_method("onHudClose"), nil, function()
	local ShortcutPalletParam = Constants.ShortcutPalletParam;
	if getCurrentIndex_method:call(ShortcutPalletParam, PC) ~= 0 then
		setCurrentIndex_method:call(ShortcutPalletParam, PC, 0);
	end
end);