--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gToggleState = {} -- table used to track state for all toggles
local gCur5dayToggle = false
local gCur5dayAnimationActive = false


function CBToggleControl(mapargs) 
  local toggle
	
  if (mapargs.context_control == 'fan_layer.slider_ac_control') then
    toggle = 'ac'
  elseif (mapargs.context_control == 'fan_layer.slider_fan_control') then
    toggle = 'fan'
  elseif (mapargs.context_control == 'fan_layer.slider_timer_control') then
    toggle = 'timer'
  elseif (mapargs.context_control == 'settings_layer.degrees_toggle') then
    toggle = 'units'
  end
	
  gre.send_event ("toggle_"..toggle, "thermostat_backend")
end

function CBShow5dayComplete()
  gCur5dayToggle = true
  gCur5dayAnimationActive = false
end

function CBHideMonToFriComplete()
  gCur5dayToggle = false
  gCur5dayAnimationActive = false
end

function CBToggleCur5day()
  if (gCur5dayToggle == false) then
    if (gCur5dayAnimationActive == false) then
      gCur5dayAnimationActive = true
      gre.send_event("run_show_5day")
    end
  else
    if (gCur5dayAnimationActive == false) then
      gCur5dayAnimationActive = true
      gre.send_event("run_hide_mon_to_fri")
    end
  end
end

function CBSetToggle(control, value)
    if (gToggleState[control] == nil) then
    -- if it doesn't exisit yet create the toggle and set it to off
      gToggleState[control] = 0
    end
    
    if (value ~= nil and gToggleState[control] == value) then
      return
    end
    
    if (value == nil) then
      if (gToggleState[control] == 0) then
        gToggleState[control] = 1
      else
        gToggleState[control] = 0
      end
    else
      gToggleState[control] = value
    end
    AnimateToggle(control)
end

function AnimateToggle(toggle)
  local ani_step = {}
  local id = gre.animation_create(60, 1)
  
  ani_step["rate"] = "linear"
  ani_step["duration"] = 250
  ani_step["key"] = toggle..".x_off"

  if (gToggleState[toggle] == 1) then
    ani_step["from"] = 0
    ani_step["to"] = 62
  else
    ani_step["from"] = 62
    ani_step["to"] = 0
  end
  
  gre.animation_add_step(id, ani_step)
  gre.animation_trigger(id)
end
