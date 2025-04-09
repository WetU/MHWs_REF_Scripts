local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local pairs = Constants.pairs;

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

local GraphicsManager_cached = false;
local DisplaySettings_cached = false;
local GraphicsSetting_cached = false;

local get_Instance_method = sdk.find_type_definition("ace.GAElement`1<ace.WindManagerBase>"):get_method("get_Instance"); -- static

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

local LDRPostProcess_type_def = sdk.find_type_definition("via.render.LDRPostProcess");
local LDRPostProcess_runtime_type = LDRPostProcess_type_def:get_runtime_type();
local get_ColorCorrect_method = LDRPostProcess_type_def:get_method("get_ColorCorrect");
local ColorCorrect_set_Enabled_method = get_ColorCorrect_method:get_return_type():get_method("set_Enabled(System.Boolean)");

local get_NowGraphicsSetting_method = nil;
local setGraphicsSetting_method = nil;
local get_DisplaySettings_method = nil;

local set_UseSDRBrightnessOptionForOverlay_method = nil;
local set_Gamma_method = nil;
local set_GammaForOverlay_method = nil;
local set_OutputLowerLimit_method = nil;
local set_OutputUpperLimit_method = nil;
local set_OutputLowerLimitForOverlay_method = nil;
local set_OutputUpperLimitForOverlay_method = nil;
local get_HDRMode_method = nil;
local updateRequest_method = nil;

local set_Fog_Enable_method = nil;
local set_VolumetricFogControl_Enable_method = nil;
local set_FilmGrain_Enable_method = nil;
local set_LensFlare_Enable_method = nil;
local set_GodRay_Enable_method = nil;
local set_LensDistortionSetting_method = nil;

local get_DPGIComponent_method = nil;
local DPGI_set_Enabled_method = nil;

local TemporalAA_type_def = sdk.find_type_definition("via.render.ToneMapping.TemporalAA");
local Strong = TemporalAA_type_def:get_field("Strong"):get_data(nil); -- static
local Disable = TemporalAA_type_def:get_field("Disable"):get_data(nil); -- static

local LocalExposureType_type_def = sdk.find_type_definition("via.render.ToneMapping.LocalExposureType");
local Legacy = LocalExposureType_type_def:get_field("Legacy"):get_data(nil); -- static
local BlurredLuminance = LocalExposureType_type_def:get_field("BlurredLuminance"):get_data(nil); -- static

local LensDistortionSetting_type_def = sdk.find_type_definition("via.render.RenderConfig.LensDistortionSetting");
local ON = LensDistortionSetting_type_def:get_field("ON"):get_data(nil); -- static
local OFF = LensDistortionSetting_type_def:get_field("OFF"):get_data(nil); -- static

local apply = false;
local changeBrightness = false;

local function SaveSettings()
    json.dump_file("mhwi_remove_postprocessing.json", settings);
end

local function LoadSettings(setting)
    changeBrightness = settings.customBrightnessEnable;
    local loadedTable = setting == 1 and json.load_file("mhwi_remove_postprocessing_game_defaults.json") or json.load_file("mhwi_remove_postprocessing.json");
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
    settings.lowerLimitOverlay = 0.0;
    settings.upperLimitOverlay = 1.0;
end

local function get_component(runtime_type)
    local PrimaryCamera = get_PrimaryCamera_method:call(nil);
    if PrimaryCamera ~= nil then
        local GameObject = get_GameObject_method:call(PrimaryCamera);
        if GameObject ~= nil then
            return getComponent_method:call(GameObject, runtime_type);
        end
    end
    return nil;
end

local function getGraphicsManagerCache(graphicsManager)
    local GraphicsManager_type_def = graphicsManager:get_type_definition();
    get_DisplaySettings_method = GraphicsManager_type_def:get_method("get_DisplaySettings");
    get_NowGraphicsSetting_method = GraphicsManager_type_def:get_method("get_NowGraphicsSetting");
    setGraphicsSetting_method = GraphicsManager_type_def:get_method("setGraphicsSetting(ace.cGraphicsSetting)");
    GraphicsManager_cached = true;
