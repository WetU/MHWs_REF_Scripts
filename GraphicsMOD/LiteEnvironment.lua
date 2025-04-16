local Constants = _G.require("Constants/Constants");
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local get_WindBase_method = Constants.GA_type_def:get_method("get_WindBase"); -- static

local get_Environment_method = Constants.GA_type_def:get_method("get_Environment"); -- static
local get_DPGIComponent_method = get_Environment_method:get_return_type():get_method("get_DPGIComponent");
local DPGI_set_Enabled_method = get_DPGIComponent_method:get_return_type():get_method("set_Enabled(System.Boolean)");

local LiteEnvironment = {};

local settings = {
    disable_wind_simulation = true,
    disable_global_illumination = true
};

local function SaveSettings()
    json.dump_file("LiteEnvironment.json", settings);
end

local function LoadSettings()
    local loadedTable = json.load_file("LiteEnvironment.json");
    if loadedTable ~= nil then
        for key, value in pairs(loadedTable) do
            settings[key] = value;
        end
    end
end

local function apply_ws_setting()
    local WindBase = get_WindBase_method:call(nil);
    if WindBase ~= nil then
        WindBase:set_field("_Stop", settings.disable_wind_simulation);
    end
end

LiteEnvironment.apply_gi_setting = function()
    local EnvironmentManager = get_Environment_method:call(nil);
    if EnvironmentManager ~= nil then
        local DPGIComponent = get_DPGIComponent_method:call(EnvironmentManager);
        if DPGIComponent ~= nil then
            DPGI_set_Enabled_method:call(DPGIComponent, not settings.disable_global_illumination);
        end
    end
end

LoadSettings();
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
        if ws_changed == true then
            SaveSettings();
            apply_ws_setting();
        end
        if gi_changed == true then
            SaveSettings();
            LiteEnvironment.apply_gi_setting();
        end
    end
end);

return LiteEnvironment;