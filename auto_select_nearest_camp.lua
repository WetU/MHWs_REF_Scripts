local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local table = Constants.table;
local ipairs = Constants.ipairs;

local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;

local distance_method = sdk.find_type_definition("via.MathEx"):get_method("distance(via.vec3, via.vec3)"); -- static

local getFloorNumFromAreaNum_method = sdk.find_type_definition("app.GUIUtilApp.MapUtil"):get_method("getFloorNumFromAreaNum(app.FieldDef.STAGE, System.Int32)"); -- static

local get_MapStageDrawData_method = Constants.VariousDataManagerSetting_type_def:get_method("get_MapStageDrawData");

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

local STAGES = {};
for _, v in ipairs(get_Stage_method:get_return_type():get_fields()) do
    if v:is_static() == true then
        table.insert(STAGES, v:get_data(nil));
    end
end

local DrawDatas = nil;

local hook_datas = {
    hasData = false,
    inputCtrl = nil,
    targetCampIdx = nil,
    selectMethod = nil
};

local function clear_datas()
    hook_datas = {
        hasData = false,
        inputCtrl = nil,
        targetCampIdx = nil,
        selectMethod = nil
    };
end

local function calcbyFloor(sameFloor_distance, diffFloor_distance)
    if sameFloor_distance ~= nil and diffFloor_distance ~= nil then
        return diffFloor_distance < (sameFloor_distance * 0.45);
    end
    return nil;
end

sdk.hook(GUI050001_type_def:get_method("initStartPoint"), Constants.getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    local startPointlist = get_CurrentStartPointList_method:call(this_ptr);
    local startPointlist_size = GenericList_get_Count_method:call(startPointlist);
    if startPointlist_size > 1 then
        local QuestOrderParam = get_QuestOrderParam_method:call(this_ptr);
        if get_IsSameStageDeclaration_method:call(QuestOrderParam) == false then
            if DrawDatas == nil then
                DrawDatas = {};
                local MapStageDrawData = get_MapStageDrawData_method:call(Constants.getVariousDataManagetSetting());
                for _, stageID in ipairs(STAGES) do
                    local DrawData = getDrawData_method:call(MapStageDrawData, stageID);
                    if DrawData ~= nil then
                        local AreaIconPosList = get_AreaIconPosList_method:call(DrawData);
                        local tempTbl = {};
                        for i = 0, GenericList_get_Count_method:call(AreaIconPosList) - 1 do
                            local AreaIconData = GenericList_get_Item_method:call(AreaIconPosList, i);
                            if AreaIconData ~= nil then
                                tempTbl[get_AreaNum_method:call(AreaIconData)] = get_AreaIconPos_method:call(AreaIconData);
                            end
                        end
                        DrawDatas[stageID] = tempTbl;
                    end
                end
            end
            local QuestViewData = QuestViewData_field:get_data(QuestOrderParam);
            local Stage = get_Stage_method:call(QuestViewData);
            local TargetEmStartArea_array = get_TargetEmStartArea_method:call(QuestViewData);
            local areaIconPosList = DrawDatas[Stage];
            local sameArea_shortest_distance = nil;
            local sameArea_idx = nil;
            local sameFloor_shortest_distance = nil;
            local sameFloor_idx = nil;
            local diffFloor_shortest_distance = nil;
            local diffFloor_idx = nil;
            for i = 0, TargetEmStartArea_array:get_size() - 1 do
                local emAreaNo = TargetEmStartArea_array:get_element(i);
                if emAreaNo ~= nil then
                    local targetEmAreaNo = Int32_value_field:get_data(emAreaNo);
                    local areaIconPos = areaIconPosList[targetEmAreaNo];
                    if areaIconPos ~= nil then
                        local targetEmFloorNo = getFloorNumFromAreaNum_method:call(nil, Stage, targetEmAreaNo);
                        for j = 0, startPointlist_size - 1 do
                            local BeaconGimmick = get_BeaconGimmick_method:call(GenericList_get_Item_method:call(startPointlist, j));
                            local FieldAreaInfo = getExistAreaInfo_method:call(BeaconGimmick);
                            local gimmick_MapAreaNum = get_MapAreaNumSafety_method:call(FieldAreaInfo);
                            if sameArea_idx ~= nil and gimmick_MapAreaNum ~= targetEmAreaNo then
                                goto continue;
                            else
                                local distance = distance_method:call(nil, areaIconPos, getPos_method:call(BeaconGimmick));
                                if targetEmAreaNo == gimmick_MapAreaNum then
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
                    end
                end
            end
            local targetStartPoint_idx = sameArea_idx or (calcbyFloor(sameFloor_shortest_distance, diffFloor_shortest_distance) == true and diffFloor_idx) or sameFloor_idx or diffFloor_idx;
            if targetStartPoint_idx ~= nil and targetStartPoint_idx > 0 then
                setCurrentSelectStartPointIndex_method:call(this_ptr, targetStartPoint_idx);
                hook_datas.targetCampIdx = targetStartPoint_idx;
                hook_datas.inputCtrl = InputCtrl_field:get_data(StartPointList_field:get_data(this_ptr));
                hook_datas.selectMethod = (targetStartPoint_idx + 1) < (startPointlist_size * 0.5) and selectPrevItem_method or selectNextItem_method;
                hook_datas.hasData = true;
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