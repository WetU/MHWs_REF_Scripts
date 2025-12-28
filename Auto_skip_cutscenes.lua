local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;

local get_hook_storage = Constants.get_hook_storage;

local DemoMediator_type_def = find_type_definition("app.DemoMediator");
local get_CurrentTimelineEventID_method = DemoMediator_type_def:get_method("get_CurrentTimelineEventID");
local requestSkip_method = DemoMediator_type_def:get_method("requestSkip");

local TimelineEventDefine_ID_type_def = get_CurrentTimelineEventID_method:get_return_type();
local skipList = {
    TimelineEventDefine_ID_type_def:get_field("evc0105"):get_data(nil), -- Omega Planetes
    TimelineEventDefine_ID_type_def:get_field("evc0106"):get_data(nil), -- Gogmazios
    TimelineEventDefine_ID_type_def:get_field("evc2001"):get_data(nil), -- Tent/Grill Cooking 1
    TimelineEventDefine_ID_type_def:get_field("evc2002"):get_data(nil), -- Tent/Grill Cooking 2
    TimelineEventDefine_ID_type_def:get_field("evc2003"):get_data(nil), -- Tent/Grill Cooking 3
    TimelineEventDefine_ID_type_def:get_field("evc2030"):get_data(nil), -- Gemma Smithy
    TimelineEventDefine_ID_type_def:get_field("evc2033"):get_data(nil)  -- Hub Smithy
};

local reqSkip = nil;
hook(DemoMediator_type_def:get_method("notifyCutSkipEnd"), Constants.getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    local ID = get_CurrentTimelineEventID_method:call(this_ptr);
    for _, v in ipairs(skipList) do
        if ID == v then
            requestSkip_method:call(this_ptr);
            break;
        end
    end
end);