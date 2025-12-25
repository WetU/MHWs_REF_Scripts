local Constants = _G.require("Constants/Constants");

local iparis = Constants.ipairs;

local sdk = Constants.sdk;
local therad = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local DemoMediator_type_def = sdk.find_type_definition("app.DemoMediator");
local get_CurrentTimelineEventID_method = DemoMediator_type_def:get_method("get_CurrentTimelineEventID");
local requestSkip_method = DemoMediator_type_def:get_method("requestSkip");

local TimelineEventDefine_ID_Type_def = get_CurrentTimelineEventID_method:get_return_type();
local skipList = {
    TimelineEventDefine_ID_Type_def:get_field("evc2001"):get_data(nil), -- Tent/Grill Cooking 1
    TimelineEventDefine_ID_Type_def:get_field("evc2002"):get_data(nil), -- Tent/Grill Cooking 2
    TimelineEventDefine_ID_Type_def:get_field("evc2003"):get_data(nil), -- Tent/Grill Cooking 3
    TimelineEventDefine_ID_Type_def:get_field("evc2030"):get_data(nil), -- Gemma Smithy
    TimelineEventDefine_ID_Type_def:get_field("evc2033"):get_data(nil)  -- Hub Smithy
};

sdk.hook(DemoMediator_type_def:get_method("notifyCutSkipEnd"), getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    local currentTimelineEventID = get_CurrentTimelineEventID_method:call(this_ptr);
    for _, v in ipairs(skipList) do
        if currentTimelineEventID == v then
            requestSkip_method:call(this_ptr);
            break;
        end
    end
end);