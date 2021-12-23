--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gToggleState = {} -- table used to track state for all toggles
local gCur5dayToggle = false

--This is used to properly scale the toggle animation no matter the size of
--the application.  The ratio is based off of the initial development size of 800x480.

local ORIG_SLIDER_WIDTH = 140
local ORIG_SLIDER_HEIGHT = 58


function CBToggleControl(mapargs)
  local control = mapargs.context_control
  
  ---@field gre#animationdata
  local anim_data = {}
  
  -- triggering an animation with context will allow context variables to be resolved (i.e. ${control:x_off})
  anim_data["context"] = control
  
  -- triggering slider_on and slider_off with the same id makes these animations mutually exclusive for this control
  -- which means only slider_on or slider_off can run at once
  anim_data["id"] = control 
  
  if (gToggleState[control] == nil) then
    -- if it doesn't exist yet create the toggle and set it to off
    gToggleState[control] = false
  end
  gToggleState[control] = not gToggleState[control]
  
  local state = gre.animation_get_state("slider", anim_data)
  
  --trigger the animation from the current progress, just reverse it
  -- When running forwards, we do not want to cleanup, so that we can remember how to go backwards again.
  -- When running backwards, we can cleanup because an animation always knows how to run forwards.
  anim_data.progress = state.progress
  anim_data.reverse = not gToggleState[control]
  anim_data.cleanup = anim_data.reverse
  
  gre.animation_trigger("slider_toggle", anim_data)
  
  if (control == "settings_layer.degrees_toggle") then
    ChangeDegrees(gToggleState[control])
  end
end

function CBToggleWeather()
  ---@field gre##animationstate state
  local state = gre.animation_get_state("weather_toggle")
  
  if (state.state ~= gre.ANIMATION_NOT_RUNNING and state.state ~= gre.ANIMATION_COMPLETE) then
    --We only trigger the animation if it's not currently running.
    return
  end
   
  local reverse = false
  if (state.progress == 1) then
    reverse = true
  end
  gre.animation_trigger("weather_toggle", {cleanup=false, reverse=reverse, progress=state.progress})
end
