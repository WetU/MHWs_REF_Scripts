local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local tostring = Constants.tostring;

local FacilityItems = {
    Pugee = nil,
    Rallus = nil
};

local FacilityManager_type_def = sdk.find_type_definition("app.FacilityManager");
local get_Pugee_method = FacilityManager_type_def:get_method("get_Pugee");
local get_Rallus_method = FacilityManager_type_def:get_method("get_Rallus");

local isEnableCoolTimer_method = get_Pugee_method:get_return_type():get_method("isEnableCoolTimer");

local FacilityRallus_type_def = get_Rallus_method:get_return_type();
local get_SupplyNum_method = FacilityRallus_type_def:get_method("get_SupplyNum");
local SettingData_field = FacilityRallus_type_def:get_field("_SettingData");

local get_StockMax_method = SettingData_field:get_type():get_method("get_StockMax");

local oldPugeeState = nil;
local oldSupplyNum = nil;

local RallusStockMax = 5;
local isRallusStockMaxUpdated = false;
sdk.hook(FacilityManager_type_def:get_method("update"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    local FacilityManager = thread.get_hook_storage()["this"];
    local FacilityPugee = get_Pugee_method:call(FacilityManager);
    local FacilityRallus = get_Rallus_method:call(FacilityManager);

    if FacilityPugee ~= nil then
        local isEnableCoolTimer = isEnableCoolTimer_method:call(FacilityPugee);
        if isEnableCoolTimer ~= oldPugeeState then
            oldPugeeState = isEnableCoolTimer;
            FacilityItems.Pugee = isEnableCoolTimer == true and "푸기: 아이템 없음" or isEnableCoolTimer == false and "푸기: 아이템 획득 가능" or nil;
        end
    end

    if FacilityRallus ~= nil then
        if isRallusStockMaxUpdated == false then
            local SettingData = SettingData_field:get_data(FacilityRallus);
            if SettingData ~= nil then
                RallusStockMax = get_StockMax_method:call(SettingData);
            end
            isRallusStockMaxUpdated = true;
        end
        local SupplyNum = get_SupplyNum_method:call(FacilityRallus);
        if SupplyNum ~= oldSupplyNum then
            oldSupplyNum = SupplyNum;
            FacilityItems.Rallus = "뜸부기 둥지: " .. tostring(SupplyNum) .. " / " .. tostring(RallusStockMax);
        end
    end
end);

return FacilityItems;