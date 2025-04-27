local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local get_LDRPostProcess_method = sdk.find_type_definition("app.AppEffectManager"):get_method("get_LDRPostProcess");
local get_ColorCorrect_method = get_LDRPostProcess_method:get_return_type():get_method("get_ColorCorrect");
local set_Enabled_method = get_ColorCorrect_method:get_return_type():get_method("set_Enabled(System.Boolean)");

local get_DisplaySettings_method = Constants.GraphicsManager_type_def:get_method("get_DisplaySettings");
local get_NowGraphicsSetting_method = Constants.GraphicsManager_type_def:get_method("get_NowGraphicsSetting");
local setGraphicsSetting_method = Constants.GraphicsManager_type_def:get_method("setGraphicsSetting(ace.cGraphicsSetting)");
local AppGraphicsSettingController_field = Constants.GraphicsManager_type_def:get_field("_AppGraphicsSettingController");
local ToneMapping_field = Constants.GraphicsManager_type_def:get_field("_ToneMapping");

local DisplaySettings_type_def = get_DisplaySettings_method:get_return_type();
local set_UseSDRBrightnessOptionForOverlay_method = DisplaySettings_type_def:get_method("set_UseSDRBrightnessOptionForOverlay(System.Boolean)");
local set_Gamma_method = DisplaySettings_type_def:get_method("set_Gamma(System.Single)");
local set_GammaForOverlay_method = DisplaySettings_type_def:get_method("set_GammaForOverlay(System.Single)");
local set_OutputLowerLimit_method = DisplaySettings_type_def:get_method("set_OutputLowerLimit(System.Single)");
local set_OutputUpperLimit_method = DisplaySettings_type_def:get_method("set_OutputUpperLimit(System.Single)");
local set_OutputLowerLimitForOverlay_method = DisplaySettings_type_def:get_method("set_OutputLowerLimitForOverlay(System.Single)");
local set_OutputUpperLimitForOverlay_method = DisplaySettings_type_def:get_method("set_OutputUpperLimitForOverlay(System.Single)");
local get_HDRMode_method = DisplaySettings_type_def:get_method("get_HDRMode");
local updateRequest_method = DisplaySettings_type_def:get_method("updateRequest");

local GraphicsSetting_type_def = get_NowGraphicsSetting_method:get_return_type();
local set_Fog_Enable_method = GraphicsSetting_type_def:get_method("set_Fog_Enable(System.Boolean)");
local set_VolumetricFogControl_Enable_method = GraphicsSetting_type_def:get_method("set_VolumetricFogControl_Enable(System.Boolean)");
local set_FilmGrain_Enable_method = GraphicsSetting_type_def:get_method("set_FilmGrain_Enable(System.Boolean)");
local set_LensFlare_Enable_method = GraphicsSetting_type_def:get_method("set_LensFlare_Enable(System.Boolean)");
local set_GodRay_Enable_method = GraphicsSetting_type_def:get_method("set_GodRay_Enable(System.Boolean)");
local set_LensDistortionSetting_method = GraphicsSetting_type_def:get_method("set_LensDistortionSetting(via.render.RenderConfig.LensDistortionSetting)");
local set_DynamicResolutionMode_method = GraphicsSetting_type_def:get_method("set_DynamicResolutionMode(ace.cGraphicsSetting.DYNAMIC_RESOLUTION_MODE)");

local ToneMapping_type_def = ToneMapping_field:get_type();
local setTemporalAA_method = ToneMapping_type_def:get_method("setTemporalAA(via.render.ToneMapping.TemporalAA)");
local set_EchoEnabled_method = ToneMapping_type_def:get_method("set_EchoEnabled(System.Boolean)");
local set_EnableLocalExposure_method = ToneMapping_type_def:get_method("set_EnableLocalExposure(System.Boolean)");
local setLocalExposureType_method = ToneMapping_type_def:get_method("setLocalExposureType(via.render.ToneMapping.LocalExposureType)");
local set_Contrast_method = ToneMapping_type_def:get_method("set_Contrast(System.Single)");

