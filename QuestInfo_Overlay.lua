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

local Mandrake_type_def = sdk.find_type_definition("via.rds.Mandrake");

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
        local this_ptr = args[2];
        if get_IsActiveQuest_method:call(this_ptr) == true then
            QuestDirector_ptr = this_ptr;
        end
    elseif get_IsActiveQuest_method:call(QuestDirector_ptr) == false then
        QuestDirector_ptr = nil;
        if QuestInfoCreated == true then
            QuestInfoCreated = false;
            questMaxDeath = nil;
            questTimeLimit = nil;
            oldElapsedTime = nil;
        end
    end
end, function()
    if QuestDirector_ptr ~= nil then
        local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector_ptr);
        if QuestInfoCreated == false then
            local ActiveQuestData = get_QuestData_method:call(QuestDirector_ptr);
            questTimeLimit = tostring(getTimeLimit_method:call(ActiveQuestData)) .. "분";
            questMaxDeath = tostring(getQuestLife_method:call(ActiveQuestData));
            local QuestPlDieCount = sdk.get_native_field(QuestDirector_ptr, QuestDirector_type_def, "QuestPlDieCount");
            DeathCount = "다운 횟수: " .. tostring(math.floor(sdk.get_native_field(QuestPlDieCount, Mandrake_type_def, "v") / sdk.get_native_field(QuestPlDieCount, Mandrake_type_def, "m"))) .. " / " .. questMaxDeath;
            getQuestTimeInfo(QuestElapsedTime);
            QuestInfoCreated = true;
        elseif QuestElapsedTime ~= oldElapsedTime then
            getQuestTimeInfo(QuestElapsedTime);
        end
    end
end);

sdk.hook(QuestDirector_type_def:get_method("applyQuestPlDie(System.Int32, System.Boolean)"), nil, function()
    if QuestInfoCreated == true then
        local QuestPlDieCount = sdk.get_native_field(QuestDirector_ptr, QuestDirector_type_def, "QuestPlDieCount");
        DeathCount = "다운 횟수: " .. tostring(math.floor(sdk.get_native_field(QuestPlDieCount, Mandrake_type_def, "v") / sdk.get_native_field(QuestPlDieCount, Mandrake_type_def, "m"))) .. " / " .. questMaxDeath;
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