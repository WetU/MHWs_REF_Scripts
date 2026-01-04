local Constants = _G.require("Constants/Constants");

--local tostring = Constants.tostring;
local ipairs = Constants.ipairs;

--local log_debug = Constants.log_debug;

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local DemoMediator_type_def = find_type_definition("app.DemoMediator");
local get_CurrentTimelineEventID_method = DemoMediator_type_def:get_method("get_CurrentTimelineEventID");
local requestSkip_method = DemoMediator_type_def:get_method("requestSkip");

local get_ID_method = find_type_definition("ace.DemoMediatorBase.cParamBase"):get_method("get_ID");

local TimelineEventDefine_ID_type_def = get_CurrentTimelineEventID_method:get_return_type();
local skipList = {
    TimelineEventDefine_ID_type_def:get_field("evc0105"):get_data(nil), -- Omega Planetes
    TimelineEventDefine_ID_type_def:get_field("evc0106"):get_data(nil), -- Gogmazios
    TimelineEventDefine_ID_type_def:get_field("evc1002"):get_data(nil), -- Zoshia
    TimelineEventDefine_ID_type_def:get_field("evc2001"):get_data(nil), -- Tent/Grill Cooking 1
    TimelineEventDefine_ID_type_def:get_field("evc2002"):get_data(nil), -- Tent/Grill Cooking 2
    TimelineEventDefine_ID_type_def:get_field("evc2003"):get_data(nil), -- Tent/Grill Cooking 3
    TimelineEventDefine_ID_type_def:get_field("evc2030"):get_data(nil), -- Gemma Smithy
    TimelineEventDefine_ID_type_def:get_field("evc2033"):get_data(nil)  -- Hub Smithy
};

local reqSkip = nil;
hook(DemoMediator_type_def:get_method("onPlayStart(ace.DemoMediatorBase.cParamBase)"), function(args)
    local ID = get_ID_method:call(args[3]);
    --log_debug(tostring(ID));
    for _, v in ipairs(skipList) do
        if ID == v then
            get_hook_storage().this_ptr = args[2];
            reqSkip = true;
            break;
        end
    end
end, function()
    if reqSkip == true then
        reqSkip = nil;
        requestSkip_method:call(get_hook_storage().this_ptr);
    end
end);

hook(DemoMediator_type_def:get_method("notifyCutSkipEnd"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    local ID = get_CurrentTimelineEventID_method:call(this_ptr);
    if ID ~= nil then
        --log_debug(tostring(ID));
        for _, v in ipairs(skipList) do
            if ID == v then
                requestSkip_method:call(this_ptr);
                break;
            end
        end
    end
end);