local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local os = Constants.os;

local config = json.load_file("ShortcutAutoClose.json") or {enabled = true};

local startTime = nil;

local function saveConfig()
	json.dump_file("ShortcutAutoClose.json", config);
end

local GUI020600_type_def = sdk.find_type_definition("app.GUI020600");
local onHudClose_method = GUI020600_type_def:get_method("onHudClose");

local GUI020600 = nil;
sdk.hook(GUI020600_type_def:get_method("execute(System.Int32)"), function(args)
	if config.enabled == true then
		GUI020600 = sdk.to_managed_object(args[2]);
	end
end, function()
	if GUI020600 ~= nil then
		startTime = os.clock();
	end
end);

re.on_frame(function()
	if GUI020600 ~= nil and os.clock() - startTime >= 0.5 then
		onHudClose_method:call(GUI020600);
		GUI020600 = nil;
	end
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if imgui.tree_node("Shortcut Bar Auto Close###Shortcut_Bar") == true then
		local changed = false;
        changed, config.enabled = imgui.checkbox("Enabled", config.enabled);
		if changed == true then
			saveConfig();
		end
        imgui.tree_pop();
    end
end);