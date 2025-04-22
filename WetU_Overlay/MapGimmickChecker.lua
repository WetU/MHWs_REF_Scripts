local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local ipairs = Constants.ipairs;

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

local BASE_STATE_type_def = get_BaseState_method:get_return_type();
local BASE_STATE = {
    ENABLE = BASE_STATE_type_def:get_field("ENABLE"):get_data(nil),
    TO_ENABLE = BASE_STATE_type_def:get_field("TO_ENABLE"):get_data(nil)
};

local GimmickID_type_def = sdk.find_type_definition("app.GimmickDef.ID");
local GimmickID = {
    GimmickID_type_def:get_field("GM000_152_00"):get_data(nil),
    GimmickID_type_def:get_field("GM000_153_00"):get_data(nil)
};
local GimmickName = {
    "퀸 라플레시아",
    "덧없는 꽃"
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
    local curStage = Constants.curStage or Constants.getCurrentStageMasterPlayer();
    if curStage == Constants.Stages[1] then
        if getInteractable(findBeacon_GimmickId_method:call(Constants.GUIMapBeaconManager, GimmickID[2])) == true then
            local msg = GimmickName[2] .. "획득 가능!";
            if this.PoppedGimmick ~= msg then
                this.PoppedGimmick = msg;
                return;
            end
        end
    elseif curStage == Constants.Stages[2] then
        local msg = "";
        for i, v in ipairs(GimmickID) do
            if getInteractable(findBeacon_GimmickId_method:call(Constants.GUIMapBeaconManager, v)) == true then
                if msg ~= "" then
                    msg = msg .. "\n";
                end
                msg = msg .. GimmickName[i] .. " 획득 가능!";
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