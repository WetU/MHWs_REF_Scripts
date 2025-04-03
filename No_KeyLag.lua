local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local imgui = Constants.imgui;
local re = Constants.re;

local LaggedKey_type_def = sdk.find_type_definition("app.cLaggedKey");
local get_LagTime_method = LaggedKey_type_def:get_method("get_LagTime");
local set_LagTime_method = LaggedKey_type_def:get_method("set_LagTime(System.Single)");

local config = nil;

local function saveConfig()
    json.dump_file("NoKeyLag.json", config);
end

local function loadConfig()
    config = json.load_file("NoKeyLag.json") or {enable = true};
    if config.enable == nil then
        config.enable = true;
    end
end

loadConfig();

sdk.hook(LaggedKey_type_def:get_method("onCustomUpdate(System.Single)"), function(args)
    if config.enable == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    local LaggedKey = thread.get_hook_storage()["this"];
    if LaggedKey ~= nil and get_LagTime_method:call(LaggedKey) ~= 0.04 then
        set_LagTime_method:call(LaggedKey, 0.04);
    end
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if imgui.tree_node("No Key Lag") == true then
		local changed = false;
		changed, config.enable = imgui.checkbox("Enable", config.enable);

		if changed == true then
			saveConfig();
		end
		imgui.tree_pop();
	end
end);