local Constants = _G.require("Constants/Constants");

local hook = Constants.hook;
local find_type_definition = Constants.find_type_definition;

local get_hook_storage = Constants.get_hook_storage;

local getObject = Constants.getObject;

local get_UpTimeSecond_method = find_type_definition("via.Application"):get_method("get_UpTimeSecond"); -- static

local ShortcutPalletParam = Constants.ShortcutPalletParam;
local ShortcutPalletParam_type_def = ShortcutPalletParam:get_type_definition();
local setCurrentIndex_method = ShortcutPalletParam_type_def:get_method("setCurrentIndex(app.ItemDef.PALLET_TYPE, System.Int32)");
local getCurrentIndex_method = ShortcutPalletParam_type_def:get_method("getCurrentIndex(app.ItemDef.PALLET_TYPE)");

local PC = find_type_definition("app.ItemDef.PALLET_TYPE"):get_field("PC"):get_data(nil); -- static

local GUI020600_type_def = find_type_definition("app.GUI020600");

local lastClosedTime = nil;

hook(GUI020600_type_def:get_method("onHudOpen"), function()
	if lastClosedTime ~= nil and (get_UpTimeSecond_method:call(nil) - lastClosedTime) >= 5.0 then
		if getCurrentIndex_method:call(ShortcutPalletParam, PC) ~= 0 then
			setCurrentIndex_method:call(ShortcutPalletParam, PC, 0);
		end
		lastClosedTime = nil;
	end
end);

hook(GUI020600_type_def:get_method("execute(System.Int32)"), getObject, function()
	get_hook_storage().this:write_float(0x344, 0.2);
end);

hook(GUI020600_type_def:get_method("onHudClose"), nil, function()
	lastClosedTime = get_UpTimeSecond_method:call(nil);
end);