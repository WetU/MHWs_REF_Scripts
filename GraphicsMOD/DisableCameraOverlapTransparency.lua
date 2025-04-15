local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local json = Constants.json;
local imgui = Constants.imgui;
local re = Constants.re;

local DisableCameraOverlapTransparency = {};

local default_config = {
	OverNear_NearestDistance = 4.2,
	OverNear_NearestHeight = 1.4,
	OverNear_Alpha = 0.35
};
local preset_config = {
	OverNear_NearestDistance = 10.0,
	OverNear_NearestHeight = 1.4,
	OverNear_Alpha = 1.0
};
local config = nil;

local function saveConfig()
    json.dump_file("DisableCameraOverlapTransparency.json", config);
end

local function loadConfig()
    config = json.load_file("DisableCameraOverlapTransparency.json") or default_config;
end

loadConfig();

local MasterPlCamera_field = Constants.CameraManager_type_def:get_field("_MasterPlCamera");
local MiniComponents_field = MasterPlCamera_field:get_type():get_field("_MiniComponents");
local AdjustCollision_field = MiniComponents_field:get_type():get_field("AdjustCollision");
local SettingParam_field = AdjustCollision_field:get_type():get_field("_SettingParam");

local CameraOverlapTransparencyControllerBase_type_def = sdk.find_type_definition("app.CameraOverlapTransparencyControllerBase");
local IsDeactivateTrigger_field = CameraOverlapTransparencyControllerBase_type_def:get_field("_IsDeactivateTrigger");

DisableCameraOverlapTransparency.Apply = function(cameraManager)
	local MasterPlCamera = MasterPlCamera_field:get_data(cameraManager);
	if MasterPlCamera ~= nil then
		local SettingParam = SettingParam_field:get_data(AdjustCollision_field:get_data(MiniComponents_field:get_data(MasterPlCamera)));
		SettingParam:set_field("OverNear_NearestDistance", config.OverNear_NearestDistance);
		SettingParam:set_field("OverNear_NearestHeight", config.OverNear_NearestHeight);
		SettingParam:set_field("OverNear_Alpha_Near", config.OverNear_Alpha);
		SettingParam:set_field("OverNear_Alpha_Far", config.OverNear_Alpha);
	end
end

sdk.hook(CameraOverlapTransparencyControllerBase_type_def:get_method("update"), Constants.getObject, function()
	local CameraOverlapTransparencyControllerBase = Constants.thread.get_hook_storage()["this"];
	if IsDeactivateTrigger_field:get_data(CameraOverlapTransparencyControllerBase) ~= true then
		CameraOverlapTransparencyControllerBase:set_field("_IsDeactivateTrigger", true);
	end
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
	if imgui.tree_node("Disable Camera Overlap Transparency") == true then
		local changed = false;
		local requireSave = false;
		imgui.begin_group();
		imgui.text("--------------  CameraSettings(Boss Fight)  --------------");
		imgui.text("Closest <--MinCameraDistance--> Farthest")
		changed, config.OverNear_NearestDistance = imgui.slider_float("Distance##DCOT_OverNear_NearestDistance", config.OverNear_NearestDistance, 0.0, 10.0);
		if changed == true and requireSave ~= true then
			requireSave = true;
		end
		imgui.new_line();
		imgui.text("Lowest <---MinCameraHeight---> Highest");
		changed, config.OverNear_NearestHeight = imgui.slider_float("Height##DCOT_OverNear_NearestHeight", config.OverNear_NearestHeight, 0.0, 1.4);
		if changed == true and requireSave ~= true then
			requireSave = true;
		end
		imgui.new_line();
		imgui.text("Invisible  <------------Alpha------------>  Fully Visible");
		changed, config.OverNear_Alpha = imgui.slider_float("Alpha##OverNear_Alpha_Near", config.OverNear_Alpha, 0.0, 1.0);
		if changed == true and requireSave ~= true then
			requireSave = true;
		end
		imgui.push_style_color(21, 0xFFFF8000);
		if imgui.button("Reset Default##ResetDefault_Button") == true then
			config = default_config;
			requireSave = true;
		end
		imgui.same_line();
		if imgui.button("Load Preset##LoadPreset_Button") == true then
			config = preset_config;
			requireSave = true;
		end
		imgui.pop_style_color(1);
		imgui.end_group();
		imgui.tree_pop();

		if requireSave == true then
			local MasterPlCamera = MasterPlCamera_field:get_data(Constants.get_Camera_method:call(nil));
			if MasterPlCamera ~= nil then
				local SettingParam = SettingParam_field:get_data(AdjustCollision_field:get_data(MiniComponents_field:get_data(MasterPlCamera)));
				SettingParam:set_field("OverNear_NearestDistance", config.OverNear_NearestDistance);
				SettingParam:set_field("OverNear_NearestHeight", config.OverNear_NearestHeight);
				SettingParam:set_field("OverNear_Alpha_Near", config.OverNear_Alpha);
				SettingParam:set_field("OverNear_Alpha_Far", config.OverNear_Alpha);
			end
			saveConfig();
		end
	end
end);

return DisableCameraOverlapTransparency;