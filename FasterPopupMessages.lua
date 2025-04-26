local Constants = _G.require("Constants/Constants");
local json = Constants.json;
local imgui = Constants.imgui;
local re = Constants.re;
local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI000003_type_def = sdk.find_type_definition("app.GUI000003");
local DispMinTimer_field = GUI000003_type_def:get_field("_DispMinTimer");

local GUI010002_type_def = sdk.find_type_definition("app.GUI010002");
local requestClose_method = GUI010002_type_def:get_method("requestClose(System.Boolean)");

local GUINotifyWindowInfoApp_type_def = sdk.find_type_definition("app.cGUINotifyWindowInfoApp");
local get_NotifyWindowId_method = GUINotifyWindowInfoApp_type_def:get_method("get_NotifyWindowId");
local set_SelectedIndex_method = GUINotifyWindowInfoApp_type_def:get_method("set_SelectedIndex(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfoApp_type_def:get_method("executeWindowEndFunc");

local GUINotifyWindow_ID_GUI070000_DLG02 = sdk.find_type_definition("app.GUINotifyWindowDef.ID"):get_field("GUI070000_DLG02"):get_data(nil);

local config = json.load_file("FasterPopupMessages.json") or {
	enabled = true,
	longerWaits = false,
	newMinWait = 0.2
};

local treeTitle = config.newMinWait > 1.0 and "Slower Popup Messages###FasterPopupMessages" or "Faster Popup Messages###FasterPopupMessages";

local function saveConfig()
	json.dump_file("FasterPopupMessages.json", config);
end

local function getObj(args)
	if config.enabled == true then
		thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
	end
end

sdk.hook(GUI000003_type_def:get_method("setupDialog"), getObj, function()
	local GUI000003 = thread.get_hook_storage()["this"];
	if GUI000003 ~= nil and (config.longerWaits == true or DispMinTimer_field:get_data(GUI000003) > config.newMinWait) then
		GUI000003:set_field("_DispMinTimer", config.newMinWait);
	end
end);

sdk.hook(GUI010002_type_def:get_method("onOpen"), getObj, function()
	local GUI010002 = thread.get_hook_storage()["this"];
	if GUI010002 ~= nil then
		requestClose_method:call(GUI010002, false);
	end
end);

sdk.hook(sdk.find_type_definition("app.cGUISystemModuleNotifyWindowApp"):get_method("requestNotifyWindow(ace.cGUINotifyWindowInfo)"), function(args)
	local GUINotifyWindowInfoApp = sdk.to_managed_object(args[3]);
	if get_NotifyWindowId_method:call(GUINotifyWindowInfoApp) == GUINotifyWindow_ID_GUI070000_DLG02 then
		set_SelectedIndex_method:call(GUINotifyWindowInfoApp, 0);
		executeWindowEndFunc_method:call(GUINotifyWindowInfoApp);
		return sdk.PreHookResult.SKIP_ORIGINAL;
	end
end);

local function tooltip(msg)
	imgui.same_line();
	imgui.text("(?)");
	if imgui.is_item_hovered() == true then
		imgui.set_tooltip(msg.."\n ");
	end
end

re.on_config_save(saveConfig);

re.on_draw_ui(function()
	if imgui.tree_node(treeTitle) == true then
		local changed = false;
		local requireSave = false;
		local changedMinWait = false;
		changed, config.enabled = imgui.checkbox("Enabled", config.enabled);
		if changed == true and requireSave ~= true then
			requireSave = true;
		end
		changed, config.longerWaits = imgui.checkbox("Slower Popup Messages", config.longerWaits);
		if changed == true and requireSave ~= true then
			requireSave = true;
		end
		tooltip("Allows you to exceed the default minimum display time.\nYou don't actually want to do that, right??");
		imgui.text("New minimum display time:");
		changedMinWait, config.newMinWait = imgui.slider_float("##newMinWait", config.newMinWait, 0.0, config.longerWaits and 10.0 or 1.0, "%.1f");
		if config.newMinWait >= 10.0 then
			tooltip("Not enough? CTRL+Click to set a custom value!");
		end
		if changedMinWait == true then
			if requireSave ~= true then
				requireSave = true;
			end
			treeTitle = config.newMinWait > 1.0 and "Slower Popup Messages###FasterPopupMessages" or "Faster Popup Messages###FasterPopupMessages";
		end
		if requireSave == true then
			saveConfig();
		end
		imgui.tree_pop();
	end
end);