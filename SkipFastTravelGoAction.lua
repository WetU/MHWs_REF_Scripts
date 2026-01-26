local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;

local get_hook_storage = Constants.get_hook_storage;

local get_Chara_method = Constants.get_Chara_method;
local get_IsMaster_method = Constants.get_IsMaster_method;

local FastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cFastTravelGo");
local departure_method = FastTravelGo_type_def:get_method("departure");

local PorterRideFastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cPorterRideFastTravelGo");
local PorterRide_departure_method = PorterRideFastTravelGo_type_def:get_method("departure");

local PorterRideYokuryuuFastTravel_type_def = find_type_definition("app.PlayerCommonAction.cPorterRideYokuryuuFastTravel");
local PorterRideYokuryuu_departure_method = PorterRideYokuryuuFastTravel_type_def:get_method("departure");

local PorterNoRideFastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cPorterNoRideFastTravelGo");
local startFTFade_method = PorterNoRideFastTravelGo_type_def:get_method("startFTFade(System.Boolean)");

local skipAction = nil;
hook(FastTravelGo_type_def:get_method("setupArrivalInfo"), function(args)
    local this_ptr = args[2];
    if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) then
        get_hook_storage().this_ptr = this_ptr;
        skipAction = true;
    end
end, function()
    if skipAction then
        skipAction = nil;
        departure_method:call(get_hook_storage().this_ptr);
    end
end);

hook(PorterRideFastTravelGo_type_def:get_method("setupArrivalInfo"), function(args)
    local this_ptr = args[2];
    if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) then
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
    if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) then
        get_hook_storage().this_ptr = this_ptr;
        skipAction = true;
    end
end, function()
    if skipAction then
        skipAction = nil;
        PorterRideYokuryuu_departure_method:call(get_hook_storage().this_ptr);
    end
end);

hook(PorterNoRideFastTravelGo_type_def:get_method("setupArrivalInfo"), function(args)
    local this_ptr = args[2];
    if get_IsMaster_method:call(get_Chara_method:call(this_ptr)) then
        get_hook_storage().this_ptr = this_ptr;
        skipAction = true;
    end
end, function()
    if skipAction then
        skipAction = nil;
        startFTFade_method:call(get_hook_storage().this_ptr, true);
    end
end);