local require = _G.require;
local draw = _G.draw;

local Constants = require("Constants/Constants");
local FacilityItems = require("WetU_Overlay/FacilityItems");
local QuestInfo = require("WetU_Overlay/QuestInfo");

local re = Constants.re;

re.on_frame(function()
    if FacilityItems.Rallus ~= nil then
        draw.text("뜸부기: " .. FacilityItems.Rallus, 0, 1580, 0xFFFFFFFF);
    end

    if QuestInfo.QuestInfoCreated == true then
        draw.text(QuestInfo.QuestTimer .. "\n" .. QuestInfo.DeathCount, 3719, 257, 0xFFFFFFFF);
    end
end);