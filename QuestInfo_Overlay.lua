local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local re = Constants.re;
local draw = Constants.draw;

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

local oldElapsedTime = nil;

local questMaxDeath = nil;
local questTimeLimit = nil;

local QuestInfoCreated = false;
local QuestTimer = nil;
local DeathCount = nil;

local function getQuestTimeInfo(questElapsedTime)
    oldElapsedTime = questElapsedTime;
    local seconds, miliseconds = math.modf(questElapsedTime % 60.0);
    QuestTimer = string.format("%02d'%02d\"%02d", math.floor(questElapsedTime / 60.0), seconds, miliseconds > 0.0 and string.match(miliseconds, "%.(%d%d)") or 0) .. " / " .. questTimeLimit;
end

local QuestDirector = nil;
sdk.hook(Constants.QuestDirector_type_def:get_method("update"), function(args)
    if QuestDirector == nil then
        QuestDirector = sdk.to_managed_object(args[2]);
    end
end, function()
    if get_IsActiveQuest_method:call(QuestDirector) == true then
        local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector);
        if QuestInfoCreated == false then
            local ActiveQuestData = get_QuestData_method:call(QuestDirector);
            questTimeLimit = tostring(getTimeLimit_method:call(ActiveQuestData)) .. "분";
            questMaxDeath = tostring(getQuestLife_method:call(ActiveQuestData));

            local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector);
            DeathCount = "다운 횟수: " .. tostring(math.floor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount))) .. " / " .. questMaxDeath;

            getQuestTimeInfo(QuestElapsedTime);

            QuestInfoCreated = true;
        else
            if QuestElapsedTime ~= oldElapsedTime then
                getQuestTimeInfo(QuestElapsedTime);
            end
        end
    else
        if QuestInfoCreated == true then
            QuestInfoCreated = false;

            questMaxDeath = nil;
            questTimeLimit = nil;

            oldElapsedTime = nil;
        end
    end
end);

sdk.hook(Constants.QuestDirector_type_def:get_method("applyQuestPlDie(System.Int32, System.Boolean)"), function(args)
    if QuestInfoCreated == true and QuestDirector == nil then
        QuestDirector = sdk.to_managed_object(args[2]);
    end
end, function()
    if QuestInfoCreated == true then
        local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector);
        DeathCount = "다운 횟수: " .. tostring(math.floor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount))) .. " / " .. questMaxDeath;
    end
end);

sdk.hook(Constants.QuestDirector_type_def:get_method("notifyQuestRetry"), nil, function()
    if QuestInfoCreated == true then
        DeathCount = "다운 횟수: 0 / " .. questMaxDeath;
    end
end);

re.on_frame(function()
    if QuestInfoCreated == true then
        draw.text(QuestTimer .. "\n" .. DeathCount, 3719, 257, 0xFFFFFFFF);
    end
end);