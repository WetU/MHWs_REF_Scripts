local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;

local isPickup = false;

sdk.hook(Constants.ItemUtil_type_def:get_method("pickupItem(app.ItemDef.ID, System.Int16, app.EnemyDef.ID, app.ItemDef.LOG_TYPE)"), function(args)
	isPickup = true;
end, function(retval)
	isPickup = false;
	return Constants.FALSE_ptr;
end);

sdk.hook(Constants.ItemUtil_type_def:get_method("<pickupItem>g__isReplaceItem|15_0(app.ItemUtil.<>c__DisplayClass15_0)"), nil, function(retval)
	return isPickup == true and Constants.FALSE_ptr or retval;
end);