local get_DynamicResolution_method = AppGraphicsSettingController_field:get_type():get_method("get_DynamicResolution");

local GraphicsDynamicResolution_type_def = get_DynamicResolution_method:get_return_type();
local get_Enable_method = GraphicsDynamicResolution_type_def:get_method("get_Enable");
local set_Enable_method = GraphicsDynamicResolution_type_def:get_method("set_Enable(System.Boolean)");

local TemporalAA_type_def = sdk.find_type_definition("via.render.ToneMapping.TemporalAA");
local TemporalAA = {
    Strong = TemporalAA_type_def:get_field("Strong"):get_data(nil),
    Disable = TemporalAA_type_def:get_field("Disable"):get_data(nil)
};

local LocalExposureType_type_def = sdk.find_type_definition("via.render.ToneMapping.LocalExposureType");
local LocalExposureType = {
    Leagacy = LocalExposureType_type_def:get_field("Legacy"):get_data(nil),
    BlurredLuminance = LocalExposureType_type_def:get_field("BlurredLuminance"):get_data(nil)
};

local LensDistortionSetting_type_def = sdk.find_type_definition("via.render.RenderConfig.LensDistortionSetting");
local LensDistortionSetting = {
    ON = LensDistortionSetting_type_def:get_field("ON"):get_data(nil),
    OFF = LensDistortionSetting_type_def:get_field("OFF"):get_data(nil)
};

local DYNAMIC_RESOLUTION_MODE_TARGET_60 = sdk.find_type_definition("ace.cGraphicsSetting.DYNAMIC_RESOLUTION_MODE"):get_field("TARGET_60"):get_data(nil);

local DisablePP = {};

local settings = {
    TAA = false,
    jitter = false,
    colorCorrect = true,
    lensDistortionEnable = false,
    localExposure = true,
    localExposureBlurredLuminance = false,
    customContrastEnable = false,
    filmGrain = true,
    lensFlare = true,
    godRay = true,
    fog = true,
    volumetricFog = true,
    customBrightnessEnable = false,
    useSDRBrightnessOptionforOverlay = false,
    customContrast = 1.0,
    gamma = 1.0,
    gammaOverlay = 1.0,
    lowerLimit = 0.0,
    upperLimit = 1.0,
    lowerLimitOverlay = 0.0,
    upperLimitOverlay = 1.0
};

local changeBrightness = false;

local function SaveSettings()
    json.dump_file("mhwi_remove_postprocessing.json", settings);
end

local function LoadSettings(setting)
    changeBrightness = settings.customBrightnessEnable;
    local loadedTable = setting == 1 and json.load_file("mhwi_remove_postprocessing_game_defaults.json") or json.load_file("mhwi_remove_postprocessing.json");
    if loadedTable ~= nil then
        for key, value in Constants.pairs(loadedTable) do
            settings[key] = value;
        end
    end
end

LoadSettings(nil);

