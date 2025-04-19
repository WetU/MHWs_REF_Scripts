local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local GUI010001_type_def = sdk.find_type_definition("app.GUI010001");
local Flow_field = GUI010001_type_def:get_field("_Flow");
local Skip_field = GUI010001_type_def:get_field("_Skip");
local EnableSkip_field = GUI010001_type_def:get_field("_EnableSkip");

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