end

local function getDisplaySettingsCache(displaySettings)
    local DisplaySettings_type_def = displaySettings:get_type_definition();
    set_UseSDRBrightnessOptionForOverlay_method = DisplaySettings_type_def:get_method("set_UseSDRBrightnessOptionForOverlay(System.Boolean)");
    set_Gamma_method = DisplaySettings_type_def:get_method("set_Gamma(System.Single)");
    set_GammaForOverlay_method = DisplaySettings_type_def:get_method("set_GammaForOverlay(System.Single)");
    set_OutputLowerLimit_method = DisplaySettings_type_def:get_method("set_OutputLowerLimit(System.Single)");
    set_OutputUpperLimit_method = DisplaySettings_type_def:get_method("set_OutputUpperLimit(System.Single)");
    set_OutputLowerLimitForOverlay_method = DisplaySettings_type_def:get_method("set_OutputLowerLimitForOverlay(System.Single)");
    set_OutputUpperLimitForOverlay_method = DisplaySettings_type_def:get_method("set_OutputUpperLimitForOverlay(System.Single)");
    get_HDRMode_method = DisplaySettings_type_def:get_method("get_HDRMode");
    updateRequest_method = DisplaySettings_type_def:get_method("updateRequest");
    DisplaySettings_cached = true;
end

local function getGraphicsSettingCache(graphicsSetting)
    local GraphicsSetting_type_def = graphicsSetting:get_type_definition();
    set_Fog_Enable_method = GraphicsSetting_type_def:get_method("set_Fog_Enable(System.Boolean)");
    set_VolumetricFogControl_Enable_method = GraphicsSetting_type_def:get_method("set_VolumetricFogControl_Enable(System.Boolean)");
    set_FilmGrain_Enable_method = GraphicsSetting_type_def:get_method("set_FilmGrain_Enable(System.Boolean)");
    set_LensFlare_Enable_method = GraphicsSetting_type_def:get_method("set_LensFlare_Enable(System.Boolean)");
    set_GodRay_Enable_method = GraphicsSetting_type_def:get_method("set_GodRay_Enable(System.Boolean)");
    set_LensDistortionSetting_method = GraphicsSetting_type_def:get_method("set_LensDistortionSetting(via.render.RenderConfig.LensDistortionSetting)");
    GraphicsSetting_cached = true;
end

local function apply_ws_setting()
    get_Instance_method:call(nil):set_field("_Stop", settings.disable_wind_simulation);
end

local function apply_gi_setting()
    local EnvironmentManager = sdk.get_managed_singleton("app.EnvironmentManager");
    if EnvironmentManager ~= nil then
        if get_DPGIComponent_method == nil then
            get_DPGIComponent_method = EnvironmentManager:get_type_definition():get_method("get_DPGIComponent");
        end
        local DPGIComponent = get_DPGIComponent_method:call(EnvironmentManager);
        if DPGIComponent ~= nil then
            if DPGI_set_Enabled_method == nil then
                DPGI_set_Enabled_method = DPGIComponent:get_type_definition():get_method("set_Enabled(System.Boolean)");
            end
            DPGI_set_Enabled_method:call(DPGIComponent, not settings.disable_global_illumination);
        end
    end
end

