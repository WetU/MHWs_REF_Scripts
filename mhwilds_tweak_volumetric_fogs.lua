local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local re = Constants.re;
local json = Constants.json;
local imgui = Constants.imgui;

local pairs = Constants.pairs;

local statics = require("utility/Statics");
local VolumetricFogTextureSizes = statics.generate("via.render.VolumetricFogControl.TextureSize", true);
local VolumetricFogIntegrationTypes = statics.generate("via.render.VolumetricFogControl.IntegrationType", true);
local VolumetricFogJitterNoiseTypes = statics.generate("via.render.VolumetricFogControl.JitterNoiseType", true);

local volumetricFogTextureSizeOptions = {
    "Lowest (" .. VolumetricFogTextureSizes[2] .. ", Hidden)",
    "Lower (" .. VolumetricFogTextureSizes[3] .. ", Hidden)",
    "Low (" .. VolumetricFogTextureSizes[0] .. ")",
    "High (" .. VolumetricFogTextureSizes[1] .. ")"
};

local volumetricFogTextureSizeValueMap = {
    VolumetricFogTextureSizes.W96xH54xD32,
    VolumetricFogTextureSizes.W96xH54xD64,
    VolumetricFogTextureSizes.W160xH90xD64,
    VolumetricFogTextureSizes.W160xH90xD128
};

local defaultSettings = {
    volumetricFogTextureSize = 3, -- Low
    ambientLightEnabled = true,
    ambientLightRateMultiplier = 1.0,
    emissionEnabled = true,
    fogCullingDistanceMultiplier = 1.0,
    advancedOptionsEnabled = false,
    shadowEnabled = true,
    depthDecodingParamMultiplier = 1.0,
    softnessMultiplier = 1.0,
    prevFrameBlendFactorMultiplier = 1.0,
    shadowCullingBlendFactorScaleMultiplier = 1.0,
    rejectionEnabled = true,
    rejectSensitivityMultiplier = 1.0,
    rejectSensitivityFactorMultiplier = 1.0,
    leakBiasMultiplier = 1.0,
    overrideIntegrationType = false,
    integrationType = 0,
    overrideJitterNoiseType = false,
    jitterNoiseType = 0,
    overrideFadeDistance = false,
    fadeDistance = -10.0,
    fadeDensity = 10.0
};

local settings = defaultSettings;

local function SaveSettings()
    json.dump_file("mhwilds_tweak_volumetric_fogs.json", settings);
end

local function LoadSettings()
    local loadedTable = json.load_file("mhwilds_tweak_volumetric_fogs.json");
    if loadedTable ~= nil then
        for key, val in pairs(loadedTable) do
            settings[key] = loadedTable[key];
        end
    end
end

LoadSettings();

local get_NowGraphicsSetting_method = Constants.get_NowGraphicsSetting_method;
local setGraphicsSetting_method = Constants.setGraphicsSetting_method;

