local Constants = _G.require("Constants/Constants");
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

local oldElapsedTime = nil;

local questMaxDeath = nil;
local questTimeLimit = nil;

local QuestInfo = {
    QuestInfoCreated = false,
    QuestTimer = nil,
    DeathCount = nil
};

sdk.hook(Constants.QuestDirector_type_def:get_method("update"), Constants.getObject, function()
    local QuestDirector = thread.get_hook_storage()["this"];
    if get_IsActiveQuest_method:call(QuestDirector) == true then
        if QuestInfo.QuestInfoCreated == false then
            local ActiveQuestData = get_QuestData_method:call(QuestDirector);
            questTimeLimit = tostring(getTimeLimit_method:call(ActiveQuestData)) .. "분";
            questMaxDeath = tostring(getQuestLife_method:call(ActiveQuestData));

            local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector);
            QuestInfo.DeathCount = "다운 횟수: " .. tostring(math.floor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount))) .. " / " .. questMaxDeath;

            local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector);
            oldElapsedTime = QuestElapsedTime;
            local seconds, miliseconds = math.modf(QuestElapsedTime % 60.0);
            QuestInfo.QuestTimer = string.format("%02d'%02d\"%02d", math.floor(QuestElapsedTime / 60.0), seconds, miliseconds > 0.0 and string.match(miliseconds, "%.(%d%d)") or 0) .. " / " .. questTimeLimit;

            QuestInfo.QuestInfoCreated = true;
        else
            local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector);
            if QuestElapsedTime ~= oldElapsedTime then
                oldElapsedTime = QuestElapsedTime;
                local seconds, miliseconds = math.modf(QuestElapsedTime % 60.0);
                QuestInfo.QuestTimer = string.format("%02d'%02d\"%02d", math.floor(QuestElapsedTime / 60.0), seconds, miliseconds > 0.0 and string.match(miliseconds, "%.(%d%d)") or 0) .. " / " .. questTimeLimit;
            end
        end
    else
        if QuestInfo.QuestInfoCreated == true then
            QuestInfo.QuestInfoCreated = false;

            questMaxDeath = nil;
            questTimeLimit = nil;

            oldElapsedTime = nil;
        end
    end
end);

sdk.hook(Constants.QuestDirector_type_def:get_method("applyQuestPlDie(System.Int32, System.Boolean)"), function(args)
    if QuestInfo.QuestInfoCreated == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    if QuestInfo.QuestInfoCreated == true then
        local QuestPlDieCount = QuestPlDieCount_field:get_data(thread.get_hook_storage()["this"]);
        QuestInfo.DeathCount = "다운 횟수: " .. tostring(math.floor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount))) .. " / " .. questMaxDeath;
    end
end);

return QuestInfo;