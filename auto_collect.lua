local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local pairs = Constants.pairs;

local getSellItem_method = Constants.ItemUtil_type_def:get_method("getSellItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static

local getItemLog_method = Constants.ChatManager_type_def:get_method("getItemLog(app.ItemDef.ID, System.Int16, System.Boolean, System.Boolean, app.EnemyDef.ID, app.GimmickDef.ID)");

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

local Gm262_type_def = sdk.find_type_definition("app.Gm262");
local successButtonEvent_method = Gm262_type_def:get_method("successButtonEvent");

local STOCK_TYPE_BOX = sdk.find_type_definition("app.ItemUtil.STOCK_TYPE"):get_field("BOX"):get_data(nil); -- static

local notifyList = {};

local function getItemLog(ItemDefID, quantity)
    getItemLog_method:call(sdk.get_managed_singleton("app.ChatManager"), ItemDefID, quantity, false, false, -1, -1);
end

local function addNotifyList(ItemDefID, quantity)
    if notifyList[ItemDefID] ~= nil then
        notifyList[ItemDefID] = notifyList[ItemDefID] + quantity;
    else
        notifyList[ItemDefID] = quantity;
    end
end

local function sendNotification()
    for ItemDefID, quantity in pairs(notifyList) do
        getItemLog(ItemDefID, quantity);
    end
    notifyList = {};
end

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
            addNotifyList(ItemId, ItemNum);
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
            addNotifyList(ItemId, ItemNum);
            clearRewardItem_method:call(LargeWorkshopParam, i);
        else
            break;
        end
    end
end);

sdk.hook(FacilityDining_type_def:get_method("addSuplyNum"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    supplyFood_method:call(thread.get_hook_storage()["this"]);
    sendNotification();
end);

sdk.hook(Gm262_type_def:get_method("doUpdateBegin"), function(args)
    if Constants.RallusSupplyNum > 0 then
        successButtonEvent_method:call(sdk.to_managed_object(args[2]));
    end
end);