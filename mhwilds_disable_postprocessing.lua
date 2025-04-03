local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local pairs = Constants.pairs;

local statics = require("utility/Statics");
local TAAStrength = statics.generate("via.render.ToneMapping.TemporalAA", true);
local localExposureType = statics.generate("via.render.ToneMapping.LocalExposureType", true);
local lensDistortionSetting = statics.generate("via.render.RenderConfig.LensDistortionSetting", true);

local settings = {
    TAA = false,
    jitter = false,
    LDRPostProcessEnable = true,
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
    upperLimitOverlay = 1.0,
    disable_wind_simulation = true,
    disable_global_illumination = true
};

local get_Instance_method = sdk.find_type_definition("ace.GAElement`1<ace.WindManagerBase>"):get_method("get_Instance"); -- static;

local get_PrimaryCamera_method = sdk.find_type_definition("ace.CameraUtil"):get_method("get_PrimaryCamera"); -- static
local get_GameObject_method = get_PrimaryCamera_method:get_return_type():get_method("get_GameObject");
local getComponent_method = get_GameObject_method:get_return_type():get_method("getComponent(System.Type)");

local ToneMapping_type_def = sdk.find_type_definition("via.render.ToneMapping");
local ToneMapping_runtime_type = ToneMapping_type_def:get_runtime_type();
local setTemporalAA_method = ToneMapping_type_def:get_method("setTemporalAA(via.render.ToneMapping.TemporalAA)");
local set_EchoEnabled_method = ToneMapping_type_def:get_method("set_EchoEnabled(System.Boolean)");
local set_EnableLocalExposure_method = ToneMapping_type_def:get_method("set_EnableLocalExposure(System.Boolean)");
local setLocalExposureType_method = ToneMapping_type_def:get_method("setLocalExposureType(via.render.ToneMapping.LocalExposureType)");
local set_Contrast_method = ToneMapping_type_def:get_method("set_Contrast(System.Single)");

local get_NowGraphicsSetting_method = Constants.get_NowGraphicsSetting_method;
local setGraphicsSetting_method = Constants.setGraphicsSetting_method;
local get_DisplaySettings_method = Constants.GraphicsManager_type_def:get_method("get_DisplaySettings");

local DisplaySettings_type_def = get_DisplaySettings_method:get_return_type();
local set_UseSDRBrightnessOptionForOverlay_method = DisplaySettings_type_def:get_method("set_UseSDRBrightnessOptionForOverlay(System.Boolean)");
local set_Gamma_method = DisplaySettings_type_def:get_method("set_Gamma(System.Single)");
local set_GammaForOverlay_method = DisplaySettings_type_def:get_method("set_GammaForOverlay(System.Single)");
local set_OutputLowerLimit_method = DisplaySettings_type_def:get_method("set_OutputLowerLimit(System.Single)");
local set_OutputUpperLimit_method = DisplaySettings_type_def:get_method("set_OutputUpperLimit(System.Single)");
local get_HDRMode_method = DisplaySettings_type_def:get_method("get_HDRMode");
local updateRequest_method = DisplaySettings_type_def:get_method("updateRequest");

local GraphicsSetting_type_def = get_NowGraphicsSetting_method:get_return_type();
local set_Fog_Enable_method = GraphicsSetting_type_def:get_method("set_Fog_Enable(System.Boolean)");
local set_VolumetricFogControl_Enable_method = GraphicsSetting_type_def:get_method("set_VolumetricFogControl_Enable(System.Boolean)");
local set_FilmGrain_Enable_method = GraphicsSetting_type_def:get_method("set_FilmGrain_Enable(System.Boolean)");
local set_LensFlare_Enable_method = GraphicsSetting_type_def:get_method("set_LensFlare_Enable(System.Boolean)");
local set_GodRay_Enable_method = GraphicsSetting_type_def:get_method("set_GodRay_Enable(System.Boolean)");
local set_LensDistortionSetting_method = GraphicsSetting_type_def:get_method("set_LensDistortionSetting(via.render.RenderConfig.LensDistortionSetting)");

local LDRPostProcess_type_def = sdk.find_type_definition("via.render.LDRPostProcess");
local LDRPostProcess_runtime_type = LDRPostProcess_type_def:get_runtime_type();
local get_ColorCorrect_method = LDRPostProcess_type_def:get_method("get_ColorCorrect");

local ColorCorrect_set_Enabled_method = get_ColorCorrect_method:get_return_type():get_method("set_Enabled(System.Boolean)");

local get_DPGIComponent_method = sdk.find_type_definition("app.EnvironmentManager"):get_method("get_DPGIComponent");
local DPGI_set_Enabled_method = get_DPGIComponent_method:get_return_type():get_method("set_Enabled(System.Boolean)");

