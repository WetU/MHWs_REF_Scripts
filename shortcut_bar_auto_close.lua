local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local config = json.load_file("ShortcutAutoClose.json") or {enabled = true};
if config.enabled == nil then
	config.enabled = true;
end

local function saveConfig()
	json.dump_file("ShortcutAutoClose.json", config);
end

sdk.hook(sdk.find_type_definition("app.GUI020600"):get_method("execute(System.Int32)"), function(args)
	if config.enabled == true then
		thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
	end
end, function()
	if config.enabled == true then
		local GUI020600 = thread.get_hook_storage()["this"];
		GUI020600:write_float(0x344, 0.5);
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