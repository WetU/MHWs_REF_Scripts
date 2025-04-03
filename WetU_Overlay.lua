local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local tostring = Constants.tostring;
local string = Constants.string;
local math = Constants.math;

local HunterMealEffect_type_def = sdk.find_type_definition("app.cHunterMealEffect");
local get_DurationTimer_method = HunterMealEffect_type_def:get_method("get_DurationTimer");
local IsTimerActive_field = HunterMealEffect_type_def:get_field("_IsTimerActive");

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

local NO_CANTEEN = "식사 효과 없음";

local questInfoTbl = {
    oldDeathCount = nil,
    oldElapsedTime = nil,

    questInfoCreated = false,
    questMaxDeath = nil,
    questCurDeath = 0,
    questTimeLimit = nil,
    questCurTime = nil
};

local mealInfoTbl = {
    oldMealTimer = nil,
    mealTimer = NO_CANTEEN
};

local config = nil;

local function saveConfig()
    json.dump_file("WetU_Overlay.json", config);
end

local function loadConfig()
    config = json.load_file("WetU_Overlay.json") or {unLock = false};
    if config.unLock == nil then
        config.unLock = false;
    end
end

loadConfig();

local windowFlag = config.unLock == true and 4096 or (4096 + 64 + 512);

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

    if OldQuestPlDieCount ~= questInfoTbl.oldDeathCount then
        questInfoTbl.oldDeathCount = OldQuestPlDieCount;
        questInfoTbl.questCurDeath = OldQuestPlDieCount;
    end

    if QuestElapsedTime ~= questInfoTbl.oldElapsedTime then
        questInfoTbl.oldElapsedTime = QuestElapsedTime;
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
end, function()
    local QuestFailed = thread.get_hook_storage()["this"];

    if QuestFailedType_field:get_data(get_Param_method:call(QuestFailed)) == DEATH_COUNT_UP then
        if questInfoTbl.questMaxDeath == nil then
            questInfoTbl.questMaxDeath = tostring(getQuestLife_method:call(get_QuestData_method:call(get_Owner_method:call(QuestFailed))));
        end

        questInfoTbl.questCurDeath = questInfoTbl.questMaxDeath;
    end
end);

sdk.hook(QuestDirector_type_def:get_method("questInfoClear(System.Boolean, System.Boolean)"), nil, function()
    questInfoTbl.questInfoCreated = false;

    questInfoTbl.questMaxDeath = nil;
    questInfoTbl.questCurDeath = 0;
    questInfoTbl.questTimeLimit = nil;
    questInfoTbl.questCurTime = nil;

    questInfoTbl.oldDeathCount = nil;
    questInfoTbl.oldElapsedTime = nil;
end);

sdk.hook(HunterMealEffect_type_def:get_method("update(System.Single, app.HunterCharacter)"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    local HunterMealEffect = thread.get_hook_storage()["this"];
    if IsTimerActive_field:get_data(HunterMealEffect) == true then
        local timer = get_DurationTimer_method:call(HunterMealEffect);
        if timer ~= mealInfoTbl.oldMealTimer then
            mealInfoTbl.oldMealTimer = timer;
            mealInfoTbl.mealTimer = string.format("식사 타이머: %02d:%02d", math.floor(timer / 60.0), math.modf(timer % 60.0));
        end
    else
        if mealInfoTbl.mealTimer ~= NO_CANTEEN then
            mealInfoTbl.oldMealTimer = NO_CANTEEN;
            mealInfoTbl.mealTimer = NO_CANTEEN;
        end
    end
end);

re.on_config_save(saveConfig);

re.on_frame(function()
    if questInfoTbl.questInfoCreated == true and imgui.begin_window("퀘스트 정보", nil, windowFlag) == true then
        imgui.text(questInfoTbl.questCurTime .. " / " .. questInfoTbl.questTimeLimit);
        imgui.text("다운 횟수: " .. questInfoTbl.questCurDeath .. " / " .. questInfoTbl.questMaxDeath);
        imgui.end_window();
    end

    if imgui.begin_window("식사 정보", nil, windowFlag) == true then
        imgui.text(mealInfoTbl.mealTimer);
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