local function ApplySettings()
    local ToneMapping = get_component(ToneMapping_runtime_type);

    if ToneMapping ~= nil then
        setTemporalAA_method:call(ToneMapping, settings.TAA == true and Strong or Disable);
        set_EchoEnabled_method:call(ToneMapping, settings.jitter);
        set_EnableLocalExposure_method:call(ToneMapping, settings.localExposure);
        setLocalExposureType_method:call(ToneMapping, settings.localExposureBlurredLuminance == true and BlurredLuminance or Legacy);
        set_Contrast_method:call(ToneMapping, settings.customContrastEnable == true and settings.customContrast or settings.colorCorrect == false and 1.0 or 0.3);
    end

    local GraphicsManager = sdk.get_managed_singleton("app.GraphicsManager");
    if GraphicsManager_cached == false then
        getGraphicsManagerCache(GraphicsManager);
    end
    local DisplaySettings = get_DisplaySettings_method:call(GraphicsManager);
    if DisplaySettings_cached == false then
        getDisplaySettingsCache(DisplaySettings);
    end

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

    local NowGraphicsSetting = get_NowGraphicsSetting_method:call(GraphicsManager);
    if GraphicsSetting_cached == false then
        getGraphicsSettingCache(NowGraphicsSetting);
    end

    set_Fog_Enable_method:call(NowGraphicsSetting, settings.fog);
    set_VolumetricFogControl_Enable_method:call(NowGraphicsSetting, settings.volumetricFog);
    set_FilmGrain_Enable_method:call(NowGraphicsSetting, settings.filmGrain);
    set_LensFlare_Enable_method:call(NowGraphicsSetting, settings.lensFlare);
    set_GodRay_Enable_method:call(NowGraphicsSetting, settings.godRay);
    set_LensDistortionSetting_method:call(NowGraphicsSetting, settings.lensDistortionEnable == true and ON or OFF);

    if apply == true then
        setGraphicsSetting_method:call(GraphicsManager, NowGraphicsSetting);
    end
end

sdk.hook(Constants.CameraManager_type_def:get_method("onSceneLoadFadeIn"), nil, function()
    ApplySettings();
    apply_gi_setting();
end);

sdk.hook(ToneMapping_type_def:get_method("clearHistogram"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[1]);
end, function()
    set_EnableLocalExposure_method:call(thread.get_hook_storage()["this"], settings.localExposure);
end);

LoadSettings();
ApplySettings();
apply_ws_setting();
apply_gi_setting();

re.on_application_entry("LockScene", function()
    local LDRPostProcess = get_component(LDRPostProcess_runtime_type);
    if LDRPostProcess ~= nil then
        local ColorCorrect = get_ColorCorrect_method:call(LDRPostProcess);
        if ColorCorrect ~= nil then
            ColorCorrect_set_Enabled_method:call(ColorCorrect, settings.colorCorrect);
        end
    end
end);

re.on_config_save(SaveSettings);

re.on_draw_ui(function()
    if imgui.tree_node("Post Processing Settings") == true then
        local ws_changed = false;
        local gi_changed = false;
        local changed = false;
        local requireSave = false;

        imgui.push_style_color(21, 0xFF030380);
        changed = imgui.small_button("Save settings");
        if changed == true and requireSave ~= true then
            requireSave = true;
        end
        imgui.same_line();
        local loadGameDefaults = imgui.small_button("Load game defaults");
        if loadGameDefaults == true then
            LoadSettings(1);
            ApplySettings();
        end
        imgui.same_line();
        local loadSaved = imgui.small_button("Load saved settings");
        if loadSaved == true then
            LoadSettings();
            ApplySettings();
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
        local isReset = imgui.small_button("Reset gamma & brightness");
        imgui.pop_style_color(1);
        if isReset == true then
            ResetBrightness();
            ApplySettings();
        end
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
        apply = imgui.small_button("Apply graphics settings");
        imgui.pop_style_color(1);
        if apply == true then
            ApplySettings();
            apply = false;
        end
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
        ws_changed, settings.disable_wind_simulation = imgui.checkbox("Disable Wind Simulation", settings.disable_wind_simulation);
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("Huge performance improvement.\n\nThe vegetation and tissues sway will not longer\ndepend of the wind intensity and direction.");
        end
        gi_changed, settings.disable_global_illumination = imgui.checkbox("Disable Global Illumination", settings.disable_global_illumination);
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("Medium performance improvement.\n\nHighly deteriorate the visual quality.");
        end
        imgui.spacing();

        imgui.text("WARNING: applying graphics settings will set");
        imgui.text("ambient lighting to high due to a bug in the game");
        imgui.text("until returning to title or restarting the game");
        imgui.tree_pop();

        if requireSave == true then
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
    end
end);