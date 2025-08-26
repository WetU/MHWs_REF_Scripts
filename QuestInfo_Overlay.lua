local Constants = _G.require("Constants/Constants");

local tostring = Constants.tostring;
local string = Constants.string;
local math = Constants.math;

local sdk = Constants.sdk;
local re = Constants.re;
local draw = Constants.draw;
local imgui = Constants.imgui;

local font = imgui.load_font(nil, 20);

local QuestDirector_type_def = Constants.QuestDirector_type_def;
local get_IsActiveQuest_method = QuestDirector_type_def:get_method("get_IsActiveQuest");
local get_QuestData_method = QuestDirector_type_def:get_method("get_QuestData");
local get_QuestElapsedTime_method = QuestDirector_type_def:get_method("get_QuestElapsedTime");
local QuestPlDieCount_field = QuestDirector_type_def:get_field("QuestPlDieCount");

local Mandrake_type_def = QuestPlDieCount_field:get_type();
local v_field = Mandrake_type_def:get_field("v");
local m_field = Mandrake_type_def:get_field("m");

local ActiveQuestData_type_def = Constants.ActiveQuestData_type_def;
local getTimeLimit_method = ActiveQuestData_type_def:get_method("getTimeLimit");
local getQuestLife_method = ActiveQuestData_type_def:get_method("getQuestLife");

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

local QuestDirector_ptr = nil;
sdk.hook(QuestDirector_type_def:get_method("update"), function(args)
    if QuestDirector_ptr == nil then
        QuestDirector_ptr = args[2];
    end
end, function()
    if get_IsActiveQuest_method:call(QuestDirector_ptr) == true then
        local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector_ptr);
        if QuestInfoCreated == false then
            QuestInfoCreated = true;
            local ActiveQuestData = get_QuestData_method:call(QuestDirector_ptr);
            questTimeLimit = tostring(getTimeLimit_method:call(ActiveQuestData)) .. "분";
            questMaxDeath = tostring(getQuestLife_method:call(ActiveQuestData));
            local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector_ptr);
            DeathCount = "다운 횟수: " .. tostring(math.floor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount))) .. " / " .. questMaxDeath;
            getQuestTimeInfo(QuestElapsedTime);
        elseif QuestElapsedTime ~= oldElapsedTime then
            getQuestTimeInfo(QuestElapsedTime);
        end
    elseif QuestInfoCreated == true then
        QuestInfoCreated = false;
        questMaxDeath = nil;
        questTimeLimit = nil;
        oldElapsedTime = nil;
    end
end);

sdk.hook(QuestDirector_type_def:get_method("applyQuestPlDie(System.Int32, System.Boolean)"), function(args)
    if QuestInfoCreated == true and QuestDirector_ptr == nil then
        QuestDirector_ptr = args[2];
    end
end, function()
    if QuestInfoCreated == true then
        local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector_ptr);
        DeathCount = "다운 횟수: " .. tostring(math.floor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount))) .. " / " .. questMaxDeath;
    end
end);

sdk.hook(QuestDirector_type_def:get_method("notifyQuestRetry"), nil, function()
    if QuestInfoCreated == true then
        DeathCount = "다운 횟수: 0 / " .. questMaxDeath;
    end
end);

re.on_frame(function()
    if QuestInfoCreated == true then
        imgui.push_font(font);
        draw.text(QuestTimer .. "\n" .. DeathCount, 3719, 257, 0xFFFFFFFF);
        imgui.pop_font();
    end
end);