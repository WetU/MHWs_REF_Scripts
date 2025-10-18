local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local getObject = Constants.getObject;

local GUI020600_type_def = sdk.find_type_definition("app.GUI020600");

local get_Item_method = Constants.UserSaveParam_type_def:get_method("get_Item");

local get_ShortcutPallet_method = get_Item_method:get_return_type():get_method("get_ShortcutPallet");

local ShortcutPalletParam_type_def = get_ShortcutPallet_method:get_return_type();
local setCurrentIndex_method = ShortcutPalletParam_type_def:get_method("setCurrentIndex(app.ItemDef.PALLET_TYPE, System.Int32)");
local getCurrentIndex_method = ShortcutPalletParam_type_def:get_method("getCurrentIndex(app.ItemDef.PALLET_TYPE)");

local PC = sdk.find_type_definition("app.ItemDef.PALLET_TYPE"):get_field("PC"):get_data(nil); -- static

sdk.hook(GUI020600_type_def:get_method("execute(System.Int32)"), getObject, function()
	thread.get_hook_storage()["this"]:write_float(0x344, 0.5);
end);

local ShortcutPalletParam = nil;
sdk.hook(GUI020600_type_def:get_method("onHudClose"), nil, function()
	if ShortcutPalletParam == nil then
		ShortcutPalletParam = get_ShortcutPallet_method:call(get_Item_method:call(Constants.UserSaveData));
	end
	if getCurrentIndex_method:call(ShortcutPalletParam, PC) ~= 0 then
		setCurrentIndex_method:call(ShortcutPalletParam, PC, 0);
	end
end);