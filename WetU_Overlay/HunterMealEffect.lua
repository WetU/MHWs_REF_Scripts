local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local get_IsMaster_method = Constants.HunterCharacter_type_def:get_method("get_IsMaster");

local HunterMealEffect_type_def = sdk.find_type_definition("app.cHunterMealEffect");
local get_DurationTimer_method = HunterMealEffect_type_def:get_method("get_DurationTimer");
local IsTimerActive_field = HunterMealEffect_type_def:get_field("_IsTimerActive");

local NO_CANTEEN = "효과 없음";
local oldMealTimer = nil;

local mealInfoTbl = {
    MealTimer = nil
};

sdk.hook(HunterMealEffect_type_def:get_method("update(System.Single, app.HunterCharacter)"), function(args)
    if get_IsMaster_method:call(sdk.to_managed_object(args[4])) == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    local HunterMealEffect = thread.get_hook_storage()["this"];
    if HunterMealEffect ~= nil then
        if IsTimerActive_field:get_data(HunterMealEffect) == true then
            local DurationTimer = get_DurationTimer_method:call(HunterMealEffect);
            if DurationTimer ~= oldMealTimer then
                oldMealTimer = DurationTimer;
                mealInfoTbl.MealTimer = string.format("%02d:%02d", math.floor(DurationTimer / 60.0), math.modf(DurationTimer % 60.0));
            end
        else
            if mealInfoTbl.MealTimer ~= NO_CANTEEN then
                oldMealTimer = NO_CANTEEN;
                mealInfoTbl.MealTimer = NO_CANTEEN;
            end
        end
    end
end);

return mealInfoTbl;