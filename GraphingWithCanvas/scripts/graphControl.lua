--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local controlGraph

local controlGraphData = {
  {label = "Control 1", value = 250, color = 0x4A5466},
  {label = "Control 2", value = 250, color = 0x4A5466},
  {label = "Control 3", value = 250, color = 0x4A5466},
  {label = "Control 4", value = 250, color = 0x4A5466}
}

function CBInintControlGraph()
  local initData = {}
  initData.type = "bar"
  initData.ticks = 5
  initData.control = "controlGraphLayer.canvas"
  initData.name = "control_canvas"
  initData.graphFill = 0xE3E6E9
  initData.color = 0x007700
  controlGraph = Graph.create(initData)
  controlGraph:Clear()
  controlGraph:DrawBarGraph(controlGraphData)
end

function UpdateControlGraph()
  controlGraph:Clear()
  controlGraph:DrawBarGraph(controlGraphData)
end

local ActiveSlider = nil
local SliderMax = 155
local SliderMin = 0
local activeIndex = nil

function CalcSliderPosition(mapargs)
	local press_y = mapargs.context_event_data.y
	local v = {}
	control = gre.get_control_attrs(mapargs.context_control, "y")
	local new_y = press_y - control["y"] - (54 / 2)

	if new_y < SliderMin then
		new_y = SliderMin
	elseif new_y > SliderMax then
		new_y = SliderMax
	end

	local data = {}
	data[mapargs.context_control..".sliderOffset"] = new_y
	gre.set_data(data)
	controlGraphData[tonumber(activeIndex)].value = 500 - math.ceil(new_y / SliderMax * 500)
  UpdateControlGraph()
end

function CBSliderPress(mapargs)
  activeIndex = mapargs.index
  ActiveSlider = mapargs.context_control
  CalcSliderPosition(mapargs)
end

function CBSliderMotion(mapargs)
  if ActiveSlider == nil then
    return
  end
  if ActiveSlider == mapargs.context_control then
    CalcSliderPosition(mapargs)
  end
end

function CBSliderRelease(mapargs)
  ActiveSlider = nil
end
