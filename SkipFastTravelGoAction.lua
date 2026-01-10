local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;

local find_type_definition = Constants.find_type_definition;

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local get_Network_method = Constants.get_Network_method;

local get_UserInfoManager_method = get_Network_method:get_return_type():get_method("get_UserInfoManager");

local getMemberNum_method = get_UserInfoManager_method:get_return_type():get_method("getMemberNum(app.net_session_manager.SESSION_TYPE)");

local QUEST = find_type_definition("app.net_session_manager.SESSION_TYPE"):get_field("QUEST"):get_data(nil);

local FastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cFastTravelGo");
local methods = FastTravelGo_type_def:get_methods();
local startFTFade_method = nil;
local startFTFade_callback_method = Constants.getCallbackMethod(methods, "startFTFade");
for _, v in ipairs(methods) do
    if v:get_name() == "startFTFade" then
        startFTFade_method = v;
        break;
    end
end

local isSolo = nil;
Constants.hook(FastTravelGo_type_def:get_method("doEnter"), function(args)
    if getMemberNum_method:call(get_UserInfoManager_method:call(get_Network_method:call(nil)), QUEST) <= 1 then
        get_hook_storage().this_ptr = args[2];
        isSolo = true;
    end
end, function(retval)
    if isSolo then
        isSolo = nil;
        local this_ptr = get_hook_storage().this_ptr;
        startFTFade_method:call(this_ptr, false);
        startFTFade_callback_method:call(this_ptr);
    end
    return retval;
end);