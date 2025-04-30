local require = _G.require;

local Constants = require("Constants/Constants");
local DisablePP = require("GraphicsMOD/disable_postprocessing");
local LiteEnvironment = require("GraphicsMOD/LiteEnvironment");

local sdk = Constants.sdk;

DisablePP.ApplySettings();
LiteEnvironment.apply_gi_setting();

sdk.hook(Constants.CameraManager_type_def:get_method("onSceneLoadFadeIn"), function(args)
    if Constants.CameraManager == nil then
        Constants.CameraManager = sdk.to_managed_object(args[2]);
    end
end, function()
    DisablePP.ApplySettings();
    LiteEnvironment.apply_gi_setting();
end);