local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local addItemLog_method = sdk.find_type_definition("app.ChatLogUtil"):get_method("addItemLog(app.ItemDef.ID, System.Int16, System.Boolean, System.Boolean, app.EnemyDef.ID)")  -- static
local getSellItem_method = Constants.ItemUtil_type_def:get_method("getSellItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static

local CollectionNPCParam_type_def = sdk.find_type_definition("app.savedata.cCollectionNPCParam");
local getCollectionItems_method = CollectionNPCParam_type_def:get_method("getCollectionItems");
local clearCollectionItem_method = CollectionNPCParam_type_def:get_method("clearCollectionItem(System.Int32)");

local LargeWorkshopParam_type_def = sdk.find_type_definition("app.savedata.cLargeWorkshopParam");
local get_Rewards_method = LargeWorkshopParam_type_def:get_method("get_Rewards");
local clearRewardItem_method = LargeWorkshopParam_type_def:get_method("clearRewardItem(System.Int32)");

local ItemWork_type_def = sdk.find_type_definition("app.savedata.cItemWork");
local get_ItemId_method = ItemWork_type_def:get_method("get_ItemId");
local Num_field = ItemWork_type_def:get_field("Num");

local FacilityDining_type_def = sdk.find_type_definition("app.FacilityDining");
local supplyFood_method = FacilityDining_type_def:get_method("supplyFood");

local STOCK_TYPE_BOX = sdk.find_type_definition("app.ItemUtil.STOCK_TYPE"):get_field("BOX"):get_data(nil); -- static

sdk.hook(CollectionNPCParam_type_def:get_method("addCollectionItem"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    local CollectionNPCParam = thread.get_hook_storage()["this"];
    local ItemWorks_array = getCollectionItems_method:call(CollectionNPCParam);

    for i = 0, ItemWorks_array:get_size() - 1 do
        local ItemWork = ItemWorks_array:get_element(i);
        local ItemNum = Num_field:get_data(ItemWork);
        if ItemNum > 0 then
            local ItemId = get_ItemId_method:call(ItemWork);
            getSellItem_method:call(nil, ItemId, ItemNum, STOCK_TYPE_BOX);
            addItemLog_method:call(nil, ItemId, ItemNum, false, false, -1);
            clearCollectionItem_method:call(CollectionNPCParam, i);
        else
            break;
        end
    end
end);

sdk.hook(LargeWorkshopParam_type_def:get_method("addRewardItem"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    local LargeWorkshopParam = thread.get_hook_storage()["this"];
    local ItemWorks_array = get_Rewards_method:call(LargeWorkshopParam);

    for i = 0, ItemWorks_array:get_size() - 1 do
        local ItemWork = ItemWorks_array:get_element(i);
        local ItemNum = Num_field:get_data(ItemWork);
        if ItemNum > 0 then
            local ItemId = get_ItemId_method:call(ItemWork);
            getSellItem_method:call(nil, ItemId, ItemNum, STOCK_TYPE_BOX);
            addItemLog_method:call(nil, ItemId, ItemNum, false, false, -1);
            clearRewardItem_method:call(LargeWorkshopParam, i);
        else
            break;
        end
    end
end);

local FacilityDining = nil;
sdk.hook(FacilityDining_type_def:get_method("supplyTimerGoal(app.cFacilityTimer)"), function(args)
    FacilityDining = sdk.to_managed_object(args[2]);
end);

sdk.hook(sdk.find_type_definition("app.LifeAreaMusicManager"):get_method("enterLifeArea"), nil, function()
    if FacilityDining ~= nil then
        supplyFood_method:call(FacilityDining);
        FacilityDining = nil;
    end
end);