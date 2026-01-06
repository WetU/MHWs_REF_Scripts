local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;
local pairs = Constants.pairs;
local tostring = Constants.tostring;
local tonumber = Constants.tonumber;

local mathmodf = Constants.mathmodf;
local mathfloor = Constants.mathfloor;

local strmatch = Constants.strmatch;
local strformat = Constants.strformat;

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_int64 = Constants.to_int64;
local to_valuetype = Constants.to_valuetype;

local get_hook_storage = Constants.get_hook_storage;

local push_font = Constants.push_font;
local pop_font = Constants.pop_font;

local on_frame = Constants.on_frame;

local drawtext = Constants.drawtext;

local font = Constants.load_font(nil, 20);

local QuestDirector_type_def = Constants.QuestDirector_type_def;
local get_IsActiveQuest_method = QuestDirector_type_def:get_method("get_IsActiveQuest");
local get_QuestData_method = QuestDirector_type_def:get_method("get_QuestData");
local get_QuestElapsedTime_method = QuestDirector_type_def:get_method("get_QuestElapsedTime");
local QuestPlDieCount_field = QuestDirector_type_def:get_field("QuestPlDieCount");

local Mandrake_type_def = QuestPlDieCount_field:get_type();
local v_field = Mandrake_type_def:get_field("v");
local m_field = Mandrake_type_def:get_field("m");

local ActiveQuestData_type_def = get_QuestData_method:get_return_type();
local getTimeLimit_method = ActiveQuestData_type_def:get_method("getTimeLimit");
local getQuestLife_method = ActiveQuestData_type_def:get_method("getQuestLife");

local SlingerExCharge_type_def = find_type_definition("app.HunterStatusWatchers.cSlingerExCharge");
local IsChargeMax_field = SlingerExCharge_type_def:get_field("_IsChargeMax");

local getHunterCharacter_method = find_type_definition("app.GUIActionGuideParamGetter"):get_method("getHunterCharacter"); -- static

local HunterCharacter_type_def = getHunterCharacter_method:get_return_type();
local get_IsMaster_method = HunterCharacter_type_def:get_method("get_IsMaster");
local get_HunterStatus_method = HunterCharacter_type_def:get_method("get_HunterStatus");

local get_AttackPower_method = get_HunterStatus_method:get_return_type():get_method("get_AttackPower");

local HunterAttackPower_type_def = get_AttackPower_method:get_return_type();
local get_AttibuteType_method = HunterAttackPower_type_def:get_method("get_AttibuteType");

local WeaponAttr = {};
for _, v in ipairs(get_AttibuteType_method:get_return_type():get_fields()) do
    if v:is_static() == true then
        local name = v:get_name();
        if name == "NONE" then
            WeaponAttr["무속성"] = v:get_data(nil);
        elseif name == "FIRE" then
            WeaponAttr["불속성"] = v:get_data(nil);
        elseif name == "WATER" then
            WeaponAttr["물속성"] = v:get_data(nil);
        elseif name == "ICE" then
            WeaponAttr["얼음속성"] = v:get_data(nil);
        elseif name == "ELEC" then
            WeaponAttr["번개속성"] = v:get_data(nil);
        elseif name == "DRAGON" then
            WeaponAttr["용속성"] = v:get_data(nil);
        elseif name == "POISON" then
            WeaponAttr["독속성"] = v:get_data(nil);
        elseif name == "PARALYSE" then
            WeaponAttr["마비속성"] = v:get_data(nil);
        elseif name == "SLEEP" then
            WeaponAttr["수면속성"] = v:get_data(nil);
        elseif name == "BLAST" then
            WeaponAttr["폭파속성"] = v:get_data(nil);
        end
    end
end

local oldElapsedTime = nil;
local oldWeaponAttr = nil;

local curDeathCount = nil;
local questMaxDeath = nil;
local questTimeLimit = nil;

local QuestInfoCreated = false;
local QuestTimer = nil;
local curWeaponAttr = "";
local slingerChargeMax = "";

local QuestDirector_ptr = nil;
local Hunter_AttackPower = nil;

