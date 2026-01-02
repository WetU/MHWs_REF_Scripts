local Constants = _G.require("Constants/Constants");

local tostring = Constants.tostring;

local log_debug = Constants.log_debug;

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_int64 = Constants.to_int64;

local GUI020206_type_def = find_type_definition("app.GUI020206");

local Default = find_type_definition("app.GUI020206.RequestType"):get_field("Default"):get_data(nil);

local SKIP_ORIGINAL = Constants.SKIP_ORIGINAL;

local function preHook_one(args)
    if (to_int64(args[4]) & 0xFFFFFFFF) == Default then
        return SKIP_ORIGINAL;
    end
end

local function preHook_SKIP()
    return SKIP_ORIGINAL;
end

hook(GUI020206_type_def:get_method("requestStage(app.FieldDef.STAGE, app.GUI020206.RequestType)"), preHook_one);
hook(GUI020206_type_def:get_method("requestLifeArea(app.FieldDef.LIFE_AREA, app.GUI020206.RequestType)"), preHook_one);
hook(GUI020206_type_def:get_method("requestCamp(app.GimmickDef.ID, System.Boolean)"), function(args)
    log_debug("GUI020206 requestCamp args[4] : " .. tostring(to_int64(args[4]) & 1));
    return SKIP_ORIGINAL;
end);
hook(GUI020206_type_def:get_method("requestBase(System.Guid, System.Guid, app.FieldDef.STAGE, app.FieldDef.LIFE_AREA, System.Boolean)"), preHook_SKIP);