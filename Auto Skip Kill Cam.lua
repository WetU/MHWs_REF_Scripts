local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local config = nil;

local function loadConfig()
    config = json.load_file("AutoSkipKillCam.json") or {enableKillCam = true};
    if config.enableKillCam == nil then
        config.enableKillCam = true;
    end
end

local function saveConfig()
    json.dump_file("AutoSkipKillCam.json", config);
end

loadConfig();

sdk.hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), nil, function(retval)
    return config.enableKillCam == true and Constants.FALSE_ptr or retval;
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
    if imgui.tree_node("Auto Skip Kill Cam") == true then
		local changed = false;
		changed, config.enableKillCam = imgui.checkbox("Enable Skip Kill-Cam", config.enableKillCam);
        if changed == true then
            saveConfig();
        end
		imgui.tree_pop();
	end
end);