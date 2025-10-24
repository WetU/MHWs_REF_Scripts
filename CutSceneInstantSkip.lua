local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI020025_type_def = sdk.find_type_definition("app.GUI020025");
local get_CurrentDispPattern_method = GUI020025_type_def:get_method("get_CurrentDispPattern");
local doSkip_method = GUI020025_type_def:get_method("doSkip");

local DISP_PATTERN_type_def = get_CurrentDispPattern_method:get_return_type();
local DISP_PATTERN = {
    DISP_PATTERN_type_def:get_field("CUT_SCENE"):get_data(nil),
    DISP_PATTERN_type_def:get_field("CUT_SCENE_MULTI"):get_data(nil)
};

local shouldSkip = false;
sdk.hook(GUI020025_type_def:get_method("updateSkipOnTimer"), function(args)
    local this_ptr = args[2];
    local curDispPattern = get_CurrentDispPattern_method:call(this_ptr);
    for _, v in ipairs(DISP_PATTERN) do
        if curDispPattern == v then
            thread.get_hook_storage()["this_ptr"] = this_ptr;
            shouldSkip = true;
            break;
        end
    end
end, function(retval)
    if shouldSkip == true then
        doSkip_method:call(thread.get_hook_storage()["this_ptr"]);
        shouldSkip = false;
    end
    return retval;
end);