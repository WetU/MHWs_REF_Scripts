local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
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
local config = json.load_file("DisableCameraOverlapTransparency.json") or default_config;

local function saveConfig()
    json.dump_file("DisableCameraOverlapTransparency.json", config);
end

local MasterPlCamera_field = Constants.CameraManager_type_def:get_field("_MasterPlCamera");
local get_Collision_method = MasterPlCamera_field:get_type():get_method("get_Collision");

local ThirdPersonCollision_type_def = get_Collision_method:get_return_type();
local SettingParam_field = ThirdPersonCollision_type_def:get_field("_SettingParam");
local AdjusterEm_field = ThirdPersonCollision_type_def:get_field("_AdjusterEm");

local set_NearestDistance_method = AdjusterEm_field:get_type():get_method("set_NearestDistance(System.Single)");

local function Apply()
	local MasterPlCamera = MasterPlCamera_field:get_data(Constants.CameraManager);
	if MasterPlCamera ~= nil then
		local Collision = get_Collision_method:call(MasterPlCamera);
		local SettingParam = SettingParam_field:get_data(Collision);
		local AdjusterEm = AdjusterEm_field:get_data(Collision);
		SettingParam:set_field("OverNear_NearestDistance", config.OverNear_NearestDistance);
		SettingParam:set_field("OverNear_NearestHeight", config.OverNear_NearestHeight);
		SettingParam:set_field("OverNear_Alpha_Near", config.OverNear_Alpha);
		SettingParam:set_field("OverNear_Alpha_Far", config.OverNear_Alpha);

		set_NearestDistance_method:call(AdjusterEm, config.OverNear_NearestDistance);
	end
end

Apply();

sdk.hook(sdk.find_type_definition("app.PlayerCameraController"):get_method("onStartCameraController"), nil, Apply);

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
			if Constants.CameraManager == nil then
				Constants.CameraManager = sdk.get_managed_singleton("app.CameraManager");
			end
			Apply();
			saveConfig();
		end
	end
end);