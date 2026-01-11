local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;

local get_hook_storage = Constants.get_hook_storage;

local getMethod = Constants.getMethod;

local get_Chara_method = Constants.get_Chara_method;
local get_IsMaster_method = Constants.get_IsMaster_method;

local get_Network_method = Constants.get_Network_method;

local get_UserInfoManager_method = get_Network_method:get_return_type():get_method("get_UserInfoManager");

local getMemberNum_method = get_UserInfoManager_method:get_return_type():get_method("getMemberNum(app.net_session_manager.SESSION_TYPE)");

local QUEST = find_type_definition("app.net_session_manager.SESSION_TYPE"):get_field("QUEST"):get_data(nil);

local FastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cFastTravelGo");
local departure_method = FastTravelGo_type_def:get_method("departure");
local Type_field = FastTravelGo_type_def:get_field("_Type");

local QUEST_START = Type_field:get_type():get_field("QUEST_START"):get_data(nil);

local PorterNoRideFastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cPorterNoRideFastTravelGo");
local PorterNoRide_methods = PorterNoRideFastTravelGo_type_def:get_methods();
local PorterNoRide_startFTFade_method = getMethod(PorterNoRide_methods, "startFTFade", false);
local PorterNoRide_startFTFade_callback_method = getMethod(PorterNoRide_methods, "startFTFade", true);
local PorterNoRide_Type_field = PorterNoRideFastTravelGo_type_def:get_field("_Type");

local PorterNoRide_QUEST_START = PorterNoRide_Type_field:get_type():get_field("QUEST_START"):get_data(nil);

local PorterRideFastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cPorterRideFastTravelGo");
local PorterRide_departure_method = PorterRideFastTravelGo_type_def:get_method("departure");
local PorterRide_Type_field = PorterRideFastTravelGo_type_def:get_field("_Type");

local PorterRide_QUEST_START = PorterRide_Type_field:get_type():get_field("QUEST_START"):get_data(nil);

local PorterRideYokuryuuFastTravel_type_def = find_type_definition("app.PlayerCommonAction.cPorterRideYokuryuuFastTravel");
local PorterRideYokuryuu_departure_method = PorterRideYokuryuuFastTravel_type_def:get_method("departure");
local PorterRideYokuryuu_Type_field = PorterRideYokuryuuFastTravel_type_def:get_field("_Type");

local PorterRideYokuryuu_QUEST_START = PorterRideYokuryuu_Type_field:get_type():get_field("QUEST_START"):get_data(nil);

local skipAction = nil;
hook(FastTravelGo_type_def:get_method("setupArrivalInfo"), function(args)
    local this_ptr = args[2];
    if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) and (Type_field:get_data(this_ptr) ~= QUEST_START or getMemberNum_method:call(get_UserInfoManager_method:call(get_Network_method:call(nil)), QUEST) <= 1) then
        get_hook_storage().this_ptr = this_ptr;
        skipAction = true;
    end
end, function()
    if skipAction then
        skipAction = nil;
        departure_method:call(get_hook_storage().this_ptr);
    end
end);

hook(getMethod(PorterNoRide_methods, "setupArrivalInfo", false), function(args)
    local this_ptr = args[2];
    if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) and (PorterNoRide_Type_field:get_data(this_ptr) ~= PorterNoRide_QUEST_START or getMemberNum_method:call(get_UserInfoManager_method:call(get_Network_method:call(nil)), QUEST) <= 1) then
        get_hook_storage().this_ptr = this_ptr;
        skipAction = true;
    end
end, function()
    if skipAction then
        skipAction = nil;
        local this_ptr = get_hook_storage().this_ptr;
        PorterNoRide_startFTFade_method:call(this_ptr, false);
        PorterNoRide_startFTFade_callback_method:call(this_ptr);
    end
end);

hook(PorterRideFastTravelGo_type_def:get_method("setupArrivalInfo"), function(args)
    local this_ptr = args[2];
    if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) and (PorterRide_Type_field:get_data(this_ptr) ~= PorterRide_QUEST_START or getMemberNum_method:call(get_UserInfoManager_method:call(get_Network_method:call(nil)), QUEST) <= 1) then
        get_hook_storage().this_ptr = this_ptr;
        skipAction = true;
    end
end, function()
    if skipAction then
        skipAction = nil;
        PorterRide_departure_method:call(get_hook_storage().this_ptr);
    end
end);

hook(PorterRideYokuryuuFastTravel_type_def:get_method("setupArrivalInfo"), function(args)
    local this_ptr = args[2];
    if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) and (PorterRideYokuryuu_Type_field:get_data(this_ptr) ~= PorterRideYokuryuu_QUEST_START or getMemberNum_method:call(get_UserInfoManager_method:call(get_Network_method:call(nil)), QUEST) <= 1) then
        get_hook_storage().this_ptr = this_ptr;
        skipAction = true;
    end
end, function()
    if skipAction then
        skipAction = nil;
        PorterRideYokuryuu_departure_method:call(get_hook_storage().this_ptr);
    end
end);