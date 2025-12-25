local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;
local tostring = Constants.tostring;
local tonumber = Constants.tonumber;
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

local ActiveQuestData_type_def = get_QuestData_method:get_return_type();
local getTimeLimit_method = ActiveQuestData_type_def:get_method("getTimeLimit");
local getQuestLife_method = ActiveQuestData_type_def:get_method("getQuestLife");

local getHunterCharacter_method = sdk.find_type_definition("app.GUIActionGuideParamGetter"):get_method("getHunterCharacter"); -- static

local get_HunterStatus_method = getHunterCharacter_method:get_return_type():get_method("get_HunterStatus");

local get_AttackPower_method = get_HunterStatus_method:get_return_type():get_method("get_AttackPower");

local HunterAttackPower_type_def = get_AttackPower_method:get_return_type();
local get_AttibuteType_method = HunterAttackPower_type_def:get_method("get_AttibuteType");

local WeaponAttr = {};
for _, v in Constants.ipairs(get_AttibuteType_method:get_return_type():get_fields()) do
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

local questMaxDeath = nil;
local questTimeLimit = nil;

local QuestInfoCreated = false;
local QuestTimer = nil;
local DeathCount = nil;
local curWeaponAttr = nil;

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
        elseif curWeaponAttr ~= nil then
            curWeaponAttr = nil;
        end
    end
end

local function getQuestTimeInfo(questElapsedTime)
    oldElapsedTime = questElapsedTime;
    local second, milisecond = math.modf(questElapsedTime % 60.0);
    QuestTimer = string.format("%02d'%02d\"%02d", math.floor(questElapsedTime / 60.0), second, milisecond ~= 0.0 and tonumber(string.match(tostring(milisecond), "%.(%d%d)")) or 0) .. " / " .. questTimeLimit;
end

sdk.hook(HunterAttackPower_type_def:get_method("setWeaponAttackPower(app.cHunterCreateInfo)"), nil, function()
    if QuestInfoCreated == true then
        getWeaponAttr(get_AttibuteType_method:call(Hunter_AttackPower));
    end
end);

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
        end
    end
end, function()
    if QuestDirector_ptr ~= nil then
        local QuestElapsedTime = get_QuestElapsedTime_method:call(QuestDirector_ptr);
        if QuestInfoCreated == false then
            local ActiveQuestData = get_QuestData_method:call(QuestDirector_ptr);
            questTimeLimit = tostring(getTimeLimit_method:call(ActiveQuestData)) .. "분";
            questMaxDeath = tostring(getQuestLife_method:call(ActiveQuestData));
            local QuestPlDieCount = QuestPlDieCount_field:get_data(QuestDirector_ptr);
            DeathCount = "다운 횟수: " .. tostring(math.floor(v_field:get_data(QuestPlDieCount) / m_field:get_data(QuestPlDieCount))) .. " / " .. questMaxDeath;
            getQuestTimeInfo(QuestElapsedTime);
            Hunter_AttackPower = get_AttackPower_method:call(get_HunterStatus_method:call(getHunterCharacter_method:call(nil)));
            getWeaponAttr(get_AttibuteType_method:call(Hunter_AttackPower));
            QuestInfoCreated = true;
        elseif QuestElapsedTime ~= oldElapsedTime then
            getQuestTimeInfo(QuestElapsedTime);
        end
    end
end);

sdk.hook(QuestDirector_type_def:get_method("applyQuestPlDie(System.Int32, System.Boolean)"), nil, function()
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
        if curWeaponAttr ~= nil then
            draw.text(curWeaponAttr .. "\n" .. QuestTimer .. "\n" .. DeathCount, 3719, 250, 0xFFFFFFFF);
        else
            draw.text("" .. "\n" .. QuestTimer .. "\n" .. DeathCount, 3719, 250, 0xFFFFFFFF);
        end
        imgui.pop_font();
    end
end);