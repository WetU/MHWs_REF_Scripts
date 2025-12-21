local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;

local sdk = Constants.sdk;
local thread = Constants.thread;
local re = Constants.re;

local getThisPtr = Constants.getThisPtr;

local HunterQuestActionController_type_def = sdk.find_type_definition("app.mcHunterQuestActionController");
local showStamp_method = HunterQuestActionController_type_def:get_method("showStamp(app.mcHunterQuestActionController.QUEST_ACTION_TYPE)");

local QUEST_ACTION_TYPE_type_def = sdk.find_type_definition("app.mcHunterQuestActionController.QUEST_ACTION_TYPE");
local QUEST_ACTION_TYPE = {
    NONE = QUEST_ACTION_TYPE_type_def:get_field("NONE"):get_data(nil),
    MAX = QUEST_ACTION_TYPE_type_def:get_field("MAX"):get_data(nil)
};

local GUI020201_type_def = sdk.find_type_definition("app.GUI020201");
local GUI020201_CurType_field = GUI020201_type_def:get_field("_CurType");
local GUI_field = GUI020201_type_def:get_field("_GUI");

local set_PlaySpeed_method = GUI_field:get_type():get_method("set_PlaySpeed(System.Single)");

local GUI020216_type_def = sdk.find_type_definition("app.GUI020216");
local GUI020216_CurType_field = GUI020216_type_def:get_field("_CurType");

local TYPE_MAX = GUI020201_CurType_field:get_type():get_field("MAX"):get_data(nil);

local FALSE_ptr = sdk.to_ptr(false);
local ZERO_float_ptr = sdk.float_to_ptr(0.0);

sdk.hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), nil, function()
    return FALSE_ptr;
end);

sdk.hook(HunterQuestActionController_type_def:get_method("checkQuestActionEnable(app.mcHunterQuestActionController.QUEST_ACTION_TYPE)"), function(args)
    local storage = thread.get_hook_storage();
    storage.this_ptr = args[2];
    storage.actionType_ptr = args[3];
end, function(retval)
    if (sdk.to_int64(retval) & 1) == 1 then
        local storage = thread.get_hook_storage();
        local actionType = sdk.to_int64(storage.actionType_ptr) & 0xFFFFFFFF;
        for _, v in pairs(QUEST_ACTION_TYPE) do
            if actionType == v then
                return retval;
            end
        end
        showStamp_method:call(storage.this_ptr, actionType);
    end
    return retval;
end);

sdk.hook(HunterQuestActionController_type_def:get_method("requestDelayStamp(app.mcHunterQuestActionController.QUEST_ACTION_TYPE, System.Single)"), function(args)
    if sdk.to_float(args[4]) > 0.0 then
        args[4] = ZERO_float_ptr;
    end
end);

local GUI020201_datas = {
    GUI = nil,
    reqSkip = false,
    isSetted = false
};

sdk.hook(GUI020201_type_def:get_method("onOpen"), getThisPtr, function()
    local GUI020201_ptr = thread.get_hook_storage()["this_ptr"];
    if GUI020201_CurType_field:get_data(GUI020201_ptr) ~= TYPE_MAX then
        if GUI020201_datas.GUI == nil then
            GUI020201_datas.GUI = GUI_field:get_data(GUI020201_ptr);
        end
        GUI020201_datas.reqSkip = true;
    end
end);

sdk.hook(GUI020201_type_def:get_method("guiVisibleUpdate"), nil, function()
    if GUI020201_datas.reqSkip == true and GUI020201_datas.isSetted == false then
        GUI020201_datas.isSetted = true;
        GUI020201_datas.reqSkip = false;
        set_PlaySpeed_method:call(GUI020201_datas.GUI, 10.0);
    end
end);

sdk.hook(GUI020201_type_def:get_method("onCloseApp"), nil, function()
    if GUI020201_datas.isSetted == true then
        GUI020201_datas.isSetted = false;
        set_PlaySpeed_method:call(GUI020201_datas.GUI, 1.0);
    end
end);

local GUI020216_datas = {
    GUI = nil,
    reqSkip = false,
    isSetted = false
};

sdk.hook(GUI020216_type_def:get_method("onOpen"), getThisPtr, function()
    local GUI020216_ptr = thread.get_hook_storage()["this_ptr"];
    if GUI020216_CurType_field:get_data(GUI020216_ptr) ~= TYPE_MAX then
        if GUI020216_datas.GUI == nil then
            GUI020216_datas.GUI = GUI_field:get_data(GUI020216_ptr);
        end
        GUI020216_datas.reqSkip = true;
    end
end);

sdk.hook(GUI020216_type_def:get_method("guiVisibleUpdate"), nil, function()
    if GUI020216_datas.reqSkip == true and GUI020216_datas.isSetted == false then
        GUI020216_datas.isSetted = true;
        GUI020216_datas.reqSkip = false;
        set_PlaySpeed_method:call(GUI020216_datas.GUI, 10.0);
    end
end);

sdk.hook(GUI020216_type_def:get_method("onCloseApp"), nil, function()
    if GUI020216_datas.isSetted == true then
        GUI020216_datas.isSetted = false;
        set_PlaySpeed_method:call(GUI020216_datas.GUI, 1.0);
    end
end);

re.on_script_reset(function()
    if GUI020201_datas.isSetted == true then
        set_PlaySpeed_method:call(GUI020201_datas.GUI, 1.0);
    end
    if GUI020216_datas.isSetted == true then
        set_PlaySpeed_method:call(GUI020216_datas.GUI, 1.0);
    end
end);