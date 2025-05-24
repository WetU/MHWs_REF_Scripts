local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local get_UpTimeSecond_method = sdk.find_type_definition("via.Application"):get_method("get_UpTimeSecond"); -- static

local GUI020600_type_def = sdk.find_type_definition("app.GUI020600");
local onHudClose_method = GUI020600_type_def:get_method("onHudClose");

local config = json.load_file("ShortcutAutoClose.json") or {enabled = true};
if config.enabled == nil then
	config.enabled = true;
end

local function saveConfig()
	json.dump_file("ShortcutAutoClose.json", config);
end

local GUI020600 = nil;
local startTime = nil;
sdk.hook(GUI020600_type_def:get_method("execute(System.Int32)"), function(args)
	if config.enabled == true then
		GUI020600 = sdk.to_managed_object(args[2]);
	end
end, function()
	if config.enabled == true then
		startTime = get_UpTimeSecond_method:call(nil);
	end
end);

re.on_frame(function()
	if startTime ~= nil and get_UpTimeSecond_method:call(nil) - startTime >= 0.5 then
		onHudClose_method:call(GUI020600);
		GUI020600 = nil;
		startTime = nil;
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