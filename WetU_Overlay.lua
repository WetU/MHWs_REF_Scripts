local require = _G.require;

local Constants = require("Constants/Constants");
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local FacilityItems = require("WetU_Overlay/FacilityItems");
local MealInfo = require("WetU_Overlay/HunterMealEffect");
local QuestInfo = require("WetU_Overlay/QuestInfo");
local MoonTracker = require("WetU_Overlay/MoonTracker");

local windowFlag = 4096 + 64 + 512;
local config = json.load_file("WetU_Overlay.json") or {unLock = false};;
if config.unLock == nil then
    config.unLock = false;
elseif config.unLock == true then
    windowFlag = 4096;
end

local function saveConfig()
    json.dump_file("WetU_Overlay.json", config);
end

re.on_config_save(saveConfig);

re.on_frame(function()
    local str = "";
    if MealInfo.MealTimer ~= nil then
        str = "식사: " .. MealInfo.MealTimer;
    end
    if FacilityItems.Rallus ~= nil then
        if str ~= "" then
            str = str .. " | ";
        end
        str = str .. "뜸부기: " .. FacilityItems.Rallus;
    end
    if MoonTracker.MoonState ~= nil then
        if str ~= "" then
            str = str .. " | ";
        end
        str = str .. MoonTracker.MoonState;
    end
    if str ~= "" then
        imgui.begin_window("정보", nil, windowFlag);
        imgui.text(str);
        imgui.end_window();
    end

    if QuestInfo.QuestInfoCreated == true then
        imgui.begin_window("퀘스트 정보", nil, windowFlag);
        imgui.text(QuestInfo.QuestTimer .. "\n" .. QuestInfo.DeathCount);
        imgui.end_window();
    end
end);

re.on_draw_ui(function()
    if imgui.tree_node("WetU_Overlay") == true then
		local changed = false;
		changed, config.unLock = imgui.checkbox("Unlock Panel", config.unLock);
		if changed == true then
			saveConfig();
            windowFlag = config.unLock == true and 4096 or (4096 + 64 + 512);
		end
		imgui.tree_pop();
	end
end);