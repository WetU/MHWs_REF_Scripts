local require = _G.require;

local Constants = require("Constants/Constants");
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local FacilityItems = require("WetU_Overlay/FacilityItems");
local MealInfo = require("WetU_Overlay/HunterMealEffect");
local QuestInfo = require("WetU_Overlay/QuestInfo");
local SpecialGimmick = require("WetU_Overlay/MapGimmickChecker");

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
    if QuestInfo.QuestInfoCreated == true and imgui.begin_window("퀘스트 정보", nil, windowFlag) == true then
        imgui.text(QuestInfo.QuestTimer .. "\n" .. QuestInfo.DeathCount);
        imgui.end_window();
    end

    if MealInfo.MealTimer ~= nil and imgui.begin_window("식사", nil, windowFlag) == true then
        imgui.text(MealInfo.MealTimer);
        imgui.end_window();
    end

    if FacilityItems.Rallus ~= nil and imgui.begin_window("시설", nil, windowFlag) == true then
        imgui.text(FacilityItems.Rallus);
        imgui.end_window();
    end

    if SpecialGimmick.PoppedGimmick ~= nil and imgui.begin_window("특별 채취", nil, windowFlag) == true then
        imgui.text(SpecialGimmick.PoppedGimmick);
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