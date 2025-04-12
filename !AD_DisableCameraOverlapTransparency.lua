local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local imgui = Constants.imgui;
local re = Constants.re;

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
local config = default_config;

local function saveConfig()
    json.dump_file("DisableCameraOverlapTransparency.json", config);
end

local function loadConfig()
    config = json.load_file("DisableCameraOverlapTransparency.json");
end

loadConfig();

local MasterPlCamera_field = Constants.CameraManager_type_def:get_field("_MasterPlCamera");
local MiniComponents_field = MasterPlCamera_field:get_type():get_field("_MiniComponents");
local AdjustCollision_field = MiniComponents_field:get_type():get_field("AdjustCollision");
local SettingParam_field = AdjustCollision_field:get_type():get_field("_SettingParam");

local CameraOverlapTransparencyControllerBase_type_def = sdk.find_type_definition("app.CameraOverlapTransparencyControllerBase");
local IsDeactivateTrigger_field = CameraOverlapTransparencyControllerBase_type_def:get_field("_IsDeactivateTrigger");

local function ApplyCameraSettings()
	local MasterPlCamera = MasterPlCamera_field:get_data(sdk.get_managed_singleton("app.CameraManager"));
	if MasterPlCamera ~= nil then
		local MiniComponents = MiniComponents_field:get_data(MasterPlCamera);
		if MiniComponents ~= nil then
			local AdjustCollision = AdjustCollision_field:get_data(MiniComponents);
			if AdjustCollision ~= nil then
				local SettingParam = SettingParam_field:get_data(AdjustCollision);
				if SettingParam ~= nil then
					SettingParam:set_field("OverNear_NearestDistance", config.OverNear_NearestDistance);
					SettingParam:set_field("OverNear_NearestHeight", config.OverNear_NearestHeight);
					SettingParam:set_field("OverNear_Alpha_Near", config.OverNear_Alpha);
					SettingParam:set_field("OverNear_Alpha_Far", config.OverNear_Alpha);
				end
			end
		end
	end
end

sdk.hook(CameraOverlapTransparencyControllerBase_type_def:get_method("update"), Constants.getObject, function()
	local CameraOverlapTransparencyControllerBase = thread.get_hook_storage()["this"];
	if IsDeactivateTrigger_field:get_data(CameraOverlapTransparencyControllerBase) ~= true then
		CameraOverlapTransparencyControllerBase:set_field("_IsDeactivateTrigger", true);
	end
end);
sdk.hook(Constants.CameraManager_type_def:get_method("onSceneLoadFadeIn"), nil, ApplyCameraSettings);

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

		if requireSave == true then
			ApplyCameraSettings();
			saveConfig();
		end

		imgui.tree_pop();
	end
end)