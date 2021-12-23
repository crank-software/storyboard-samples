--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local sliderOffset
local sliderWidth
local thumbWidth
local pressState = false

function InitSlider(mapargs)
  local data = gre.get_data("sliderControls_layer.sliderGroup.grd_x", 
                            "sliderControls_layer.sliderGroup.sliderTrack.grd_width",
                            "sliderControls_layer.sliderGroup.sliderThumb.grd_width",
                            "sliderControls_layer.sliderGroup.trackHighlightcopy.grd_x")
  sliderOffset = data["sliderControls_layer.sliderGroup.grd_x"] - data["sliderControls_layer.sliderGroup.trackHighlightcopy.grd_x"]
  sliderWidth = data["sliderControls_layer.sliderGroup.sliderTrack.grd_width"]
  thumbWidth = data["sliderControls_layer.sliderGroup.sliderThumb.grd_width"]
end

function UpdateSlider(value)
  local data = {}
  local sliderVal = (value - sliderOffset) / sliderWidth
  local thumbX = sliderVal * sliderWidth - thumbWidth / 2
  
  data["sliderControls_layer.sliderGroup.sliderThumb.grd_x"] = thumbX
  gLastValue = math.floor(sliderVal * 100)
  data["sliderControls_layer.currentValue.value"] = gLastValue
  gre.set_data(data)
end

function PopulateSlider(mapargs)
  local data = {}
  
  gLastValue = gCurrentMenu.items[gLastRow].value
  data["sliderControls_layer.currentValue.value"] = gLastValue

  local targetMenu = "sliderControls_layer.menuGroup.breadcrumb.text"
  data[targetMenu] = gMenuStack[1].title
  gCurrentMenu = gMenuStack[#gMenuStack]
  for i = 2,#gMenuStack do
    data[targetMenu] = string.format("%s > %s", data[targetMenu], gMenuStack[i].title)
  end
  data[targetMenu] = string.format("%s > %s", data[targetMenu], gCurrentMenu.items[gLastRow].title)
  data["nextScreen"] = "slider_screen"
  UpdateSlider(gLastValue / 100 * sliderWidth - thumbWidth/2 + sliderOffset)
  data["screenDirection"] = "right"
  gre.set_data(data)
  gre.send_event("swapScreen")
end

function CBSliderPress(mapargs)
  pressState = true
  local data = mapargs.context_event_data
  UpdateSlider(data.x)
end

function CBSliderMotion(mapargs)
  if (pressState == true) then
    UpdateSlider(mapargs.context_event_data.x)
  end
end

function CBSliderRelease(mapargs)
  pressState = false
end