DisablePP.ApplySettings = function()
    if Constants.GraphicsManager == nil then
        Constants.GraphicsManager = sdk.get_managed_singleton("app.GraphicsManager");
    end
    local ToneMapping = ToneMapping_field:get_data(Constants.GraphicsManager);
    if ToneMapping ~= nil then
        setTemporalAA_method:call(ToneMapping, settings.TAA == true and TemporalAA.Strong or TemporalAA.Disable);
        set_EchoEnabled_method:call(ToneMapping, settings.jitter);
        set_EnableLocalExposure_method:call(ToneMapping, settings.localExposure);
        setLocalExposureType_method:call(ToneMapping, settings.localExposureBlurredLuminance == true and LocalExposureType.BlurredLuminance or LocalExposureType.Legacy);
        set_Contrast_method:call(ToneMapping, settings.customContrastEnable == true and settings.customContrast or settings.colorCorrect == false and 1.0 or 0.3);
    end

    local DisplaySettings = get_DisplaySettings_method:call(Constants.GraphicsManager);
    if DisplaySettings ~= nil then
        set_UseSDRBrightnessOptionForOverlay_method:call(DisplaySettings, settings.customBrightnessEnable);
        if settings.customBrightnessEnable == true or changeBrightness == true then
            set_Gamma_method:call(DisplaySettings, settings.gamma);
            set_GammaForOverlay_method:call(DisplaySettings, settings.gammaOverlay);
            set_OutputLowerLimit_method:call(DisplaySettings, settings.lowerLimit);
            set_OutputUpperLimit_method:call(DisplaySettings, settings.upperLimit);
            set_OutputLowerLimitForOverlay_method:call(DisplaySettings, settings.lowerLimitOverlay);
            set_OutputUpperLimitForOverlay_method:call(DisplaySettings, settings.upperLimitOverlay);
            if get_HDRMode_method:call(DisplaySettings) == false then
                updateRequest_method:call(DisplaySettings);
            end
            changeBrightness = false;
        end
    end

    local AppGraphicsSettingController = AppGraphicsSettingController_field:get_data(Constants.GraphicsManager);
    if AppGraphicsSettingController ~= nil then
        local GraphicsDynamicResolution = get_DynamicResolution_method:call(AppGraphicsSettingController);
        if GraphicsDynamicResolution ~= nil and get_Enable_method:call(GraphicsDynamicResolution) == false then
            set_Enable_method:call(GraphicsDynamicResolution, true);
        end
    end

    local NowGraphicsSetting = get_NowGraphicsSetting_method:call(Constants.GraphicsManager);
    if NowGraphicsSetting ~= nil then
        set_Fog_Enable_method:call(NowGraphicsSetting, settings.fog);
        set_VolumetricFogControl_Enable_method:call(NowGraphicsSetting, settings.volumetricFog);
        set_FilmGrain_Enable_method:call(NowGraphicsSetting, settings.filmGrain);
        set_LensFlare_Enable_method:call(NowGraphicsSetting, settings.lensFlare);
        set_GodRay_Enable_method:call(NowGraphicsSetting, settings.godRay);
        set_LensDistortionSetting_method:call(NowGraphicsSetting, settings.lensDistortionEnable == true and LensDistortionSetting.ON or LensDistortionSetting.OFF);
        set_DynamicResolutionMode_method:call(NowGraphicsSetting, DYNAMIC_RESOLUTION_MODE_TARGET_60);
        setGraphicsSetting_method:call(Constants.GraphicsManager, NowGraphicsSetting);
    end
end

sdk.hook(ToneMapping_type_def:get_method("clearHistogram"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[1]);
end, function()
    set_EnableLocalExposure_method:call(thread.get_hook_storage()["this"], settings.localExposure);
end);

local ColorCorrect = nil;
re.on_application_entry("LockScene", function()
    if ColorCorrect == nil then
        local AppEffectManager = sdk.get_managed_singleton("app.AppEffectManager");
        if AppEffectManager ~= nil then
            local LDRPostProcess = get_LDRPostProcess_method:call(AppEffectManager);
            if LDRPostProcess ~= nil then
                ColorCorrect = get_ColorCorrect_method:call(LDRPostProcess);
            end
        end
    end
    if ColorCorrect ~= nil then
        set_Enabled_method:call(ColorCorrect, settings.colorCorrect);
    end
end);

re.on_config_save(SaveSettings);

