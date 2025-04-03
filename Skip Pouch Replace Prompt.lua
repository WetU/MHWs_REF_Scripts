local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI030201PartsPouch_type_def = sdk.find_type_definition("app.GUI030201PartsPouch");
local b__11_0_method = GUI030201PartsPouch_type_def:get_method("<cancelReplaceDialogue>b__11_0(System.Int32)");

local getNotifyWindowModule_method = sdk.find_type_definition("app.GUIManager"):get_method("getNotifyWindowModule");

local GUISystemModuleNotifyWindowApp_type_def = sdk.find_type_definition("app.cGUISystemModuleNotifyWindowApp");
local exists_method = GUISystemModuleNotifyWindowApp_type_def:get_method("exists(app.GUINotifyWindowDef.ID)");
local remove_method = GUISystemModuleNotifyWindowApp_type_def:get_method("remove(app.GUINotifyWindowDef.ID, System.Boolean)");

local GUI030201_DLG_04 = sdk.find_type_definition("app.GUINotifyWindowDef.ID"):get_field("GUI030201_DLG_04"):get_data(nil); -- static

sdk.hook(GUI030201PartsPouch_type_def:get_method("onOpen"), function(args)
	thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
	local WindowApp = getNotifyWindowModule_method:call(sdk.get_managed_singleton("app.GUIManager"));
	if exists_method:call(WindowApp, GUI030201_DLG_04) == true then
		remove_method:call(WindowApp, GUI030201_DLG_04, true);
		b__11_0_method:call(thread.get_hook_storage()["this"], 0);
	end
end);