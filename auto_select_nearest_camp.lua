local Constants = _G.require("Constants/Constants");

local type = Constants.type;

local sdk = Constants.sdk;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;
local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;

local distance_method = sdk.find_type_definition("via.MathEx"):get_method("distance(via.vec3, via.vec3)"); -- static

local getFloorNumFromAreaNum_method = sdk.find_type_definition("app.GUIUtilApp.MapUtil"):get_method("getFloorNumFromAreaNum(app.FieldDef.STAGE, System.Int32)"); -- static

local get_MAP3D_method = Constants.GUIManager_type_def:get_method("get_MAP3D");

local get_MapStageDrawData_method = get_MAP3D_method:get_return_type():get_method("get_MapStageDrawData");

local getDrawData_method = get_MapStageDrawData_method:get_return_type():get_method("getDrawData(app.FieldDef.STAGE)");

local get_AreaIconPosList_method = getDrawData_method:get_return_type():get_method("get_AreaIconPosList");

local AreaIconData_type_def = sdk.find_type_definition("app.user_data.MapStageDrawData.cAreaIconData");
local get_AreaIconPos_method = AreaIconData_type_def:get_method("get_AreaIconPos");
local get_AreaNum_method = AreaIconData_type_def:get_method("get_AreaNum");

local Int32_value_field = get_AreaNum_method:get_return_type():get_field("m_value");

local GUI050001_type_def = sdk.find_type_definition("app.GUI050001");
local get_CurrentStartPointList_method = GUI050001_type_def:get_method("get_CurrentStartPointList");
local get_QuestOrderParam_method = GUI050001_type_def:get_method("get_QuestOrderParam");
local setCurrentSelectStartPointIndex_method = GUI050001_type_def:get_method("setCurrentSelectStartPointIndex(System.Int32)");
local StartPointList_field = GUI050001_type_def:get_field("_StartPointList");

local get_BeaconGimmick_method = sdk.find_type_definition("app.cStartPointInfo"):get_method("get_BeaconGimmick");

local GUIBeaconGimmick_type_def = get_BeaconGimmick_method:get_return_type();
local getPos_method = GUIBeaconGimmick_type_def:get_method("getPos");
local getExistAreaInfo_method = GUIBeaconGimmick_type_def:get_method("getExistAreaInfo");

local FieldAreaInfo_type_def = getExistAreaInfo_method:get_return_type();
local get_MapAreaNumSafety_method = FieldAreaInfo_type_def:get_method("get_MapAreaNumSafety");
local get_MapFloorNumSafety_method = FieldAreaInfo_type_def:get_method("get_MapFloorNumSafety");

local QuestOrderParam_type_def = get_QuestOrderParam_method:get_return_type();
local get_IsSameStageDeclaration_method = QuestOrderParam_type_def:get_method("get_IsSameStageDeclaration");
local QuestViewData_field = QuestOrderParam_type_def:get_field("QuestViewData");

local GUIQuestViewData_type_def = QuestViewData_field:get_type();
local get_TargetEmStartArea_method = GUIQuestViewData_type_def:get_method("get_TargetEmStartArea");
local get_Stage_method = GUIQuestViewData_type_def:get_method("get_Stage");

local InputCtrl_field = StartPointList_field:get_type():get_field("_InputCtrl");

local FluentScrollList_type_def = sdk.find_type_definition("ace.cGUIInputCtrl_FluentScrollList`2<app.GUIID.ID,app.GUIFunc.TYPE>");
local getSelectedIndex_method = FluentScrollList_type_def:get_method("getSelectedIndex");
local selectPrevItem_method = FluentScrollList_type_def:get_method("selectPrevItem");
local selectNextItem_method = FluentScrollList_type_def:get_method("selectNextItem");

local hook_datas = nil;

local function clear_datas()
    hook_datas = {
        hasData = false,
        inputCtrl = nil,
        targetCampIdx = nil,
        selectMethod = nil
    };
end

local function dataProcess(GUI050001_ptr, targetCampIdx, list_size)
    setCurrentSelectStartPointIndex_method:call(GUI050001_ptr, targetCampIdx);
    hook_datas.targetCampIdx = targetCampIdx;
    hook_datas.inputCtrl = InputCtrl_field:get_data(StartPointList_field:get_data(GUI050001_ptr));
    hook_datas.selectMethod = (targetCampIdx + 1) < (list_size * 0.5) and selectPrevItem_method or selectNextItem_method;
    hook_datas.hasData = true;
