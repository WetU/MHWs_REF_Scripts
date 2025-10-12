local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local GUI020025_type_def = sdk.find_type_definition("app.GUI020025");
local doSkip_method = GUI020025_type_def:get_method("doSkip");

sdk.hook(GUI020025_type_def:get_method("updateSkipOnTimer"), getThisPtr, function(retval)
    doSkip_method:call(thread.get_hook_storage()["this_ptr"]);
    return retval;
end);