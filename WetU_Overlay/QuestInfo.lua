local require = _G.require;

local Constants = require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local tostring = Constants.tostring;
local string = Constants.string;
local math = Constants.math;

local QuestPlaying_type_def = sdk.find_type_definition("app.cQuestPlaying");
local get_Owner_method = QuestPlaying_type_def:get_method("get_Owner");
local get_Param_method = QuestPlaying_type_def:get_method("get_Param");
local OldQuestPlDieCount_field = QuestPlaying_type_def:get_field("_OldQuestPlDieCount");

local QuestDirector_type_def = Constants.QuestDirector_type_def;
local get_QuestData_method = QuestDirector_type_def:get_method("get_QuestData");
local get_QuestElapsedTime_method = QuestDirector_type_def:get_method("get_QuestElapsedTime");
local get_QuestRemainTime_method = QuestDirector_type_def:get_method("get_QuestRemainTime");

local getQuestLife_method = get_QuestData_method:get_return_type():get_method("getQuestLife");

local QuestFailedType_field = get_Param_method:get_return_type():get_field("QuestFailedType");

local DEATH_COUNT_UP = sdk.find_type_definition("app.cQuestDirector.QUEST_FAILED_TYPE"):get_field("DEATH_COUNT_UP"):get_data(nil); -- static

local oldDeathCount = nil;
local oldElapsedTime = nil;

local questInfoTbl = {
    questInfoCreated = false,
    questMaxDeath = nil,
    questCurDeath = 0,
    questTimeLimit = nil,
    questCurTime = nil
};

sdk.hook(QuestPlaying_type_def:get_method("update"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    local QuestPlaying = thread.get_hook_storage()["this"];
    local QuestDirector = get_Owner_method:call(QuestPlaying);
    local OldQuestPlDieCount = OldQuestPlDieCount_field:get_data(QuestPlaying);
    local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector);

    if questInfoTbl.questMaxDeath == nil then
        questInfoTbl.questMaxDeath = tostring(getQuestLife_method:call(get_QuestData_method:call(QuestDirector)));
    end

    if OldQuestPlDieCount ~= oldDeathCount then
        oldDeathCount = OldQuestPlDieCount;
        questInfoTbl.questCurDeath = OldQuestPlDieCount;
    end

    if QuestElapsedTime ~= oldElapsedTime then
        oldElapsedTime = QuestElapsedTime;
        local seconds, miliseconds = math.modf(QuestElapsedTime % 60.0);
        questInfoTbl.questCurTime = string.format("%02d'%02d\"%02d", math.floor(QuestElapsedTime / 60.0), seconds, miliseconds > 0.0 and string.match(miliseconds, "%.(%d%d)") or 0);
    end

    if questInfoTbl.questTimeLimit == nil then
        questInfoTbl.questTimeLimit = string.format("%.0f분", (QuestElapsedTime + get_QuestRemainTime_method:call(QuestDirector)) / 60.0);
    end

    if questInfoTbl.questInfoCreated ~= true then
        questInfoTbl.questInfoCreated = true;
    end
end);

sdk.hook(sdk.find_type_definition("app.cQuestFailed"):get_method("enter"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function(retval)
    if (sdk.to_int64(retval) & 1) == 1 then
        local QuestFailed = thread.get_hook_storage()["this"];

        if QuestFailedType_field:get_data(get_Param_method:call(QuestFailed)) == DEATH_COUNT_UP then
            if questInfoTbl.questMaxDeath == nil then
                questInfoTbl.questMaxDeath = tostring(getQuestLife_method:call(get_QuestData_method:call(get_Owner_method:call(QuestFailed))));
            end

            questInfoTbl.questCurDeath = questInfoTbl.questMaxDeath;
        end
    end

    return retval;
end);

sdk.hook(QuestDirector_type_def:get_method("questInfoClear(System.Boolean, System.Boolean)"), nil, function()
    questInfoTbl.questInfoCreated = false;

    questInfoTbl.questMaxDeath = nil;
    questInfoTbl.questCurDeath = 0;
    questInfoTbl.questTimeLimit = nil;
    questInfoTbl.questCurTime = nil;

    oldDeathCount = nil;
    oldElapsedTime = nil;
end);

return questInfoTbl;