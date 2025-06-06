local require = _G.require;

local Constants = require("Constants/Constants");
local DisablePP = require("GraphicsMOD/disable_postprocessing");
local LiteEnvironment = require("GraphicsMOD/LiteEnvironment");

local sdk = Constants.sdk;

local DemoMediator_type_def = sdk.find_type_definition("app.DemoMediator");

DisablePP.ApplySettings();
LiteEnvironment.apply_gi_setting(false);

sdk.hook(sdk.find_type_definition("app.CameraManager"):get_method("onSceneLoadFadeIn"), function(args)
    if Constants.CameraManager == nil then
        Constants.CameraManager = sdk.to_managed_object(args[2]);
    end
end, function()
    DisablePP.ApplySettings();
    LiteEnvironment.apply_gi_setting(false);
end);

sdk.hook(DemoMediator_type_def:get_method("onPlayStart(ace.DemoMediatorBase.cParamBase)"), nil, function()
    LiteEnvironment.apply_gi_setting(true);
    DisablePP.apply_vf_setting(true);
end);

sdk.hook(DemoMediator_type_def:get_method("unload(ace.DemoMediatorBase.cParamBase)"), nil, function()
    LiteEnvironment.apply_gi_setting(false);
    DisablePP.apply_vf_setting(false);
end);