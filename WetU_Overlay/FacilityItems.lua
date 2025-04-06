local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local math = Constants.math;
local string = Constants.string;
local tostring = Constants.tostring;

local FacilityItems = {
    HasData = false,
    Pugee = nil,
    Rallus = nil
};

local FacilityManager_type_def = sdk.find_type_definition("app.FacilityManager");
local get_Pugee_method = FacilityManager_type_def:get_method("get_Pugee");
local get_Rallus_method = FacilityManager_type_def:get_method("get_Rallus");

local FacilityPugee_type_def = get_Pugee_method:get_return_type();
local get__SaveParam_method = FacilityPugee_type_def:get_method("get__SaveParam");
local isEnableCoolTimer_method = FacilityPugee_type_def:get_method("isEnableCoolTimer");

local getCoolTimer_method = get__SaveParam_method:get_return_type():get_method("getCoolTimer");

local FacilityRallus_type_def = get_Rallus_method:get_return_type();
local get_SupplyTimer_method = FacilityRallus_type_def:get_method("get_SupplyTimer");
local get_SupplyNum_method = FacilityRallus_type_def:get_method("get_SupplyNum");
local SettingData_field = FacilityRallus_type_def:get_field("_SettingData");

local get_StockMax_method = SettingData_field:get_type():get_method("get_StockMax");

local oldPugeeState = nil;
local oldCoolTimer = nil;
local oldSupplyTimer = nil;
local oldSupplyNum = nil;

local RallusStockMax = "5";
local isRallusStockMaxUpdated = false;

local RallusTimer = nil;
local RallusNum = nil;
sdk.hook(FacilityManager_type_def:get_method("update"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    local FacilityManager = thread.get_hook_storage()["this"];
    local FacilityPugee = get_Pugee_method:call(FacilityManager);
    local FacilityRallus = get_Rallus_method:call(FacilityManager);

    if FacilityPugee ~= nil then
        local isEnableCoolTimer = isEnableCoolTimer_method:call(FacilityPugee);

        if isEnableCoolTimer == true then
            local CoolTimer = getCoolTimer_method:call(get__SaveParam_method:call(FacilityPugee));
            if CoolTimer ~= oldCoolTimer then
                oldCoolTimer = CoolTimer;
                FacilityItems.Pugee = "푸기: " .. string.format("%02d:%02d", math.floor(CoolTimer / 60.0), math.modf(CoolTimer % 60.0));
            end
        end

        if isEnableCoolTimer ~= oldPugeeState then
            oldPugeeState = isEnableCoolTimer;
            if isEnableCoolTimer == false then
                FacilityItems.Pugee = "푸기: 획득 가능";
            elseif isEnableCoolTimer == nil then
                FacilityItems.Pugee = nil;
            end
        end

        if FacilityItems.HasData ~= true then
            FacilityItems.HasData = true;
        end
    end

    if FacilityRallus ~= nil then
        local isUpdated = false;

        if isRallusStockMaxUpdated == false then
            local SettingData = SettingData_field:get_data(FacilityRallus);
            if SettingData ~= nil then
                RallusStockMax = tostring(get_StockMax_method:call(SettingData));
                isUpdated = true;
            end
            isRallusStockMaxUpdated = true;
        end

        local SupplyTimer = get_SupplyTimer_method:call(FacilityRallus);
        local SupplyNum = get_SupplyNum_method:call(FacilityRallus);

        if SupplyTimer ~= oldSupplyTimer then
            oldSupplyTimer = SupplyTimer;
            RallusTimer = string.format("%02d:%02d", math.floor(SupplyTimer / 60.0), math.modf(SupplyTimer % 60.0));
            isUpdated = true;
        end

        if SupplyNum ~= oldSupplyNum then
            oldSupplyNum = SupplyNum;
            RallusNum = tostring(SupplyNum);
            isUpdated = true;
        end

        if isUpdated == true then
            FacilityItems.Rallus = "뜸부기 둥지: " .. RallusNum .. "/" .. RallusStockMax .. "(" .. RallusTimer .. ")";
            if FacilityItems.HasData ~= true then
                FacilityItems.HasData = true;
            end
        end
    end
end);

return FacilityItems;