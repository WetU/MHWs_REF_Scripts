local require = _G.require;

local Constants = require("Constants/Constants");
local DisablePP = require("GraphicsMOD/disable_postprocessing");
local DisableCameraOverlapTransparency = require("GraphicsMOD/DisableCameraOverlapTransparency");
local LiteEnvironment = require("GraphicsMOD/LiteEnvironment");

DisablePP.ApplySettings();
LiteEnvironment.apply_gi_setting();

Constants.sdk.hook(DisableCameraOverlapTransparency.CameraManager_type_def:get_method("onSceneLoadFadeIn"), Constants.getObject, function()
    DisablePP.ApplySettings();
    LiteEnvironment.apply_gi_setting();
    DisableCameraOverlapTransparency.Apply(Constants.thread.get_hook_storage()["this"]);
end);