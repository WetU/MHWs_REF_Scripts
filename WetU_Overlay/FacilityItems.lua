local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local math = Constants.math;
local tostring = Constants.tostring;

local FacilityItems = {
    Rallus = nil
};

local FacilityManager_type_def = sdk.find_type_definition("app.FacilityManager");
local get_Pugee_method = FacilityManager_type_def:get_method("get_Pugee");
local get_Rallus_method = FacilityManager_type_def:get_method("get_Rallus");

local FacilityPugee_type_def = get_Pugee_method:get_return_type();
local isEnableCoolTimer_method = FacilityPugee_type_def:get_method("isEnableCoolTimer");
local stroke_method = FacilityPugee_type_def:get_method("stroke(System.Boolean)");

local FacilityRallus_type_def = get_Rallus_method:get_return_type();
local get_SupplyTimer_method = FacilityRallus_type_def:get_method("get_SupplyTimer");
local get_SupplyNum_method = FacilityRallus_type_def:get_method("get_SupplyNum");
local SettingData_field = FacilityRallus_type_def:get_field("_SettingData");

local get_StockMax_method = SettingData_field:get_type():get_method("get_StockMax");

local oldSupplyTimer = nil;

local RallusStockMax = "5";
local isRallusStockMaxUpdated = false;

local RallusTimer = nil;
sdk.hook(FacilityManager_type_def:get_method("update"), Constants.getObject, function()
    local FacilityManager = Constants.thread.get_hook_storage()["this"];
    local FacilityPugee = get_Pugee_method:call(FacilityManager);
    local FacilityRallus = get_Rallus_method:call(FacilityManager);
    local SupplyTimer = get_SupplyTimer_method:call(FacilityRallus);
    local SupplyNum = get_SupplyNum_method:call(FacilityRallus);
    local isUpdated = false;

    if isEnableCoolTimer_method:call(FacilityPugee) == false then
        stroke_method:call(FacilityPugee, true);
        Constants.addSystemLog_method:call(Constants.get_Chat_method:call(nil), "푸기 아이템 획득!");
    end

    if isRallusStockMaxUpdated == false then
        RallusStockMax = tostring(get_StockMax_method:call(SettingData_field:get_data(FacilityRallus)));
        isRallusStockMaxUpdated = true;
        isUpdated = true;
    end

    if SupplyTimer ~= oldSupplyTimer then
        oldSupplyTimer = SupplyTimer;
        RallusTimer = Constants.string.format("%02d:%02d", math.floor(SupplyTimer / 60.0), math.modf(SupplyTimer % 60.0));
        isUpdated = true;
    end

    if SupplyNum ~= Constants.RallusSupplyNum then
        Constants.RallusSupplyNum = SupplyNum;
        isUpdated = true;
    end

    if isUpdated == true and Constants.RallusSupplyNum ~= nil then
        FacilityItems.Rallus = "뜸부기 둥지: " .. tostring(Constants.RallusSupplyNum) .. "/" .. RallusStockMax .. "(" .. RallusTimer .. ")";
    end
end);

return FacilityItems;