local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;

local GUI020206_type_def = sdk.find_type_definition("app.GUI020206");

local Default = sdk.find_type_definition("app.GUI020206.RequestType"):get_field("Default"):get_data(nil);

local SKIP_ORIGINAL = sdk.PreHookResult.SKIP_ORIGINAL;

local function preHook_one(args)
    if (sdk.to_int64(args[4]) & 0xFFFFFFFF) == Default then
        return SKIP_ORIGINAL;
    end
end

local function preHook_SKIP()
    return SKIP_ORIGINAL;
end

sdk.hook(GUI020206_type_def:get_method("requestStage(app.FieldDef.STAGE, app.GUI020206.RequestType)"), preHook_one);
sdk.hook(GUI020206_type_def:get_method("requestLifeArea(app.FieldDef.LIFE_AREA, app.GUI020206.RequestType)"), preHook_one);
sdk.hook(GUI020206_type_def:get_method("requestCamp(app.GimmickDef.ID, System.Boolean)"), preHook_SKIP);
sdk.hook(GUI020206_type_def:get_method("requestBase(System.Guid, System.Guid, app.FieldDef.STAGE, app.FieldDef.LIFE_AREA, System.Boolean)"), preHook_SKIP);