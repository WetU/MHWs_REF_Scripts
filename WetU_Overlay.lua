local require = _G.require;
local draw = _G.draw;

local Constants = require("Constants/Constants");
local FacilityItems = require("WetU_Overlay/FacilityItems");
local MealInfo = require("WetU_Overlay/HunterMealEffect");
local QuestInfo = require("WetU_Overlay/QuestInfo");
local MoonTracker = require("WetU_Overlay/MoonTracker");

Constants.re.on_frame(function()
    local str = MealInfo.MealTimer ~= nil and "식사: " .. MealInfo.MealTimer or "";
    if FacilityItems.Rallus ~= nil then
        str = str ~= "" and str .. " | " .. "뜸부기: " .. FacilityItems.Rallus or "뜸부기: " .. FacilityItems.Rallus;
    end
    if MoonTracker.MoonState ~= nil then
        str = str ~= "" and str .. " | " .. MoonTracker.MoonState or MoonTracker.MoonState;
    end
    if str ~= "" then
        draw.text(str, 0, 1580, 0xFFFFFFFF);
    end

    if QuestInfo.QuestInfoCreated == true then
        draw.text(QuestInfo.QuestTimer .. "\n" .. QuestInfo.DeathCount, 3719, 257, 0xFFFFFFFF);
    end
end);