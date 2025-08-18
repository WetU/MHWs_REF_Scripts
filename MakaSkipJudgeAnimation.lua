local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;

local GUI090002PartsItemReceive_type_def = sdk.find_type_definition("app.GUI090002PartsItemReceive");
local get__Mode_method = GUI090002PartsItemReceive_type_def:get_method("get__Mode");
local get__JudgeAnimationEnd_method = GUI090002PartsItemReceive_type_def:get_method("get__JudgeAnimationEnd");
local get__WaitAnimationTime_method = GUI090002PartsItemReceive_type_def:get_method("get__WaitAnimationTime");
local set__WaitAnimationTime_method = GUI090002PartsItemReceive_type_def:get_method("set__WaitAnimationTime(System.Single)");
local get__WaitControlTime_method = GUI090002PartsItemReceive_type_def:get_method("get__WaitControlTime");
local set__WaitControlTime_method = GUI090002PartsItemReceive_type_def:get_method("set__WaitControlTime(System.Single)");

local MODE_type_def = get__Mode_method:get_return_type();
local MODE = {
    JUDGE00 = MODE_type_def:get_field("JUDGE00"):get_data(nil),
    JUDGE01 = MODE_type_def:get_field("JUDGE01"):get_data(nil)
};

local GUI090002PartsItemReceive = nil;
sdk.hook(GUI090002PartsItemReceive_type_def:get_method("start(app.cGUIPartsRecieveItemsInfo, System.Collections.Generic.List`1<app.cReceiveItemInfo>)"), function(args)
    GUI090002PartsItemReceive = sdk.to_managed_object(args[2]);
end);

sdk.hook(GUI090002PartsItemReceive_type_def:get_method("onVisibleUpdate"), nil, function()
    if GUI090002PartsItemReceive ~= nil then
        local Mode = get__Mode_method:call(GUI090002PartsItemReceive);
        if Mode == MODE.JUDGE00 or Mode == MODE.JUDGE01 then
            if get__JudgeAnimationEnd_method:call(GUI090002PartsItemReceive) == false then
                if get__WaitAnimationTime_method:call(GUI090002PartsItemReceive) > 0.01 then
                    set__WaitAnimationTime_method:call(GUI090002PartsItemReceive, 0.01);
                end
            else
                if get__WaitControlTime_method:call(GUI090002PartsItemReceive) > 0.01 then
                    set__WaitControlTime_method:call(GUI090002PartsItemReceive, 0.01);
                end
            end
        end
    end
end);

sdk.hook(sdk.find_type_definition("app.GUI090002"):get_method("onClose"), function(args)
    GUI090002PartsItemReceive = nil;
end);