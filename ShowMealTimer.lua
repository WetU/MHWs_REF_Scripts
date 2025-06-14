local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local math = Constants.math;

local StatusIconManager_type_def = sdk.find_type_definition("app.StatusIconManager");
local StatusIconInfoList_field = StatusIconManager_type_def:get_field("_StatusIconInfoList");

local get_IsMaster_method = Constants.HunterCharacter_type_def:get_method("get_IsMaster");
local get_IsInLifeArea_method = Constants.HunterCharacter_type_def:get_method("get_IsInLifeArea");
local get_HunterStatus_method = Constants.HunterCharacter_type_def:get_method("get_HunterStatus");

local get_MealEffect_method = get_HunterStatus_method:get_return_type():get_method("get_MealEffect");

local get_DurationTimer_method = get_MealEffect_method:get_return_type():get_method("get_DurationTimer");

local StatusIconInfo_type_def = sdk.find_type_definition("app.StatusIconInfo");
local get_TimerText_method = StatusIconInfo_type_def:get_method("get_TimerText");
local StatusIcon_field = StatusIconInfo_type_def:get_field("_StatusIcon");

local get_Parent_method = get_TimerText_method:get_return_type():get_method("get_Parent");

local gui_Control_type_def = get_Parent_method:get_return_type();
local get_PlayState_method = gui_Control_type_def:get_method("get_PlayState");
local set_PlayState_method = gui_Control_type_def:get_method("set_PlayState(System.String)");

local STATUS_0019 = StatusIcon_field:get_type():get_field("STATUS_0019"):get_data(nil);

local TRUE_ptr = sdk.to_ptr(true);

local Boolean_type_def = get_IsMaster_method:get_return_type();
local m_value_field = Boolean_type_def:get_field("m_value");

local isFirst = true;
local isMasterStatus = nil;
sdk.hook(StatusIconManager_type_def:get_method("buffTimerUpdate(app.HunterCharacter, app.IconDef.STATUS, System.Boolean)"), function(args)
    local HunterCharacter = sdk.to_managed_object(args[3]);
    if get_IsMaster_method:call(HunterCharacter) == true then
        if sdk.to_int64(args[4]) & 0xFFFFFFFF == STATUS_0019 then
            if get_IsInLifeArea_method:call(HunterCharacter) == false and m_value_field:get_data(sdk.to_valuetype(args[5], Boolean_type_def)) == false then
                args[5] = TRUE_ptr;
            end
            thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
            isMasterStatus = true;
        end
        if Constants.HunterCharacter == nil then
            Constants.HunterCharacter = HunterCharacter;
        end
    end
end, function()
    if isMasterStatus == true then
        local StatusIconInfoList = StatusIconInfoList_field:get_data(thread.get_hook_storage()["this"]);
        for i = 0, StatusIconInfoList:get_size() - 1 do
            local StatusIconInfo = StatusIconInfoList[i];
            if StatusIcon_field:get_data(StatusIconInfo) == STATUS_0019 then
                if isFirst == true then
                    StatusIconInfo:set_field("Timer", math.floor(get_DurationTimer_method:call(get_MealEffect_method:call(get_HunterStatus_method:call(Constants.HunterCharacter)))));
                end
                local TimerText_Control = get_Parent_method:call(get_TimerText_method:call(StatusIconInfo));
                if get_PlayState_method:call(TimerText_Control) ~= "DEFAULT" then
                    set_PlayState_method:call(TimerText_Control, "DEFAULT");
                end
                break;
            end
        end
        isMasterStatus = nil;
        if isFirst == true then
            isFirst = false;
        end
    end
end);