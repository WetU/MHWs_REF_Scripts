local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local get_WindBase_method = sdk.find_type_definition("app.GA"):get_method("get_WindBase"); -- static

local get_DPGIComponent_method = nil;
local DPGI_set_Enabled_method = nil;

local LiteEnvironment = {};

local settings = {
    disable_wind_simulation = true,
    disable_global_illumination = true
};

local function SaveSettings()
    json.dump_file("LiteEnvironment.json", settings);
end

local loadedTable = json.load_file("LiteEnvironment.json");
if loadedTable ~= nil then
    for key, value in pairs(loadedTable) do
        settings[key] = value;
    end
end

local WindBase = nil;
local function apply_ws_setting()
    if WindBase == nil then
        WindBase = get_WindBase_method:call(nil);
    end
    WindBase:set_field("_Stop", settings.disable_wind_simulation);
end

LiteEnvironment.apply_gi_setting = function()
    if Constants.EnvironmentManager == nil then
        Constants.EnvironmentManager = sdk.get_managed_singleton("app.EnvironmentManager");
    end
    if get_DPGIComponent_method == nil then
        get_DPGIComponent_method = Constants.EnvironmentManager.get_DPGIComponent;
        DPGI_set_Enabled_method = get_DPGIComponent_method:get_return_type():get_method("set_Enabled(System.Boolean)");
    end
    local DPGIComponent = get_DPGIComponent_method:call(Constants.EnvironmentManager);
    if DPGIComponent ~= nil then
        DPGI_set_Enabled_method:call(DPGIComponent, not settings.disable_global_illumination);
    end
end

apply_ws_setting();

re.on_config_save(SaveSettings);

re.on_draw_ui(function()
    if imgui.tree_node("Lite Environment") == true then
        local ws_changed = false;
        local gi_changed = false;
        ws_changed, settings.disable_wind_simulation = imgui.checkbox("Disable Wind Simulation", settings.disable_wind_simulation);
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("Huge performance improvement.\n\nThe vegetation and tissues sway will not longer\ndepend of the wind intensity and direction.");
        end
        gi_changed, settings.disable_global_illumination = imgui.checkbox("Disable Global Illumination", settings.disable_global_illumination);
        if imgui.is_item_hovered() == true then
            imgui.set_tooltip("Medium performance improvement.\n\nHighly deteriorate the visual quality.");
        end
        imgui.tree_pop();
        if ws_changed == true or gi_changed == true then
            SaveSettings();
            if ws_changed == true then
                apply_ws_setting();
            end
            if gi_changed == true then
                LiteEnvironment.apply_gi_setting();
            end
        end
    end
end);

return LiteEnvironment;