local function getWeaponAttr(attr)
    if oldWeaponAttr ~= attr then
        oldWeaponAttr = attr;
        if attr ~= nil then
            for k, v in pairs(WeaponAttr) do
                if attr == v then
                    curWeaponAttr = k;
                    break;
                end
            end
        elseif curWeaponAttr ~= "" then
            curWeaponAttr = "";
        end
    end
end

local function getQuestTimeInfo(questElapsedTime)
    oldElapsedTime = questElapsedTime;
    local second, milisecond = mathmodf(questElapsedTime % 60.0);
    QuestTimer = strformat("%02d'%02d\"%02d", mathfloor(questElapsedTime / 60.0), second, milisecond ~= 0.0 and tonumber(strmatch(tostring(milisecond), "%.(%d%d)")) or 0) .. " / " .. questTimeLimit;
end

local isMaster = nil;
hook(SlingerExCharge_type_def:get_method("onUpdate(app.cHunterStatusWatcherBase.UPDATE_ARG)"), function(args)
    if QuestInfoCreated and get_IsMaster_method:call(Character_field:get_data(to_valuetype(args[3], UPDATE_ARG_type_def))) then
        get_hook_storage().this_ptr = args[2];
        isMaster = true;
    end
end, function()
    if isMaster then
        isMaster = nil;
        local IsChargeMax = IsChargeMax_field:get_data(get_hook_storage().this_ptr);
        log.debug(tostring(IsChargeMax));
        if IsChargeMax then
            slingerChargeMax = "슬링어 풀차지";
        elseif slingerChargeMax ~= "" then
            slingerChargeMax = "";
        end
    end
end);

hook(HunterAttackPower_type_def:get_method("setWeaponAttackPower(app.cHunterCreateInfo)"), nil, function()
    if QuestInfoCreated then
        getWeaponAttr(get_AttibuteType_method:call(Hunter_AttackPower));
    end
end);

hook(QuestDirector_type_def:get_method("update"), function(args)
    if not QuestDirector_ptr then
        local this_ptr = args[2];
        if get_IsActiveQuest_method:call(this_ptr) then
            QuestDirector_ptr = this_ptr;
        end
    elseif not get_IsActiveQuest_method:call(QuestDirector_ptr) then
        QuestDirector_ptr = nil;
        if QuestInfoCreated then
            QuestInfoCreated = false;
            if slingerChargeMax ~= "" then
                slingerChargeMax = "";
            end
        end
    end
end, function()
    if QuestDirector_ptr ~= nil then
        local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector_ptr);
        if not QuestInfoCreated then
            local ActiveQuestData = get_QuestData_method:call(QuestDirector_ptr);
            questTimeLimit = tostring(getTimeLimit_method:call(ActiveQuestData)) .. "분";
            questMaxDeath = tostring(getQuestLife_method:call(ActiveQuestData));
            local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector_ptr);
            curDeathCount = mathfloor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount));
            getQuestTimeInfo(QuestElapsedTime);
            Hunter_AttackPower = get_AttackPower_method:call(get_HunterStatus_method:call(getHunterCharacter_method:call(nil)));
            getWeaponAttr(get_AttibuteType_method:call(Hunter_AttackPower));
            QuestInfoCreated = true;
        elseif QuestElapsedTime ~= oldElapsedTime then
            getQuestTimeInfo(QuestElapsedTime);
        end
    end
end);

hook(QuestDirector_type_def:get_method("applyQuestPlDie(System.Int32, System.Boolean)"), function(args)
    if QuestInfoCreated and (to_int64(args[4]) & 1) == 0 then
        curDeathCount = curDeathCount + 1;
    end
end);

hook(QuestDirector_type_def:get_method("notifyQuestRetry"), nil, function()
    if QuestInfoCreated then
        curDeathCount = 0;
    end
end);

on_frame(function()
    if QuestInfoCreated then
        push_font(font);
        drawtext(slingerChargeMax .. "\n" .. curWeaponAttr .. "\n" .. QuestTimer .. "\n" .. "다운 횟수: " .. tostring(curDeathCount) .. " / " .. questMaxDeath, 3719, 234, 0xFFFFFFFF);
        pop_font();
    end
end);