re.on_draw_ui(function()
    if imgui.tree_node("Post Processing Settings") == true then
        local changed = false;
        local requireSave = false;
        imgui.push_style_color(21, 0xFF030380);
        if imgui.small_button("Save settings") == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.same_line();
        if imgui.small_button("Load game defaults") == true then
            LoadSettings(1);
            DisablePP.ApplySettings();
        end
        imgui.same_line();
        if imgui.small_button("Load saved settings") == true then
            LoadSettings(nil);
            DisablePP.ApplySettings();
        end
        imgui.pop_style_color(1);
        imgui.text("NOTE: requires game restart after loading defaults to fully revert brightness changes");
        imgui.spacing();

        imgui.text("Anti-Aliasing & filters");
        changed, settings.TAA = imgui.checkbox("TAA", settings.TAA);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.indent(24);
        changed, settings.jitter = imgui.checkbox("TAA jitter", settings.jitter);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.unindent(24);
        changed, settings.colorCorrect = imgui.checkbox("Color correction", settings.colorCorrect);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.localExposure = imgui.checkbox("Local exposure", settings.localExposure);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.indent(24);
        changed, settings.localExposureBlurredLuminance = imgui.checkbox("Use blurred luminance (sharpens)", settings.localExposureBlurredLuminance);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.unindent(24);
        changed, settings.customContrastEnable = imgui.checkbox("Enable custom contrast", settings.customContrastEnable);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.customContrast = imgui.drag_float("Contrast", settings.customContrast, 0.01, 0.01, 5.0);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.new_line();

        imgui.text("SDR gamma & Brightness");
        changed, settings.customBrightnessEnable = imgui.checkbox("Enable SDR custom gamma & brightness", settings.customBrightnessEnable);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.text("NOTE: requires game restart after disabling to revert changes");
        imgui.spacing();

        imgui.text_colored("Use in game brightness options for HDR", 0xAD0000FF);
        imgui.push_style_color(21, 0xFF030380);
        if imgui.small_button("Reset gamma & brightness") == true then
            settings.gamma = 1.0;
            settings.gammaOverlay = 1.0;
            settings.lowerLimit = 0.0;
            settings.upperLimit = 1.0;
            settings.lowerLimitOverlay = 0.0;
            settings.upperLimitOverlay = 1.0;
            DisablePP.ApplySettings();
        end
        imgui.pop_style_color(1);
        changed, settings.gamma = imgui.drag_float("Gamma", settings.gamma, 0.001, 0.001, 5.0);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.upperLimit = imgui.drag_float("Max brightness", settings.upperLimit, 0.001, 0.001, 10.0);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.lowerLimit = imgui.drag_float("Min brightness", settings.lowerLimit, 0.001, -5.0, 5.0);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.spacing();

        changed, settings.gammaOverlay = imgui.drag_float("UI gamma", settings.gammaOverlay, 0.001, 0.001, 5.0);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.upperLimitOverlay = imgui.drag_float("UI max brightness", settings.upperLimitOverlay, 0.001, 0.001, 10.0);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.lowerLimitOverlay = imgui.drag_float("UI min brightness", settings.lowerLimitOverlay, 0.001, -5.0, 5.0);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.new_line();

        imgui.text("Graphics Settings");
        imgui.push_style_color(21, 0xFF030380);
        if imgui.small_button("Apply graphics settings") == true then
            DisablePP.ApplySettings();
        end
        imgui.pop_style_color(1);
        changed, settings.lensDistortionEnable = imgui.checkbox("Lens distortion", settings.lensDistortionEnable);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.fog = imgui.checkbox("Fog", settings.fog);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.volumetricFog = imgui.checkbox("Volumetric fog", settings.volumetricFog);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.filmGrain = imgui.checkbox("Film grain", settings.filmGrain);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.lensFlare = imgui.checkbox("Lens flare", settings.lensFlare);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        changed, settings.godRay = imgui.checkbox("Godray", settings.godRay);
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.spacing();

        imgui.text("WARNING: applying graphics settings will set");
        imgui.text("ambient lighting to high due to a bug in the game");
        imgui.text("until returning to title or restarting the game");
        imgui.tree_pop();

        if requireSave == true then
            SaveSettings();
            DisablePP.ApplySettings();
        end
    end
end);

return DisablePP;