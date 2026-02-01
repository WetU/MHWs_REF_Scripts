local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local FastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cFastTravelGo");
local departure_method = FastTravelGo_type_def:get_method("departure");

local PorterRideFastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cPorterRideFastTravelGo");
local PorterRide_departure_method = PorterRideFastTravelGo_type_def:get_method("departure");

local PorterRideYokuryuuFastTravel_type_def = find_type_definition("app.PlayerCommonAction.cPorterRideYokuryuuFastTravel");
local PorterRideYokuryuu_departure_method = PorterRideYokuryuuFastTravel_type_def:get_method("departure");

local PorterNoRideFastTravelGo_type_def = find_type_definition("app.PlayerCommonAction.cPorterNoRideFastTravelGo");
local startFTFade_method = PorterNoRideFastTravelGo_type_def:get_method("startFTFade(System.Boolean)");

hook(FastTravelGo_type_def:get_method("setupArrivalInfo"), getThisPtr, function()
    departure_method:call(get_hook_storage().this_ptr);
end);

hook(PorterRideFastTravelGo_type_def:get_method("setupArrivalInfo"), getThisPtr, function()
    PorterRide_departure_method:call(get_hook_storage().this_ptr);
end);

hook(PorterRideYokuryuuFastTravel_type_def:get_method("setupArrivalInfo"), getThisPtr, function()
    PorterRideYokuryuu_departure_method:call(get_hook_storage().this_ptr);
end);

hook(PorterNoRideFastTravelGo_type_def:get_method("setupArrivalInfo"), getThisPtr, function()
    startFTFade_method:call(get_hook_storage().this_ptr, true);
end);