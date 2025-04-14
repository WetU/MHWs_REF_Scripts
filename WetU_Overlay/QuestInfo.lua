local require = _G.require;

local Constants = require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local tostring = Constants.tostring;
local string = Constants.string;
local math = Constants.math;

local get_IsActiveQuest_method = Constants.QuestDirector_type_def:get_method("get_IsActiveQuest");
local get_QuestData_method = Constants.QuestDirector_type_def:get_method("get_QuestData");
local get_QuestElapsedTime_method = Constants.QuestDirector_type_def:get_method("get_QuestElapsedTime");
local QuestPlDieCount_field = Constants.QuestDirector_type_def:get_field("QuestPlDieCount");

local Mandrake_type_def = QuestPlDieCount_field:get_type();
local v_field = Mandrake_type_def:get_field("v");
local m_field = Mandrake_type_def:get_field("m");

local getTimeLimit_method = Constants.ActiveQuestData_type_def:get_method("getTimeLimit");
local getQuestLife_method = Constants.ActiveQuestData_type_def:get_method("getQuestLife");

local oldDeathCount = 0.0;
local oldElapsedTime = nil;

local questMaxDeath = nil;
local questCurDeath = "0";
local questTimeLimit = nil;
local questCurTime = nil;

local questInfoTbl = {
    questInfoCreated = false,
    questTime = nil,
    deathCount = nil
};

sdk.hook(Constants.QuestDirector_type_def:get_method("update"), Constants.getObject, function()
    local QuestDirector = thread.get_hook_storage()["this"];
    if get_IsActiveQuest_method:call(QuestDirector) == true then
        local deathUpdated = false;
        local timeUpdated = false;

        if questMaxDeath == nil or questTimeLimit == nil then
            local ActiveQuestData = get_QuestData_method:call(QuestDirector);
            questMaxDeath = tostring(getQuestLife_method:call(ActiveQuestData));
            questTimeLimit = tostring(getTimeLimit_method:call(ActiveQuestData)) .. "분";
            deathUpdated = true;
            timeUpdated = true;
        end

        local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector);
        local dieCount = v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount);
        if dieCount ~= oldDeathCount then
            oldDeathCount = dieCount;
            questCurDeath = tostring(math.floor(dieCount));
            deathUpdated = true;
        end

        local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector);
        if QuestElapsedTime ~= oldElapsedTime then
            oldElapsedTime = QuestElapsedTime;
            local seconds, miliseconds = math.modf(QuestElapsedTime % 60.0);
            questCurTime = string.format("%02d'%02d\"%02d", math.floor(QuestElapsedTime / 60.0), seconds, miliseconds > 0.0 and string.match(miliseconds, "%.(%d%d)") or 0);
            timeUpdated = true;
        end

        if deathUpdated == true then
            questInfoTbl.deathCount = "다운 횟수: " .. questCurDeath .. " / " .. questMaxDeath;
        end
        if timeUpdated == true then
            questInfoTbl.questTime = questCurTime .. " / " .. questTimeLimit;
        end

        if questInfoTbl.questInfoCreated ~= true then
            questInfoTbl.questInfoCreated = true;
        end
    end
end);

sdk.hook(Constants.QuestDirector_type_def:get_method("questInfoClear(System.Boolean, System.Boolean)"), nil, function()
    questInfoTbl.questInfoCreated = false;

    questMaxDeath = nil;
    questCurDeath = "0";
    questTimeLimit = nil;
    questCurTime = nil;

    oldDeathCount = 0.0;
    oldElapsedTime = nil;
end);

return questInfoTbl;