local VolumetricFogControlParam_type_def = sdk.find_type_definition("ace.PostEffect.cVolumetricFogControlParam");
local get_ShadowEnabled_method = VolumetricFogControlParam_type_def:get_method("get_ShadowEnabled");
local set_ShadowEnabled_method = VolumetricFogControlParam_type_def:get_method("set_ShadowEnabled(System.Boolean)");
local get_AmbientLightEnabled_method = VolumetricFogControlParam_type_def:get_method("get_AmbientLightEnabled");
local set_AmbientLightEnabled_method = VolumetricFogControlParam_type_def:get_method("set_AmbientLightEnabled(System.Boolean)");
local get_AmbientLightRate_method = VolumetricFogControlParam_type_def:get_method("get_AmbientLightRate");
local set_AmbientLightRate_method = VolumetricFogControlParam_type_def:get_method("set_AmbientLightRate(System.Single)");
local get_EmissionEnabled_method = VolumetricFogControlParam_type_def:get_method("get_EmissionEnabled");
local set_EmissionEnabled_method = VolumetricFogControlParam_type_def:get_method("set_EmissionEnabled(System.Boolean)");
local get_FogCullingDistance_method = VolumetricFogControlParam_type_def:get_method("get_FogCullingDistance");
local set_FogCullingDistance_method = VolumetricFogControlParam_type_def:get_method("set_FogCullingDistance(System.Single)");
local get_DepthDecodingParam_method = VolumetricFogControlParam_type_def:get_method("get_DepthDecodingParam");
local set_DepthDecodingParam_method = VolumetricFogControlParam_type_def:get_method("set_DepthDecodingParam(System.Single)");
local get_VolumetricFogSoftness_method = VolumetricFogControlParam_type_def:get_method("get_VolumetricFogSoftness");
local set_VolumetricFogSoftness_method = VolumetricFogControlParam_type_def:get_method("set_VolumetricFogSoftness(System.Single)");
local get_PrevFrameBlendFactor_method = VolumetricFogControlParam_type_def:get_method("get_PrevFrameBlendFactor");
local set_PrevFrameBlendFactor_method = VolumetricFogControlParam_type_def:get_method("set_PrevFrameBlendFactor(System.Single)");
local get_ShadowCullingBlendFactorScale_method = VolumetricFogControlParam_type_def:get_method("get_ShadowCullingBlendFactorScale");
local set_ShadowCullingBlendFactorScale_method = VolumetricFogControlParam_type_def:get_method("set_ShadowCullingBlendFactorScale(System.Single)");
local set_Rejection_method = VolumetricFogControlParam_type_def:get_method("set_Rejection(System.Boolean)");
local get_RejectSensitivity_method = VolumetricFogControlParam_type_def:get_method("get_RejectSensitivity");
local set_RejectSensitivity_method = VolumetricFogControlParam_type_def:get_method("set_RejectSensitivity(System.Single)");
local get_RejectSensitivityFactor_method = VolumetricFogControlParam_type_def:get_method("get_RejectSensitivityFactor");
local set_RejectSensitivityFactor_method = VolumetricFogControlParam_type_def:get_method("set_RejectSensitivityFactor(System.Single)");
local get_LeakBias_method = VolumetricFogControlParam_type_def:get_method("get_LeakBias");
local set_LeakBias_method = VolumetricFogControlParam_type_def:get_method("set_LeakBias(System.Single)");
local get_NearFadeParams_method = VolumetricFogControlParam_type_def:get_method("get_NearFadeParams");
local set_NearFadeParams_method = VolumetricFogControlParam_type_def:get_method("set_NearFadeParams(via.Float2)");
local set_TextureSize_method = VolumetricFogControlParam_type_def:get_method("set_TextureSize(via.render.VolumetricFogControl.TextureSize)");
local set_IntegrationType_method = VolumetricFogControlParam_type_def:get_method("set_IntegrationType(via.render.VolumetricFogControl.IntegrationType)");
local set_JitterNoise_method = VolumetricFogControlParam_type_def:get_method("set_JitterNoise(via.render.VolumetricFogControl.JitterNoiseType)");

local function ApplySettings()
    local GraphicsManager = sdk.get_managed_singleton("app.GraphicsManager");
    if GraphicsManager ~= nil then
        setGraphicsSetting_method:call(GraphicsManager, get_NowGraphicsSetting_method:call(GraphicsManager));
    end
end

local function ResetSettings()
    for key, val in pairs(defaultSettings) do
        settings[key] = defaultSettings[key];
    end
    ApplySettings();
end