local apply = false;

local function SaveSettings()
    json.dump_file("mhwi_remove_postprocessing.json", settings);
end

local function LoadSettings()
    local loadedTable = json.load_file("mhwi_remove_postprocessing.json");
    if loadedTable ~= nil then
        for key in pairs(loadedTable) do
            settings[key] = loadedTable[key];
        end
    end
end

local function ResetBrightness()
    settings.gamma = 1.0;
    settings.gammaOverlay = 1.0;
    settings.lowerLimit = 0.0;
    settings.upperLimit = 1.0;
    settings.lowerLimitOverlay = 0.0
    settings.upperLimitOverlay = 1.0
end

local function get_component(runtime_type)
    return getComponent_method:call(get_GameObject_method:call(get_PrimaryCamera_method:call(nil)), runtime_type);
end

local function apply_ws_setting()
    get_Instance_method:call(nil):set_field("_Stop", settings.disable_wind_simulation);
end

local function apply_gi_setting()
    local EnvironmentManager = sdk.get_managed_singleton("app.EnvironmentManager");
    if EnvironmentManager ~= nil then
        local DPGIComponent = get_DPGIComponent_method:call(EnvironmentManager);
        if DPGIComponent ~= nil then
            DPGI_set_Enabled_method:call(DPGIComponent, not settings.disable_global_illumination);
        end
    end
end

local function ApplySettings()
    local ToneMapping = get_component(ToneMapping_runtime_type);

    setTemporalAA_method:call(ToneMapping, settings.TAA == true and TAAStrength.Strong or TAAStrength.Disable);
    set_EchoEnabled_method:call(ToneMapping, settings.jitter);
    set_EnableLocalExposure_method:call(ToneMapping, settings.localExposure);
    setLocalExposureType_method:call(ToneMapping, settings.localExposureBlurredLuminance == true and localExposureType.BlurredLuminance or localExposureType.Legacy);

    set_Contrast_method:call(ToneMapping, settings.customContrastEnable == true and settings.customContrast or settings.colorCorrect == false and 1.0 or 0.3);

    local GraphicsManager = sdk.get_managed_singleton("app.GraphicsManager");
    local displaySettings = get_DisplaySettings_method:call(GraphicsManager);

    if settings.customBrightnessEnable == true then
        set_UseSDRBrightnessOptionForOverlay_method:call(displaySettings, true);
        set_Gamma_method:call(displaySettings, settings.gamma);
        set_GammaForOverlay_method:call(displaySettings, settings.gammaOverlay);
        set_OutputLowerLimit_method:call(displaySettings, settings.lowerLimit);
        set_OutputUpperLimit_method:call(displaySettings, settings.upperLimit);
        if get_HDRMode_method:call(displaySettings) == false then
            updateRequest_method:call(displaySettings);
        end
    else
        set_UseSDRBrightnessOptionForOverlay_method:call(displaySettings, false);
    end

    local graphicsSetting = get_NowGraphicsSetting_method:call(GraphicsManager);

    set_Fog_Enable_method:call(graphicsSetting, settings.fog);
    set_VolumetricFogControl_Enable_method:call(graphicsSetting, settings.volumetricFog);
    set_FilmGrain_Enable_method:call(graphicsSetting, settings.filmGrain);
    set_LensFlare_Enable_method:call(graphicsSetting, settings.lensFlare);
    set_GodRay_Enable_method:call(graphicsSetting, settings.godRay);
    set_LensDistortionSetting_method:call(graphicsSetting, settings.lensDistortionEnable == true and lensDistortionSetting.ON or lensDistortionSetting.OFF);

    if apply == true then
        setGraphicsSetting_method:call(GraphicsManager, graphicsSetting);
    end
end

sdk.hook(Constants.CameraManager_type_def:get_method("onSceneLoadFadeIn"), nil, function()
    ApplySettings();
    apply_gi_setting();
end);
sdk.hook(ToneMapping_type_def:get_method("clearHistogram"), nil, function()
    set_EnableLocalExposure_method:call(get_component(ToneMapping_runtime_type), settings.localExposure);
end);

LoadSettings();
ApplySettings();
apply_ws_setting();
apply_gi_setting();

re.on_application_entry("LockScene", function()
    local Component = get_component(LDRPostProcess_runtime_type);
    if Component ~= nil then
        local ColorCorrect = get_ColorCorrect_method:call(Component);
        if ColorCorrect ~= nil then
            ColorCorrect_set_Enabled_method:call(ColorCorrect, settings.colorCorrect);
        end
    end
end);

