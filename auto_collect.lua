local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local ItemWorkCached = false;

local getSellItem_method = Constants.ItemUtil_type_def:get_method("getSellItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static

local getItemLog_method = nil;

local CollectionNPCParam_type_def = sdk.find_type_definition("app.savedata.cCollectionNPCParam");
local getCollectionItems_method = CollectionNPCParam_type_def:get_method("getCollectionItems");
local clearCollectionItem_method = CollectionNPCParam_type_def:get_method("clearCollectionItem(System.Int32)");

local LargeWorkshopParam_type_def = sdk.find_type_definition("app.savedata.cLargeWorkshopParam");
local get_Rewards_method = LargeWorkshopParam_type_def:get_method("get_Rewards");
local clearRewardItem_method = LargeWorkshopParam_type_def:get_method("clearRewardItem(System.Int32)");

local get_ItemId_method = nil;
local Num_field = nil;

local FacilityDining_type_def = sdk.find_type_definition("app.FacilityDining");
local supplyFood_method = FacilityDining_type_def:get_method("supplyFood");

local Gm262_type_def = sdk.find_type_definition("app.Gm262");
local successButtonEvent_method = Gm262_type_def:get_method("successButtonEvent");

local STOCK_TYPE_BOX = sdk.find_type_definition("app.ItemUtil.STOCK_TYPE"):get_field("BOX"):get_data(nil); -- static

local function getObject(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end

local function getItems(obj, facilityType)
    local getItemsArray_method = nil;
    local clearItem_method = nil;

    if facilityType == 1 then
        getItemsArray_method = getCollectionItems_method;
        clearItem_method = clearCollectionItem_method;
    else
        getItemsArray_method = get_Rewards_method;
        clearItem_method = clearRewardItem_method;
    end

    local ItemWorks_array = getItemsArray_method:call(obj);
    local ChatManager = sdk.get_managed_singleton("app.ChatManager");

    if Constants.ChatManager_type_def == nil then
        Constants.ChatManager_type_def = ChatManager:get_type_definition();
    end

    if getItemLog_method == nil then
        getItemLog_method = Constants.ChatManager_type_def:get_method("getItemLog(app.ItemDef.ID, System.Int16, System.Boolean, System.Boolean, app.EnemyDef.ID, app.GimmickDef.ID)");
    end

    for i = 0, ItemWorks_array:get_size() - 1 do
        local ItemWork = ItemWorks_array:get_element(i);
        if ItemWorkCached == false then
            local ItemWork_type_def = ItemWork:get_type_definition();
            get_ItemId_method = ItemWork_type_def:get_method("get_ItemId");
            Num_field = ItemWork_type_def:get_field("Num");
            ItemWorkCached = true;
        end
        local ItemNum = Num_field:get_data(ItemWork);
        if ItemNum > 0 then
            local ItemId = get_ItemId_method:call(ItemWork);
            getSellItem_method:call(nil, ItemId, ItemNum, STOCK_TYPE_BOX);
            getItemLog_method:call(ChatManager, ItemId, ItemNum, false, false, -1, -1);
            clearItem_method:call(obj, i);
        else
            break;
        end
    end
end

sdk.hook(CollectionNPCParam_type_def:get_method("addCollectionItem"), getObject, function()
    getItems(thread.get_hook_storage()["this"], 1);
end);

sdk.hook(LargeWorkshopParam_type_def:get_method("addRewardItem"), getObject, function()
    getItems(thread.get_hook_storage()["this"], 2);
end);

sdk.hook(FacilityDining_type_def:get_method("addSuplyNum"), getObject, function()
    supplyFood_method:call(thread.get_hook_storage()["this"]);
end);

sdk.hook(Gm262_type_def:get_method("doUpdateBegin"), function(args)
    if Constants.RallusSupplyNum > 0 then
        successButtonEvent_method:call(sdk.to_managed_object(args[2]));
    end
end);