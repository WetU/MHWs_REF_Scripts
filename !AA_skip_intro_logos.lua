local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI010001_type_def = sdk.find_type_definition("app.GUI010001");
local Flow_field = GUI010001_type_def:get_field("_Flow");
local Skip_field = GUI010001_type_def:get_field("_Skip");
local EnableSkip_field = GUI010001_type_def:get_field("_EnableSkip");

local FLOW_type_def = sdk.find_type_definition("app.GUI010001.FLOW");
local STARTUP = FLOW_type_def:get_field("STARTUP"):get_data(nil); -- static
local COPYRIGHT = FLOW_type_def:get_field("COPYRIGHT"):get_data(nil); -- static

sdk.hook(GUI010001_type_def:get_method("guiVisibleUpdate"), Constants.getObject, function()
    local GUI010001 = thread.get_hook_storage()["this"];
    if GUI010001 ~= nil then
        local Flow = Flow_field:get_data(GUI010001);
        if (Flow > STARTUP and Flow <= COPYRIGHT) and EnableSkip_field:get_data(GUI010001) == true and Skip_field:get_data(GUI010001) == false then
            GUI010001:set_field("_Skip", true);
        end
    end
end);