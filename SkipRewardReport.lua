local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI070000_type_def = sdk.find_type_definition("app.GUI070000");
local get_IsJudgeMode_method = GUI070000_type_def:get_method("get_IsJudgeMode");
local get__PartsRewardItems_method = GUI070000_type_def:get_method("get__PartsRewardItems");
local GUI_field = GUI070000_type_def:get_field("_GUI");

local get__JudgeAnimationEnd_method = get__PartsRewardItems_method:get_return_type():get_method("get__JudgeAnimationEnd");

local GUI000003_type_def = sdk.find_type_definition("app.GUI000003");
local NotifyWindowApp_field = GUI000003_type_def:get_field("_NotifyWindowApp");

local GUISystemModuleNotifyWindowApp_type_def = NotifyWindowApp_field:get_type();
local get__CurInfoApp_method = GUISystemModuleNotifyWindowApp_type_def:get_method("get__CurInfoApp");
local closeGUI_method = GUISystemModuleNotifyWindowApp_type_def:get_method("closeGUI");

local GUINotifyWindowInfo_type_def = get__CurInfoApp_method:get_return_type();
local get_NotifyWindowId_method = GUINotifyWindowInfo_type_def:get_method("get_NotifyWindowId");
local endWindow_method = GUINotifyWindowInfo_type_def:get_method("endWindow(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfo_type_def:get_method("executeWindowEndFunc");

local GUI070000_DLG02 = get_NotifyWindowId_method:get_return_type():get_field("GUI070000_DLG02"):get_data(nil);

sdk.hook(GUI070000_type_def:get_method("guiVisibleUpdate"), Constants.getObject, function()
    local GUI070000 = thread.get_hook_storage()["this"];
    if get_IsJudgeMode_method:call(GUI070000) == true then
        Constants.set_PlaySpeed_method:call(GUI_field:get_data(GUI070000), get__JudgeAnimationEnd_method:call(get__PartsRewardItems_method:call(GUI070000)) == false and 10.0 or 1.0);
    end
end);

sdk.hook(GUI000003_type_def:get_method("guiOpenUpdate"), Constants.getObject, function()
    local NotifyWindowApp = NotifyWindowApp_field:get_data(thread.get_hook_storage()["this"]);
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil and get_NotifyWindowId_method:call(CurInfoApp) == GUI070000_DLG02 then
        endWindow_method:call(CurInfoApp, 0);
        executeWindowEndFunc_method:call(CurInfoApp);
        closeGUI_method:call(NotifyWindowApp);
    end
end);