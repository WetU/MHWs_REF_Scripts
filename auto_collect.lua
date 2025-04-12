local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local ItemWorkCached = false;

local changeItemNum_method = Constants.ItemUtil_type_def:get_method("changeItemNum(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static
local getSellItem_method = Constants.ItemUtil_type_def:get_method("getSellItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static
local getItemNum_method = Constants.ItemUtil_type_def:get_method("getItemNum(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)"); -- static

local getItemLog_method = nil;

local CollectionNPCParam_type_def = sdk.find_type_definition("app.savedata.cCollectionNPCParam");
local get_CollectionItem_method = CollectionNPCParam_type_def:get_method("get_CollectionItem");
local clearCollectionItem_method = CollectionNPCParam_type_def:get_method("clearCollectionItem(System.Int32)");

local LargeWorkshopParam_type_def = sdk.find_type_definition("app.savedata.cLargeWorkshopParam");
local get_Rewards_method = LargeWorkshopParam_type_def:get_method("get_Rewards");
local clearRewardItem_method = LargeWorkshopParam_type_def:get_method("clearRewardItem(System.Int32)");

local get_ItemId_method = nil;
local Num_field = nil;

local FacilityDining_type_def = sdk.find_type_definition("app.FacilityDining");
local supplyFood_method = FacilityDining_type_def:get_method("supplyFood");

local FacilityMoriver_type_def = sdk.find_type_definition("app.FacilityMoriver");
local executedSharing_method = FacilityMoriver_type_def:get_method("executedSharing(app.FacilityMoriver.MoriverInfo)");
local MoriverInfos_field = FacilityMoriver_type_def:get_field("_MoriverInfos");

local MoriverInfos_type_def = MoriverInfos_field:get_type();
local get_Count_method = MoriverInfos_type_def:get_method("get_Count");
local get_Item_method = MoriverInfos_type_def:get_method("get_Item(System.Int32)");

local MoriverInfo_type_def = get_Item_method:get_return_type();
local ItemFromMoriver_field = MoriverInfo_type_def:get_field("ItemFromMoriver");
local ItemFromPlayer_field = MoriverInfo_type_def:get_field("ItemFromPlayer");

local Gm262_type_def = sdk.find_type_definition("app.Gm262");
local successButtonEvent_method = Gm262_type_def:get_method("successButtonEvent");

local ID_type_def = sdk.find_type_definition("app.ItemDef.ID");
local NONE = ID_type_def:get_field("NONE"):get_data(nil); -- static
local MAX = ID_type_def:get_field("MAX"):get_data(nil); -- static

local STOCK_TYPE_type_def = sdk.find_type_definition("app.ItemUtil.STOCK_TYPE");
local STOCK_TYPE_POUCH = STOCK_TYPE_type_def:get_field("POUCH"):get_data(nil); -- static
local STOCK_TYPE_BOX = STOCK_TYPE_type_def:get_field("BOX"):get_data(nil); -- static

local function getItemWorkCache(itemWork)
    local ItemWork_type_def = itemWork:get_type_definition();
    get_ItemId_method = ItemWork_type_def:get_method("get_ItemId");
    Num_field = ItemWork_type_def:get_field("Num");
    ItemWorkCached = true;
end

local function getItems(obj, facilityType)
    local getItemsArray_method = nil;
    local clearItem_method = nil;

    if facilityType == 1 then
        getItemsArray_method = get_CollectionItem_method;
        clearItem_method = clearCollectionItem_method;
    else
        getItemsArray_method = get_Rewards_method;
        clearItem_method = clearRewardItem_method;
    end

    local ItemWorks_array = getItemsArray_method:call(obj);
    if ItemWorks_array ~= nil then
        local ChatManager = sdk.get_managed_singleton("app.ChatManager");

        if getItemLog_method == nil then
            getItemLog_method = ChatManager:get_type_definition():get_method("getItemLog(app.ItemDef.ID, System.Int16, System.Boolean, System.Boolean, app.EnemyDef.ID, app.GimmickDef.ID)");
        end

        for i = 0, ItemWorks_array:get_size() - 1 do
            local ItemWork = ItemWorks_array:get_element(i);
            if ItemWorkCached == false then
                getItemWorkCache(ItemWork);
            end
            local ItemId = get_ItemId_method:call(ItemWork);
            if ItemId > NONE and ItemId < MAX then
                local ItemNum = Num_field:get_data(ItemWork);
                if ItemNum > 0 then
                    getSellItem_method:call(nil, ItemId, ItemNum, STOCK_TYPE_BOX);
                    getItemLog_method:call(ChatManager, ItemId, ItemNum, false, false, -1, -1);
                    clearItem_method:call(obj, i);
                else
                    break;
                end
            else
                break;
            end
        end
    end
end

sdk.hook(CollectionNPCParam_type_def:get_method("addCollectionItem(app.ItemDef.ID, System.Int16)"), Constants.getObject, function()
    getItems(thread.get_hook_storage()["this"], 1);
end);

sdk.hook(LargeWorkshopParam_type_def:get_method("addRewardItem(app.ItemDef.ID, System.Int16)"), Constants.getObject, function()
    getItems(thread.get_hook_storage()["this"], 2);
end);

sdk.hook(FacilityDining_type_def:get_method("addSuplyNum"), Constants.getObject, function()
    supplyFood_method:call(thread.get_hook_storage()["this"]);
end);

sdk.hook(Gm262_type_def:get_method("doUpdateBegin"), function(args)
    if Constants.RallusSupplyNum > 0 then
        successButtonEvent_method:call(sdk.to_managed_object(args[2]));
    end
end);

sdk.hook(FacilityMoriver_type_def:get_method("startCampfire(System.Boolean)"), function(args)
    if (sdk.to_int64(args[3]) & 1) == 1 then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    local FacilityMoriver = thread.get_hook_storage()["this"];
    if FacilityMoriver ~= nil then
        local MoriverInfos = MoriverInfos_field:get_data(FacilityMoriver);
        if MoriverInfos ~= nil then
            local Count = get_Count_method:call(MoriverInfos);
            if Count ~= nil and Count > 0 then
                local ChatManager = sdk.get_managed_singleton("app.ChatManager");
                if getItemLog_method == nil then
                    getItemLog_method = ChatManager:get_type_definition():get_method("getItemLog(app.ItemDef.ID, System.Int16, System.Boolean, System.Boolean, app.EnemyDef.ID, app.GimmickDef.ID)");
                end
                for i = 0, Count - 1 do
                    local MoriverInfo = get_Item_method:call(MoriverInfos, i);
                    if MoriverInfo ~= nil then
                        local ItemFromMoriver = ItemFromMoriver_field:get_data(MoriverInfo);
                        local ItemFromPlayer = ItemFromPlayer_field:get_data(MoriverInfo);

                        if ItemFromPlayer ~= nil then
                            if ItemWorkCached == false then
                                getItemWorkCache(ItemFromPlayer);
                            end

                            local giveItemId = get_ItemId_method:call(ItemFromPlayer);
                            if giveItemId > NONE and giveItemId < MAX then
                                local giveNum = Num_field:get_data(ItemFromPlayer);
                                if giveNum > 0 then
                                    local pouchNum = getItemNum_method:call(nil, giveItemId, STOCK_TYPE_POUCH);
                                    if pouchNum > giveNum then
                                        changeItemNum_method:call(nil, giveItemId, pouchNum - giveNum, STOCK_TYPE_POUCH);
                                    else
                                        local boxNum = getItemNum_method:call(nil, giveItemId, STOCK_TYPE_BOX);
                                        if (pouchNum + boxNum) > giveNum then
                                            changeItemNum_method:call(nil, giveItemId, 0, STOCK_TYPE_POUCH);
                                            changeItemNum_method:call(nil, giveItemId, boxNum - (giveNum - pouchNum), STOCK_TYPE_BOX);
                                        elseif boxNum > giveNum then
                                            changeItemNum_method:call(nil, giveItemId, boxNum - giveNum, STOCK_TYPE_BOX);
                                        end
                                    end
                                end
                            end
                        end

                        if ItemFromMoriver ~= nil then
                            if ItemWorkCached == false then
                                getItemWorkCache(ItemFromMoriver);
                            end

                            local gettingItemId = get_ItemId_method:call(ItemFromMoriver);
                            if gettingItemId > NONE and gettingItemId < MAX then
                                local gettingNum = Num_field:get_data(ItemFromMoriver);
                                if gettingNum > 0 then
                                    getSellItem_method:call(nil, gettingItemId, gettingNum, STOCK_TYPE_BOX);
                                    getItemLog_method:call(ChatManager, gettingItemId, gettingNum, false, false, -1, -1);
                                end
                            end
                        end

                        executedSharing_method:call(FacilityMoriver, MoriverInfo);
                    end
                end
            end
        end
    end
end);