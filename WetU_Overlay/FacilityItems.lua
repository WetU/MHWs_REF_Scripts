local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

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

local Gm262_type_def = sdk.find_type_definition("app.Gm262");
local successButtonEvent_method = Gm262_type_def:get_method("successButtonEvent");

local oldSupplyTimer = nil;

local RallusStockMax = "5";
local isRallusStockMaxUpdated = false;

local RallusTimer = nil;
local RallusNum = nil;
sdk.hook(FacilityManager_type_def:get_method("update"), function(args)
    if Constants.FacilityManager == nil then
        Constants.FacilityManager = sdk.to_managed_object(args[2]);
    end
end, function()
    if Constants.FacilityManager ~= nil then
        local FacilityPugee = get_Pugee_method:call(Constants.FacilityManager);
        if FacilityPugee ~= nil and isEnableCoolTimer_method:call(FacilityPugee) == false then
            stroke_method:call(FacilityPugee, true);
        end

        local FacilityRallus = get_Rallus_method:call(Constants.FacilityManager);
        local SupplyTimer = get_SupplyTimer_method:call(FacilityRallus);
        local SupplyNum = get_SupplyNum_method:call(FacilityRallus);
        local isUpdated = false;
        if isRallusStockMaxUpdated == false then
            RallusStockMax = tostring(get_StockMax_method:call(SettingData_field:get_data(FacilityRallus)));
            isRallusStockMaxUpdated = true;
        end

        if SupplyTimer ~= oldSupplyTimer then
            oldSupplyTimer = SupplyTimer;
            RallusTimer = Constants.string.format("%02d:%02d", math.floor(SupplyTimer / 60.0), math.modf(SupplyTimer % 60.0));
            isUpdated = true;
        end

        if SupplyNum ~= RallusNum then
            RallusNum = SupplyNum;
            isUpdated = true;
        end

        if isUpdated == true and RallusNum ~= nil then
            FacilityItems.Rallus = tostring(RallusNum) .. "/" .. RallusStockMax .. "(" .. RallusTimer .. ")";
        end
    end
end);

sdk.hook(Gm262_type_def:get_method("doUpdateBegin"), function(args)
    if RallusNum > 0 then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    local Gm262 = thread.get_hook_storage()["this"];
    if Gm262 ~= nil then
        successButtonEvent_method:call(Gm262);
    end
end);

return FacilityItems;