end

sdk.hook(GUI050001_type_def:get_method("initStartPoint"), getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    local QuestOrderParam = get_QuestOrderParam_method:call(this_ptr);
    if get_IsSameStageDeclaration_method:call(QuestOrderParam) == false then
        local startPointlist = get_CurrentStartPointList_method:call(this_ptr);
        local startPointlist_size = GenericList_get_Count_method:call(startPointlist);
        if startPointlist_size > 1 then
            local QuestViewData = QuestViewData_field:get_data(QuestOrderParam);
            local Stage = get_Stage_method:call(QuestViewData);
            local targetEmStartArea = Int32_value_field:get_data(get_TargetEmStartArea_method:call(QuestViewData):get_element(0));
            local areaIconPosList = get_AreaIconPosList_method:call(getDrawData_method:call(get_MapStageDrawData_method:call(get_MAP3D_method:call(Constants.GUIManager)), Stage));
            for i = 0, GenericList_get_Count_method:call(areaIconPosList) - 1 do
                local AreaIconData = GenericList_get_Item_method:call(areaIconPosList, i);
                if get_AreaNum_method:call(AreaIconData) == targetEmStartArea then
                    local targetEmFloorNo = getFloorNumFromAreaNum_method:call(nil, Stage, targetEmStartArea);
                    local AreaIconPos = get_AreaIconPos_method:call(AreaIconData);
                    local sameArea_shortest_distance = nil;
                    local sameArea_idx = nil;
                    local sameFloor_shortest_distance = nil;
                    local sameFloor_idx = nil;
                    local diffFloor_shortest_distance = nil;
                    local diffFloor_idx = nil;
                    for j = 0, startPointlist_size - 1 do
                        local BeaconGimmick = get_BeaconGimmick_method:call(GenericList_get_Item_method:call(startPointlist, j));
                        local FieldAreaInfo = getExistAreaInfo_method:call(BeaconGimmick);
                        local gimmick_MapAreaNum = get_MapAreaNumSafety_method:call(FieldAreaInfo);
                        if sameArea_idx ~= nil and gimmick_MapAreaNum ~= targetEmStartArea then
                            goto continue;
                        else
                            local distance = distance_method:call(nil, AreaIconPos, getPos_method:call(BeaconGimmick));
                            if gimmick_MapAreaNum == targetEmStartArea then
                                if sameArea_idx == nil or distance < sameArea_shortest_distance then
                                    sameArea_shortest_distance = distance;
                                    sameArea_idx = j;
                                end
                            elseif get_MapFloorNumSafety_method:call(FieldAreaInfo) == targetEmFloorNo then
                                if sameFloor_idx == nil or distance < sameFloor_shortest_distance then
                                    sameFloor_shortest_distance = distance;
                                    sameFloor_idx = j;
                                end
                            elseif diffFloor_idx == nil or distance < diffFloor_shortest_distance then
                                diffFloor_shortest_distance = distance;
                                diffFloor_idx = j;
                            end
                        end
                        ::continue::
                    end
                    if sameArea_idx ~= nil then
                        if sameArea_idx > 0 then
                            dataProcess(this_ptr, sameArea_idx, startPointlist_size);
                        end
                    elseif sameFloor_shortest_distance ~= nil and diffFloor_shortest_distance ~= nil and diffFloor_shortest_distance < (sameFloor_shortest_distance * 0.45) then
                        if diffFloor_idx > 0 then
                            dataProcess(this_ptr, diffFloor_idx, startPointlist_size);
                        end
                    elseif sameFloor_idx ~= nil then
                        if  sameFloor_idx > 0 then
                            dataProcess(this_ptr, sameFloor_idx, startPointlist_size);
                        end
                    elseif diffFloor_idx ~= nil then
                        if diffFloor_idx > 0 then
                            dataProcess(this_ptr, diffFloor_idx, startPointlist_size);
                        end
                    else
                        clear_datas();
                    end
                    break;
                end
            end
        end
    end
end);

sdk.hook(sdk.find_type_definition("app.GUI050001_AcceptList"):get_method("onVisibleUpdate"), nil, function()
    if hook_datas.hasData == true then
        local inputCtrl = hook_datas.inputCtrl;
        if getSelectedIndex_method:call(inputCtrl) ~= hook_datas.targetCampIdx then
            hook_datas.selectMethod:call(inputCtrl);
        else
            clear_datas();
        end
    end
end);

clear_datas();