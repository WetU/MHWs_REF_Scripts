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

local get_hook_storage = Constants.get_hook_storage;

local push_font = Constants.push_font;
local pop_font = Constants.pop_font;

local drawtext = Constants.drawtext;

local ZERO_float_ptr = Constants.ZERO_float_ptr;

local skipOriginal = Constants.skipOriginal;

local font = Constants.load_font(nil, 20);

local get_PlParam_method = Constants.get_PlParam_method;

local PlayerGlobalParam_type_def = get_PlParam_method:get_return_type();
local get_ExChargeSlingerSpeedRate_method = PlayerGlobalParam_type_def:get_method("get_ExChargeSlingerSpeedRate");

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

local StrongSlingerShoot_type_def = find_type_definition("app.PlayerCommonAction.cStrongSlingerShoot");
local Phase_field = StrongSlingerShoot_type_def:get_field("_Phase");
local AmmoType_field = StrongSlingerShoot_type_def:get_field("_AmmoType");
local ChargeTimer_field = StrongSlingerShoot_type_def:get_field("_ChargeTimer");
local get_Chara_method = StrongSlingerShoot_type_def:get_parent_type():get_parent_type():get_parent_type():get_method("get_Chara");

local get_IsMaster_method = get_Chara_method:get_return_type():get_method("get_IsMaster");

local SHOOT = Phase_field:get_type():get_field("SHOOT"):get_data(nil);

local END = find_type_definition("ace.ActionDef.UPDATE_RESULT"):get_field("END"):get_data(nil);

local EX_CHARGE = find_type_definition("app.HunterDef.SLINGER_AMMO_TYPE"):get_field("EX_CHARGE"):get_data(nil);

local getHunterStatus_method = Constants.FacilitySupplyItems_type_def:get_method("getHunterStatus"); -- static

local HunterStatus_type_def = getHunterStatus_method:get_return_type();
local get_AttackPower_method = HunterStatus_type_def:get_method("get_AttackPower");

local get_AttibuteType_method = get_AttackPower_method:get_return_type():get_method("get_AttibuteType");

local WeaponAttr = {};
do
    for _, v in ipairs(get_AttibuteType_method:get_return_type():get_fields()) do
        if v:is_static() then
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
end

local maxSlingerChargeTime = nil;

local oldElapsedTime = nil;
local oldWeaponAttr = nil;

local curDeathCount = nil;
local questMaxDeath = nil;
local questTimeLimit = nil;

local QuestInfoCreated = false;
local QuestTimer = nil;
local curWeaponAttr = nil;
local slingerChargeMax = nil;

local QuestDirector_ptr = nil;

local function postHook_getTimes()
    return ZERO_float_ptr;
end

local function getWeaponAttr(attr)
    if attr == nil then
        if curWeaponAttr ~= "" then
            curWeaponAttr = "";
        end
    elseif oldWeaponAttr ~= attr then
        oldWeaponAttr = attr;
        for k, v in pairs(WeaponAttr) do
            if attr == v then
                curWeaponAttr = k;
                break;
            end
        end
    end
end

local function getQuestTimeInfo(questElapsedTime)
    oldElapsedTime = questElapsedTime;
    local second, milisecond = mathmodf(questElapsedTime % 60.0);
    QuestTimer = strformat("%02d'%02d\"%02d", mathfloor(questElapsedTime / 60.0), second, milisecond ~= 0.0 and tonumber(strmatch(tostring(milisecond), "%.(%d%d)")) or 0);
end

local isMasterPlayerShootUpdate = nil;
local function SlingerCharge_preHook(args)
    if QuestInfoCreated then
        local this_ptr = args[2];
        if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) and AmmoType_field:get_data(this_ptr) == EX_CHARGE then
            get_hook_storage().this_ptr = this_ptr;
            isMasterPlayerShootUpdate = true;
        end
    end
end

local function SlingerCharge_postHook()
    local this_ptr = get_hook_storage().this_ptr;
    if Phase_field:get_data(this_ptr) == SHOOT then
        if slingerChargeMax ~= "" then
            slingerChargeMax = "";
        end
    else
        local ChargeTimer = ChargeTimer_field:get_data(this_ptr);
        if ChargeTimer == nil then
            if slingerChargeMax ~= "" then
                slingerChargeMax = "";
            end
        elseif ChargeTimer >= maxSlingerChargeTime and slingerChargeMax ~= "슬링어 풀차지" then
            slingerChargeMax = "슬링어 풀차지";
        end
    end
