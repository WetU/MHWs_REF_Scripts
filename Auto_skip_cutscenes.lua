local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local DemoMediator_type_def = sdk.find_type_definition("app.DemoMediator");
local requestSkip_method = DemoMediator_type_def:get_method("requestSkip");

local get_ID_method = sdk.find_type_definition("ace.DemoMediatorBase.cParamBase"):get_method("get_ID");

local TimelineEventDefine_ID_Type_def = sdk.find_type_definition("app.TimelineEventDefine.ID");
local skipList = {
    TimelineEventDefine_ID_Type_def:get_field("evc0105"):get_data(nil), -- Omega Planetes
    TimelineEventDefine_ID_Type_def:get_field("evc0106"):get_data(nil), -- Gogmazios
    TimelineEventDefine_ID_Type_def:get_field("evc2001"):get_data(nil), -- Tent/Grill Cooking 1
    TimelineEventDefine_ID_Type_def:get_field("evc2002"):get_data(nil), -- Tent/Grill Cooking 2
    TimelineEventDefine_ID_Type_def:get_field("evc2003"):get_data(nil), -- Tent/Grill Cooking 3
    TimelineEventDefine_ID_Type_def:get_field("evc2030"):get_data(nil), -- Gemma Smithy
    TimelineEventDefine_ID_Type_def:get_field("evc2033"):get_data(nil)  -- Hub Smithy
};

local reqSkip = nil;
sdk.hook(DemoMediator_type_def:get_method("onPlayStart(ace.DemoMediatorBase.cParamBase)"), function(args)
    local ID = get_ID_method:call(sdk.to_managed_object(args[3]));
    --log.debug(tostring(ID));
    for _, v in ipairs(skipList) do
        if ID == v then
            reqSkip = true;
            thread.get_hook_storage()["this_ptr"] = args[2];
            break;
        end
    end
end, function()
    if reqSkip == true then
        reqSkip = nil;
        requestSkip_method:call(thread.get_hook_storage()["this_ptr"]);
    end
end);