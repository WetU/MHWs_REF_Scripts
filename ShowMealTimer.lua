local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local StatusIconManager_type_def = sdk.find_type_definition("app.StatusIconManager");
local StatusIconInfoList_field = StatusIconManager_type_def:get_field("_StatusIconInfoList");

local get_IsMaster_method = Constants.HunterCharacter_type_def:get_method("get_IsMaster");

local StatusIconInfo_type_def = sdk.find_type_definition("app.StatusIconInfo");
local get_TimerText_method = StatusIconInfo_type_def:get_method("get_TimerText");
local StatusIcon_field = StatusIconInfo_type_def:get_field("_StatusIcon");
local DispState_field = StatusIconInfo_type_def:get_field("_DispState");

local get_Parent_method = get_TimerText_method:get_return_type():get_method("get_Parent");

local gui_Control_type_def = get_Parent_method:get_return_type();
local get_PlayState_method = gui_Control_type_def:get_method("get_PlayState");
local set_PlayState_method = gui_Control_type_def:get_method("set_PlayState(System.String)");

local STATUS_0019 = StatusIcon_field:get_type():get_field("STATUS_0019"):get_data(nil); -- MealEffect
local ACTIVE = DispState_field:get_type():get_field("ACTIVE"):get_data(nil);

local isValid = nil;
sdk.hook(StatusIconManager_type_def:get_method("buffTimerUpdate(app.HunterCharacter, app.IconDef.STATUS, System.Boolean)"), function(args)
    local HunterCharacter = sdk.to_managed_object(args[3]);
    if get_IsMaster_method:call(HunterCharacter) == true then
        if Constants.HunterCharacter == nil then
            Constants.HunterCharacter = HunterCharacter;
        end
        if (sdk.to_int64(args[4]) & 0xFFFFFFFF) == STATUS_0019 then
            args[5] = Constants.TRUE_ptr;
            thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
            isValid = true;
        end
    end
end, function()
    if isValid == true then
        local StatusIconInfoList = StatusIconInfoList_field:get_data(thread.get_hook_storage()["this"]);
        for i = 0, StatusIconInfoList:get_size() - 1 do
            local StatusIconInfo = StatusIconInfoList:get_element(i);
            if StatusIcon_field:get_data(StatusIconInfo) == STATUS_0019 then
                if DispState_field:get_data(StatusIconInfo) == ACTIVE then
                    local TimerText_Control = get_Parent_method:call(get_TimerText_method:call(StatusIconInfo));
                    if get_PlayState_method:call(TimerText_Control) ~= "DEFAULT" then
                        set_PlayState_method:call(TimerText_Control, "DEFAULT");
                    end
                end
                break;
            end
        end
        isValid = nil;
    end
end);