re.on_draw_ui(function()
    if imgui.tree_node("Post Processing Settings") == true then
        local ws_changed = false;
        local gi_changed = false;
        local changed = false;

        imgui.push_style_color(21, 0xFF030380);
        changed = imgui.small_button("Save settings");
        imgui.pop_style_color(1);
        imgui.text("Anti-Aliasing & filters");
        changed, settings.TAA = imgui.checkbox("TAA enabled", settings.TAA);
        changed, settings.jitter = imgui.checkbox("TAA jitter enabled", settings.jitter);
        changed, settings.colorCorrect = imgui.checkbox("Color correction", settings.colorCorrect);
        changed, settings.localExposure = imgui.checkbox("Local exposure enabled", settings.localExposure);
        imgui.indent(24);
        changed, settings.localExposureBlurredLuminance = imgui.checkbox("Use blurred luminance (sharpens)", settings.localExposureBlurredLuminance);
        imgui.unindent(24);
        changed, settings.customContrastEnable = imgui.checkbox("Custom contrast enabled", settings.customContrastEnable);
        changed, settings.customContrast = imgui.drag_float("Contrast", settings.customContrast, 0.01, 0.01, 5.0);
        imgui.new_line();

        imgui.text("SDR gamma & Brightness");
        changed, settings.customBrightnessEnable = imgui.checkbox("SDR custom gamma & brightness enabled", settings.customBrightnessEnable);
        imgui.text("NOTE: requires game restart after disabling to revert changes");
        imgui.spacing();

        imgui.text_colored("Use in game brightness options for HDR", 0xAD0000FF);
        imgui.push_style_color(21, 0xFF030380);
        local isReset = imgui.small_button("Reset gamma & brightness");
        imgui.pop_style_color(1);
        if isReset == true then
            ResetBrightness();
            ApplySettings();
        end
        changed, settings.gamma = imgui.drag_float("Gamma", settings.gamma, 0.001, 0.001, 5.0);
        changed, settings.upperLimit = imgui.drag_float("Max brightness", settings.upperLimit, 0.001, 0.001, 10.0);
        changed, settings.lowerLimit = imgui.drag_float("Min brightness", settings.lowerLimit, 0.001, -5.0, 5.0);
        imgui.spacing();

        changed, settings.gammaOverlay = imgui.drag_float("UI gamma", settings.gammaOverlay, 0.001, 0.001, 5.0);
        changed, settings.upperLimitOverlay = imgui.drag_float("UI max brightness", settings.upperLimitOverlay, 0.001, 0.001, 10.0);
        changed, settings.lowerLimitOverlay = imgui.drag_float("UI min brightness", settings.lowerLimitOverlay, 0.001, -5.0, 5.0);
        imgui.new_line();

        imgui.text("Graphics Settings");
        imgui.push_style_color(21, 0xFF030380);
        apply = imgui.small_button("Apply graphics settings");
        imgui.pop_style_color(1);
        if apply == true then
            ApplySettings();
            apply = false;
        end
        changed, settings.lensDistortionEnable = imgui.checkbox("Lens distortion enabled", settings.lensDistortionEnable);
        changed, settings.fog = imgui.checkbox("Fog enabled", settings.fog);
        changed, settings.volumetricFog = imgui.checkbox("Volumetric fog enabled", settings.volumetricFog);
        changed, settings.filmGrain = imgui.checkbox("Film grain enabled", settings.filmGrain);
        changed, settings.lensFlare = imgui.checkbox("Lens flare enabled", settings.lensFlare);
        changed, settings.godRay = imgui.checkbox("Godray enabled", settings.godRay);
        ws_changed, settings.disable_wind_simulation = imgui.checkbox("Disable Wind Simulation", settings.disable_wind_simulation);
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("Huge performance improvement.\n\nThe vegetation and tissues sway will not longer\ndepend of the wind intensity and direction.");
        end
        gi_changed, settings.disable_global_illumination = imgui.checkbox("Disable Global Illumination", settings.disable_global_illumination);
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("Medium performance improvement.\n\nHighly deteriorate the visual quality.");
        end
        imgui.spacing();
        if changed == true then
            SaveSettings();
            ApplySettings();
        end
        if ws_changed == true then
            SaveSettings();
            apply_ws_setting();
        end
        if gi_changed == true then
            SaveSettings();
            apply_gi_setting();
        end

        imgui.text("WARNING: applying graphics settings will set");
        imgui.text("ambient lighting to high due to a bug in the game");
        imgui.text("until returning to title or restarting the game");
        imgui.spacing();

        imgui.tree_pop();
    end
end);