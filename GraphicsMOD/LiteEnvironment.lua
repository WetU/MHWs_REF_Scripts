local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local set_Stop_method = sdk.find_type_definition("app.WindManager"):get_method("set_Stop(System.Boolean)");

local get_DPGIComponent_method = sdk.find_type_definition("app.EnvironmentManager"):get_method("get_DPGIComponent");
local set_Enabled_method = get_DPGIComponent_method:get_return_type():get_method("set_Enabled(System.Boolean)");

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

local function apply_ws_setting()
    if Constants.WindManager == nil then
        Constants.WindManager = sdk.get_managed_singleton("app.WindManager");
    end
    set_Stop_method:call(Constants.WindManager, settings.disable_wind_simulation);
end

local DPGIComponent = nil;
LiteEnvironment.apply_gi_setting = function()
    if DPGIComponent == nil then
        local EnvironmentManager = sdk.get_managed_singleton("app.EnvironmentManager");
        if EnvironmentManager ~= nil then
            DPGIComponent = get_DPGIComponent_method:call(EnvironmentManager);
        end
    end
    if DPGIComponent ~= nil then
        set_Enabled_method:call(DPGIComponent, not settings.disable_global_illumination);
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