sdk.hook(sdk.find_type_definition("ace.PostEffect.cVolumetricFogControlController"):get_method("applyToComponent"), function(args)
    local VolumetricFogControlParam = sdk.to_managed_object(args[3]);

    set_TextureSize_method:call(VolumetricFogControlParam, volumetricFogTextureSizeValueMap[settings.volumetricFogTextureSize]);

    if settings.shadowEnabled ~= get_ShadowEnabled_method:call(VolumetricFogControlParam) then
        set_ShadowEnabled_method:call(VolumetricFogControlParam, settings.shadowEnabled);
    end

    local currAmbientLightEnabled = get_AmbientLightEnabled_method:call(VolumetricFogControlParam);
    if settings.ambientLightEnabled ~= currAmbientLightEnabled then
        set_AmbientLightEnabled_method:call(VolumetricFogControlParam, settings.ambientLightEnabled);
    end

    if currAmbientLightEnabled == true and settings.ambientLightEnabled == true then
        set_AmbientLightRate_method:call(VolumetricFogControlParam, get_AmbientLightRate_method:call(VolumetricFogControlParam) * settings.ambientLightRateMultiplier);
    end

    if settings.emissionEnabled ~= get_EmissionEnabled_method:call(VolumetricFogControlParam) then
        set_EmissionEnabled_method:call(VolumetricFogControlParam, settings.emissionEnabled);
    end

    set_FogCullingDistance_method:call(VolumetricFogControlParam, get_FogCullingDistance_method:call(VolumetricFogControlParam) * settings.fogCullingDistanceMultiplier);

    if settings.advancedOptionsEnabled == true then
        set_DepthDecodingParam_method:call(VolumetricFogControlParam, get_DepthDecodingParam_method:call(VolumetricFogControlParam) * settings.depthDecodingParamMultiplier);
        set_VolumetricFogSoftness_method:call(VolumetricFogControlParam, get_VolumetricFogSoftness_method:call(VolumetricFogControlParam) * settings.softnessMultiplier);
        set_PrevFrameBlendFactor_method:call(VolumetricFogControlParam, get_PrevFrameBlendFactor_method:call(VolumetricFogControlParam) * settings.prevFrameBlendFactorMultiplier);
        set_ShadowCullingBlendFactorScale_method:call(VolumetricFogControlParam, get_ShadowCullingBlendFactorScale_method:call(VolumetricFogControlParam) * settings.shadowCullingBlendFactorScaleMultiplier);
        set_Rejection_method:call(VolumetricFogControlParam, settings.rejectionEnabled);
    
        if settings.rejectionEnabled == true then
            set_RejectSensitivity_method:call(VolumetricFogControlParam, get_RejectSensitivity_method:call(VolumetricFogControlParam) * settings.rejectSensitivityMultiplier);
            set_RejectSensitivityFactor_method:call(VolumetricFogControlParam, get_RejectSensitivityFactor_method:call(VolumetricFogControlParam)* settings.rejectSensitivityFactorMultiplier);
        end

        set_LeakBias_method:call(VolumetricFogControlParam, get_LeakBias_method:call(VolumetricFogControlParam) * settings.leakBiasMultiplier);

        if settings.overrideIntegrationType == true then
            set_IntegrationType_method:call(VolumetricFogControlParam, settings.integrationType);
        end
        
        if settings.overrideJitterNoiseType == true then
            set_JitterNoise_method:call(VolumetricFogControlParam, settings.jitterNoiseType);
        end
    end

    if settings.overrideFadeDistance == true then
        local param = get_NearFadeParams_method:call(VolumetricFogControlParam);
        param.x = settings.fadeDistance;
        param.y = settings.fadeDensity;
        set_NearFadeParams_method:call(VolumetricFogControlParam, param);
    end
end);

