local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local get_UpTimeSecond_method = sdk.find_type_definition("via.Application"):get_method("get_UpTimeSecond"); -- static

local GameFlowManagerBase_type_def = sdk.find_type_definition("ace.GameFlowManagerBase");
local getStateName_method = GameFlowManagerBase_type_def:get_method("getStateName(ace.GameStateType)");
local get_CurrentGameStateType_method = GameFlowManagerBase_type_def:get_method("get_CurrentGameStateType");

local GameFlowManager = sdk.get_managed_singleton("app.GameFlowManager");
log.debug(tostring(getStateName_method:call(GameFlowManager, get_CurrentGameStateType_method:call(GameFlowManager))))

local GUI010001_type_def = sdk.find_type_definition("app.GUI010001");
local Flow_field = GUI010001_type_def:get_field("_Flow");
local Skip_field = GUI010001_type_def:get_field("_Skip");
local EnableSkip_field = GUI010001_type_def:get_field("_EnableSkip");

local GUI010002_type_def = sdk.find_type_definition("app.GUI010002");
local requestClose_method = GUI010002_type_def:get_method("requestClose(System.Boolean)");

local FLOW_type_def = Flow_field:get_type();
local FLOW = {
    STARTUP = FLOW_type_def:get_field("STARTUP"):get_data(nil),
    COPYRIGHT = FLOW_type_def:get_field("COPYRIGHT"):get_data(nil)
};

sdk.hook(GUI010001_type_def:get_method("guiVisibleUpdate"), Constants.getObject, function()
    local GUI010001 = Constants.thread.get_hook_storage()["this"];
    local Flow = Flow_field:get_data(GUI010001);
    if (Flow > FLOW.STARTUP and Flow <= FLOW.COPYRIGHT) and EnableSkip_field:get_data(GUI010001) == true and Skip_field:get_data(GUI010001) == false then
        GUI010001:set_field("_Skip", true);
    end
end);

sdk.hook(GUI010002_type_def:get_method("onOpen"), Constants.getObject, function()
    requestClose_method:call(thread.get_hook_storage()["this"], false);
end);