end

hook(StrongSlingerShoot_type_def:get_method("doEnter"), SlingerCharge_preHook, function(retval)
    if isMasterPlayerShootUpdate then
        isMasterPlayerShootUpdate = nil;
        SlingerCharge_postHook();
    end
    return retval;
end);

hook(StrongSlingerShoot_type_def:get_method("doUpdate"), SlingerCharge_preHook, function(retval)
    if isMasterPlayerShootUpdate then
        isMasterPlayerShootUpdate = nil;
        if to_int64(retval) & 0xFFFFFFFF == END then
            if slingerChargeMax ~= "" then
                slingerChargeMax = "";
            end
        else
            SlingerCharge_postHook();
        end
    end
    return retval;
end);

local isMasterPlayer = nil;
hook(HunterStatus_type_def:get_method("setEquipPower(app.HunterCharacter)"), function(args)
    if QuestInfoCreated and get_IsMaster_method:call(args[3]) then
        get_hook_storage().HunterAttackPower = get_AttackPower_method:call(args[2]);
        isMasterPlayer = true;
    end
end, function()
    if isMasterPlayer then
        isMasterPlayer = nil;
        getWeaponAttr(get_AttibuteType_method:call(get_hook_storage().HunterAttackPower));
    end
end);

hook(QuestDirector_type_def:get_method("update"), function(args)
    if QuestDirector_ptr == nil then
        local this_ptr = args[2];
        if get_IsActiveQuest_method:call(this_ptr) then
            QuestDirector_ptr = this_ptr;
        end
    elseif get_IsActiveQuest_method:call(QuestDirector_ptr) == false then
        QuestDirector_ptr = nil;
        if QuestInfoCreated then
            QuestInfoCreated = false;
            oldElapsedTime = nil;
            oldWeaponAttr = nil;
            curDeathCount = nil;
            questMaxDeath = nil;
            questTimeLimit = nil;
            QuestTimer = nil;
            curWeaponAttr = nil;
            slingerChargeMax = nil;
        end
    end
end, function()
    if QuestDirector_ptr ~= nil then
        local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector_ptr);
        if not QuestInfoCreated then
            slingerChargeMax = "";
            if maxSlingerChargeTime == nil then
                maxSlingerChargeTime = get_ExChargeSlingerSpeedRate_method:call(get_PlParam_method:call(nil));
            end
            local ActiveQuestData = get_QuestData_method:call(QuestDirector_ptr);
            questTimeLimit = getTimeLimit_method:call(ActiveQuestData) .. "분";
            questMaxDeath = getQuestLife_method:call(ActiveQuestData);
            local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector_ptr);
            curDeathCount = mathfloor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount));
            getQuestTimeInfo(QuestElapsedTime);
            getWeaponAttr(get_AttibuteType_method:call(get_AttackPower_method:call(getHunterStatus_method:call(nil))));
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

hook(PlayerGlobalParam_type_def:get_method("get_QuestClearActionWaitTime"), skipOriginal, postHook_getTimes);
hook(PlayerGlobalParam_type_def:get_method("get_QuestRetireActionWaitTime"), skipOriginal, postHook_getTimes);
hook(PlayerGlobalParam_type_def:get_method("get_QuestFailedActionWaitTime"), skipOriginal, postHook_getTimes);
hook(PlayerGlobalParam_type_def:get_method("get_QuestReplicaLeaveActionWaitTime"), skipOriginal, postHook_getTimes);
hook(PlayerGlobalParam_type_def:get_method("get_QuestClearStampTime"), skipOriginal, postHook_getTimes);
hook(PlayerGlobalParam_type_def:get_method("get_QuestRetireStampTime"), skipOriginal, postHook_getTimes);
hook(PlayerGlobalParam_type_def:get_method("get_QuestFailedStampTime"), skipOriginal, postHook_getTimes);

Constants.on_frame(function()
    if QuestInfoCreated then
        push_font(font);
        drawtext(slingerChargeMax .. "\n" .. curWeaponAttr .. "\n" .. QuestTimer .. " / " .. questTimeLimit .. "\n" .. "다운 횟수: " .. curDeathCount .. " / " .. questMaxDeath, 3719, 234, 0xFFFFFFFF);
        pop_font();
    end
end);