re.on_draw_ui(function()
    if imgui.tree_node("Tweak volumetric fog(s)") == true then
        local changed = false;
        local requireSave = false;
        imgui.text("Note: Changes are applied immediately");
        imgui.set_next_item_width(200);
        changed, settings.volumetricFogTextureSize = imgui.combo("Volumetric fog resolution", settings.volumetricFogTextureSize, volumetricFogTextureSizeOptions);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("The lower you go the more likely it will look blocky, especially with Accurate fog integration type enabled");
        end

        changed, settings.ambientLightEnabled = imgui.checkbox("Ambient light enabled", settings.ambientLightEnabled);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end

        if settings.ambientLightEnabled == true then
            imgui.indent(50);
            imgui.set_next_item_width(100);
            changed, settings.ambientLightRateMultiplier = imgui.drag_float("Ambient light amount", settings.ambientLightRateMultiplier, 0.01, 0.0, 10.0);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            imgui.unindent(50);
        end

        changed, settings.emissionEnabled = imgui.checkbox("Emission enabled", settings.emissionEnabled);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end

        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("This is a subtle effect");
        end
        
        imgui.text("Fog culling distance");
        imgui.push_id("fogCullingDistance");
        imgui.set_next_item_width(100);
        changed, settings.fogCullingDistanceMultiplier = imgui.drag_float(" ", settings.fogCullingDistanceMultiplier, 0.01, 0.0, 10.0);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.pop_id();
        changed, settings.overrideFadeDistance = imgui.checkbox("Override near fade distance", settings.overrideFadeDistance);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end

        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("These are absolute settings (not multipliers), so it might be buggy.");
        end

        if settings.overrideFadeDistance == true then
            imgui.indent(50);
            imgui.set_next_item_width(100);
            changed, settings.fadeDistance = imgui.drag_float("Fade distance", settings.fadeDistance, 0.1, -10.0, 2000.0);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end

            if imgui.is_item_hovered() == true then
                imgui.begin_tooltip();
                imgui.text("AKA falloff distance");
                imgui.set_tooltip("Defaults to -10.0 (behind the camera)");
                imgui.end_tooltip();
            end

            imgui.set_next_item_width(100);
            changed, settings.fadeDensity = imgui.drag_float("Fade \"hardness\"(?)", settings.fadeDensity, 0.001, 0.0, 10.0);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end

            if imgui.is_item_hovered() == true then
                imgui.begin_tooltip();
                imgui.text("AKA falloff gradient");
                imgui.text("Defaults to 10.0, but seems to max out at around 0.02 - 0.1");
                imgui.end_tooltip();
            end
            imgui.unindent(50);
        end
        
        if imgui.tree_node("Advanced (no visible effects)") == true then
            changed, settings.advancedOptionsEnabled = imgui.checkbox("Enable advanced options", settings.advancedOptionsEnabled);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end

            if settings.advancedOptionsEnabled ~= true then
                imgui.begin_disabled(true);
            end

            changed, settings.shadowEnabled = imgui.checkbox("Shadow enabled", settings.shadowEnabled);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            
            imgui.push_item_width(100);
            changed, settings.depthDecodingParamMultiplier = imgui.drag_float("Depth decoding parameter", settings.depthDecodingParamMultiplier, 0.01, 0.0, 10.0);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            
            if imgui.is_item_hovered() == true then
                imgui.set_tooltip("Seems to affect fog rendering in the far distance");
            end

            changed, settings.softnessMultiplier = imgui.drag_float("Softness", settings.softnessMultiplier, 0.01, 0.0, 10.0);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            changed, settings.prevFrameBlendFactorMultiplier = imgui.drag_float("Previous frame blend factor", settings.prevFrameBlendFactorMultiplier, 0.01, 0.0, 10.0);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            changed, settings.shadowCullingBlendFactorScaleMultiplier = imgui.drag_float("Shadow culling blend factor scale", settings.shadowCullingBlendFactorScaleMultiplier, 0.01, 0.0, 10.0);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            changed, settings.rejectionEnabled = imgui.checkbox("Rejection enabled", settings.rejectionEnabled);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            imgui.pop_item_width(100);

            if settings.rejectionEnabled == true then
                imgui.indent(40);
                imgui.set_next_item_width(100);
                changed, settings.rejectSensitivityMultiplier = imgui.drag_float("Reject sensitivity", settings.rejectSensitivityMultiplier, 0.01, 0.0, 10.0);
                if changed == true and requireSave ~= true then
                    requireSave = true;
                end
                imgui.set_next_item_width(100);
                changed, settings.rejectSensitivityFactorMultiplier = imgui.drag_float("Reject sensitivity factor", settings.rejectSensitivityFactorMultiplier, 0.01, 0.0, 10.0);
                if changed == true and requireSave ~= true then
                    requireSave = true;
                end
                imgui.unindent(40);
            end
            imgui.set_next_item_width(100);
            changed, settings.leakBiasMultiplier = imgui.drag_float("Leak bias", settings.leakBiasMultiplier, 0.01, 0.0, 10.0);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            imgui.push_id("integrationType");
            imgui.set_next_item_width(200);
            if settings.overrideIntegrationType ~= true then
                imgui.begin_disabled(true);
            end

            changed, settings.integrationType = imgui.combo("Fog integration type", settings.integrationType, VolumetricFogIntegrationTypes);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end

            if imgui.is_item_hovered() == true then
                imgui.begin_tooltip();
                imgui.text("Accurate makes low-quality blocky artifacts very obvious, why would you do this");
                imgui.text("Defaults to Blurry");
                imgui.end_tooltip();
            end

            if settings.overrideIntegrationType ~= true then
                imgui.end_disabled();
            end

            imgui.same_line();
            changed, settings.overrideIntegrationType = imgui.checkbox("Override", settings.overrideIntegrationType);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end

            if imgui.is_item_hovered() == true then
                imgui.begin_tooltip();
                imgui.text("Accurate makes low-quality blocky artifacts very obvious, why would you do this");
                imgui.text("Defaults to Blurry");
                imgui.end_tooltip();
            end

            imgui.pop_id();
            imgui.push_id("jitterNoiseType");
            imgui.set_next_item_width(200);

            if settings.overrideJitterNoiseType ~= true then
                imgui.begin_disabled(true);
            end

            changed, settings.jitterNoiseType = imgui.combo("Fog jitter noise type", settings.jitterNoiseType, VolumetricFogJitterNoiseTypes);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end

            if settings.overrideJitterNoiseType ~= true then
                imgui.end_disabled();
            end

            imgui.same_line();
            changed, settings.overrideJitterNoiseType = imgui.checkbox("Override", settings.overrideJitterNoiseType);
            if changed == true and requireSave ~= true then
                requireSave = true;
            end
            imgui.pop_id();

            if settings.advancedOptionsEnabled ~= true then
                imgui.end_disabled(true);
            end

            imgui.tree_pop();
        end

        imgui.push_style_color(21, -16777117);
        local defaultsClicked = imgui.button("Reset to defaults");
        imgui.pop_style_color(1);

        if requireSave == true then
            ApplySettings();
            saveConfig();
        end

        if defaultsClicked == true then
            ResetSettings();
            saveConfig();
        end

        imgui.tree_pop();
    end
end);