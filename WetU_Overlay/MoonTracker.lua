local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local tostring = Constants.tostring;

local MoonController_type_def = sdk.find_type_definition("app.MoonController");
local getActiveMoonData_method = MoonController_type_def:get_method("getActiveMoonData");
local MoonVariationNum = tostring(MoonController_type_def:get_field("MoonVariationNum"):get_data(nil));

local get_MoonIdx_method = getActiveMoonData_method:get_return_type():get_method("get_MoonIdx");

local MoonPhase = {
    "보름달",
    "하현망",
    "하현달",
    "그믐달",
    "초승달",
    "상현달",
    "상현망"
};

local this = {
    MoonState = nil
};

local oldMoonIdx = nil;

sdk.hook(MoonController_type_def:get_method("updateData"), Constants.getObject, function()
    local MoonIdx = get_MoonIdx_method:call(getActiveMoonData_method:call(thread.get_hook_storage()["this"]));
    if MoonIdx ~= nil then
        MoonIdx = MoonIdx + 1;
        if MoonIdx ~= oldMoonIdx then
            oldMoonIdx = MoonIdx;
            this.MoonState = MoonPhase[MoonIdx] .. ": " .. tostring(MoonIdx) .. "/" .. MoonVariationNum;
        end
    else
        if this.MoonState ~= nil then
            this.MoonState = nil;
        end
    end
end);

return this;