local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local get_IsMaster_method = sdk.find_type_definition("app.HunterCharacter"):get_method("get_IsMaster");

local StatusIconManager_type_def = sdk.find_type_definition("app.StatusIconManager");

local StatusIcon_field = sdk.find_type_definition("app.StatusIconInfo"):get_field("_StatusIcon");

local STATUS_0019 = StatusIcon_field:get_type():get_field("STATUS_0019"):get_data(nil); -- MealEffect

sdk.hook(StatusIconManager_type_def:get_method("buffTimerUpdate(app.HunterCharacter, app.IconDef.STATUS, System.Boolean)"), function(args)
    if get_IsMaster_method:call(sdk.to_managed_object(args[3])) == true and (sdk.to_int64(args[4]) & 0xFFFFFFFF) == STATUS_0019 then
        args[5] = Constants.TRUE_ptr;
    end
end);

sdk.hook(StatusIconManager_type_def:get_method("forceHideTimer(app.StatusIconInfo)"), function(args)
    return StatusIcon_field:get_data(sdk.to_managed_object(args[3])) == STATUS_0019 and sdk.PreHookResult.SKIP_ORIGINAL or sdk.PreHookResult.CALL_ORIGINAL;
end);