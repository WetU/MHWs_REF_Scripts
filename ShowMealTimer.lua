local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local StatusIcon_field = sdk.find_type_definition("app.StatusIconInfo"):get_field("_StatusIcon");

local STATUS_0019 = StatusIcon_field:get_type():get_field("STATUS_0019"):get_data(nil); -- MealEffect

sdk.hook(sdk.find_type_definition("app.StatusIconManager"):get_method("forceHideTimer(app.StatusIconInfo)"), function(args)
    return StatusIcon_field:get_data(sdk.to_managed_object(args[3])) == STATUS_0019 and sdk.PreHookResult.SKIP_ORIGINAL or sdk.PreHookResult.CALL_ORIGINAL;
end);