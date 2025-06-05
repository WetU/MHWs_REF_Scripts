local require = _G.require;

local Constants = require("Constants/Constants");
local DisablePP = require("GraphicsMOD/disable_postprocessing");
local LiteEnvironment = require("GraphicsMOD/LiteEnvironment");

local sdk = Constants.sdk;

local DemoMediator_type_def = sdk.find_type_definition("app.DemoMediator");
local get_CurrentTimelineEventID_method = DemoMediator_type_def:get_method("get_CurrentTimelineEventID");

local TimelineEventID_type_def = get_CurrentTimelineEventID_method:get_return_type();
local skip_softlist = { -- List of cutscenes that might require to restore GI and VF
    TimelineEventID_type_def:get_field("evc0001"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0002"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0003"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0004"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0005"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0006"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0008"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0009"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0010"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0011"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0012"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0013"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0014"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0015"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0016"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0017"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0018"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0019"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0020"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0021"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0022"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0023"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0024"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0025"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0026"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0027"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0028"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0029"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0030"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0031"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0032"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0033"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0034"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0035"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0036"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0037"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0038"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0039"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0040"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0042"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0043"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0044"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0045"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0046"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0047"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0048"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0049"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0051"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0052"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0056"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0057"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0059"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0100"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0102"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0103"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0104"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0130"):get_data(nil),
    TimelineEventID_type_def:get_field("evc1001"):get_data(nil),
    TimelineEventID_type_def:get_field("evc1002"):get_data(nil),
    TimelineEventID_type_def:get_field("evc2013"):get_data(nil)
};
local skip_hardlist_GI = { -- List of cutscenes that where Global Illumination is MANDATORY
    TimelineEventID_type_def:get_field("evc0010"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0011"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0019"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0028"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0029"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0037"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0038"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0044"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0103"):get_data(nil)
};
local skip_hardlist_VF= { -- List of cutscenes that where Volumetric Fog is MANDATORY
    TimelineEventID_type_def:get_field("evc0011"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0017"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0020"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0027"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0029"):get_data(nil),
    TimelineEventID_type_def:get_field("evc0130"):get_data(nil),
    TimelineEventID_type_def:get_field("evc2013"):get_data(nil)
};
local is_GI_restored = false;
local is_VF_restored = false;

local function contains(tab, val)
    for i = 1, #tab do
        if tab[i] == val then
            return true;
        end
    end
    return false;
end

local function restoreGI()
    LiteEnvironment.apply_gi_setting(true);
    is_GI_restored = true;
end

local function restoreVF()
    DisablePP.apply_vf_setting(true);
    is_VF_restored = true;
end

local function restoreAll()
    restoreGI();
    restoreVF();
end

DisablePP.ApplySettings();
LiteEnvironment.apply_gi_setting();

sdk.hook(sdk.find_type_definition("app.CameraManager"):get_method("onSceneLoadFadeIn"), function(args)
    if Constants.CameraManager == nil then
        Constants.CameraManager = sdk.to_managed_object(args[2]);
    end
end, function()
    DisablePP.ApplySettings();
    LiteEnvironment.apply_gi_setting();
end);

sdk.hook(DemoMediator_type_def:get_method("onPlayStart(ace.DemoMediatorBase.cParamBase)"), function(args)
    if Constants.DemoMediator == nil then
        Constants.DemoMediator = sdk.to_managed_object(args[2]);
    end
end, function()
    local current_event = get_CurrentTimelineEventID_method:call(Constants.DemoMediator);
    if current_event ~= nil then
        if LiteEnvironment.cutscene_restore_GI == true and LiteEnvironment.cutscene_restore_VF == false then
            if contains(skip_hardlist_VF, current_event) == true then
                restoreAll();
                return;
            end
            if containts(skip_softlist, current_event) == true then
                restoreGI();
            end
        elseif LiteEnvironment.cutscene_restore_GI == false and LiteEnvironment.cutscene_restore_VF == true then
            if contains(skip_hardlist_GI, current_event) == true then
                restoreAll();
                return;
            end
            if contains(skip_softlist, current_event) == true then
                restoreVF();
            end
        elseif LiteEnvironment.cutscene_restore_GI == false and LiteEnvironment.cutscene_restore_VF == false then
            if contains(skip_hardlist_GI, current_event) == true then
                restoreGI();
            end
            if containts(skip_hardlist_VF, current_event) == true then
                restoreVF();
            end
        else
            if contains(skip_softlist, current_event) == true then
                restoreAll();
            end
        end
    end
end);

sdk.hook(DemoMediator_type_def:get_method("unload(ace.DemoMediatorBase.cParamBase)"), nil, function()
    if is_GI_restored == true then
        LiteEnvironment.apply_gi_setting();
        is_GI_restored = false;
    end
    if is_VF_restored == true then
        DisablePP.apply_vf_setting();
        is_VF_restored = false;
    end
end);