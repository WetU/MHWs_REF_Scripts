local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local getCurrentStageMasterPlayer_method = sdk.find_type_definition("app.PorterUtil"):get_method("getCurrentStageMasterPlayer"); -- static

local GUIMapBeaconManager_type_def = sdk.find_type_definition("app.GUIMapBeaconManager");
local findBeacon_GimmickId_method = GUIMapBeaconManager_type_def:get_method("findBeacon_GimmickId(app.GimmickDef.ID)");

local GUIBeaconGimmick_type_def = findBeacon_GimmickId_method:get_return_type();
local get_ContextHolder_method = GUIBeaconGimmick_type_def:get_method("get_ContextHolder");
local IsInstantiate_field = GUIBeaconGimmick_type_def:get_field("IsInstantiate");

local get_Gimmick_method = get_ContextHolder_method:get_return_type():get_method("get_Gimmick");

local GimmickContext_type_def = get_Gimmick_method:get_return_type();
local get_BaseParam_method = GimmickContext_type_def:get_method("get_BaseParam");
local get_PopedNum_method = GimmickContext_type_def:get_method("get_PopedNum");

local get_BaseState_method = get_BaseParam_method:get_return_type():get_method("get_BaseState");

local STAGE_type_def = getCurrentStageMasterPlayer_method:get_return_type();
local STAGE = {
    ["경계의 모래 평원"] = STAGE_type_def:get_field("ST101"):get_data(nil),
    ["주홍빛 숲"] = STAGE_type_def:get_field("ST102"):get_data(nil)
};

local BASE_STATE_type_def = get_BaseState_method:get_return_type();
local BASE_STATE = {
    ENABLE = BASE_STATE_type_def:get_field("ENABLE"):get_data(nil),
    TO_ENABLE = BASE_STATE_type_def:get_field("TO_ENABLE"):get_data(nil)
};

local GimmickID_type_def = sdk.find_type_definition("app.GimmickDef.ID");
local GimmickID = {
    ["퀸 라플레시아"] = GimmickID_type_def:get_field("GM000_152_00"):get_data(nil),
    ["덧없는 꽃"] = GimmickID_type_def:get_field("GM000_153_00"):get_data(nil)
};

local this = {
    PoppedGimmick = nil;
};

local function getInteractable(guiBeaconGimmick)
    if guiBeaconGimmick ~= nil and IsInstantiate_field:get_data(guiBeaconGimmick) == true then
        local ContextHolder = get_ContextHolder_method:call(guiBeaconGimmick);
        if ContextHolder ~= nil then
            local GimmickContext = get_Gimmick_method:call(ContextHolder);
            if GimmickContext ~= nil and get_PopedNum_method:call(GimmickContext) > 0 then
                local BaseParam = get_BaseParam_method:call(GimmickContext);
                if BaseParam ~= nil then
                    local BaseState = get_BaseState_method:call(BaseParam);
                    if BaseState == BASE_STATE.ENABLE or BaseState == BASE_STATE.TO_ENABLE then
                        return true;
                    end
                end
            end
        end
    end
    return false;
end

sdk.hook(GUIMapBeaconManager_type_def:get_method("update"), function(args)
    if Constants.GUIMapBeaconManager == nil then
        Constants.GUIMapBeaconManager = sdk.to_managed_object(args[2]);
    end
end, function()
    local curStage = getCurrentStageMasterPlayer_method:call(nil);
    if curStage == STAGE["경계의 모래 평원"] then
        if getInteractable(findBeacon_GimmickId_method:call(Constants.GUIMapBeaconManager, GimmickID["덧없는 꽃"])) == true then
            local msg = "덧없는 꽃 획득 가능!";
            if this.PoppedGimmick ~= msg then
                this.PoppedGimmick = msg;
                return;
            end
        end
    elseif curStage == STAGE["주홍빛 숲"] then
        local msg = "";
        for k, v in Constants.pairs(GimmickID) do
            if getInteractable(findBeacon_GimmickId_method:call(Constants.GUIMapBeaconManager, v)) == true then
                if msg ~= "" then
                    msg = msg .. "\n";
                end
                msg = msg .. k .. " 획득 가능!";
            end
        end
        if msg ~= "" then
            if msg ~= this.PoppedGimmick then
                this.PoppedGimmick = msg;
            end
        else
            if this.PoppedGimmick ~= nil then
                this.PoppedGimmick = nil;
            end
        end
        return;
    end
    if this.PoppedGimmick ~= nil then
        this.PoppedGimmick = nil;
    end
end);

return this;