local Constants = _G.require("Constants/Constants");

local hook = Constants.hook;
local to_float = Constants.to_float;

local ZERO_float_ptr = Constants.ZERO_float_ptr;
local shortVisible = Constants.float_to_ptr(0.01);

local FadeController_type_def = Constants.find_type_definition("ace.cFadeController");

hook(FadeController_type_def:get_method("requestFadeOutCore(System.Single, System.Single, System.Single, ace.cFadeRequest.FADE_PRIORITY)"), function(args)
    args[3] = shortVisible;
    if to_float(args[4]) > 0.01 then
        args[4] = shortVisible;
    end
    args[5] = ZERO_float_ptr;
end);

hook(FadeController_type_def:get_method("requestFadeInCore(System.Single, ace.cFadeRequest.FADE_PRIORITY)"), function(args)
    args[3] = ZERO_float_ptr;
end);