--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

-- Looking at the variables in Storyboard you can see that for the toggle, switch, and slider values 
-- an event of value_change is fired off whenever they change
-- This event calls cb_setControls and updates the UI
function CBSetControls()
	local data = {}
	---switch
	local switchKey="controls_layer.switch.value"
	local value = gre.get_data(switchKey)[switchKey]
	if (value==1) then
		data["controls_layer.switch.thumb.grd_y"] = 150
		data["controls_layer.switch.thumb.text"] = "OFF"
	else
		data["controls_layer.switch.thumb.grd_y"] = 54
		data["controls_layer.switch.thumb.text"] = "ON"
	end	

	---the stepper needs no changes

	---slider Control
	local sliderKey="controls_layer.slider.value"
	local value=gre.get_data(sliderKey)[sliderKey]
	data["controls_layer.slider.sliderValue.text"] = string.format("%.1f", value)
	value = (value/20)*192

	data["controls_layer.slider.sliderfill.grd_y"]=196+50-value
	data["controls_layer.slider.sliderfill.grd_height"]=value

	--toggle Control
	local toggleKey="controls_layer.toggle.value"
	local value = gre.get_data(toggleKey)[toggleKey]

	if (value==1) then
		data["controls_layer.toggle.toggleFill.grd_hidden"] = 0
	else
		data["controls_layer.toggle.toggleFill.grd_hidden"] = 1
	end
	gre.set_data(data)
end


function CBSwitchPress(mapargs)
	local value = gre.get_data("controls_layer.switch.value")["controls_layer.switch.value"]
	local data = {}
	if (value==1) then
		data["controls_layer.switch.value"] = 0
	else
		data["controls_layer.switch.value"] = 1
	end
	gre.set_data(data)
end


function CBStepper(mapargs)
	local data = {}
  	data["controls_layer.stepper.value"] = mapargs.value + mapargs.amount
	if (data["controls_layer.stepper.value"] < 0) then
		data["controls_layer.stepper.value"] = 0
	end
	gre.set_data(data)
end

---slider logic
local sliderPressed = 0

local function sliderProcess(event_data)
	local cinfo = gre.get_control_attrs("controls_layer.slider", "y")
	local local_y = event_data.y - cinfo.y - 50
	local data = {}
	value = ((200 - local_y) / 200) * 20
	data["controls_layer.slider.value"]=value
	gre.set_data(data)
end

function CBSliderPress(mapargs)
	sliderPressed = 1
	sliderProcess(mapargs.context_event_data)
end


function CBSliderMotion(mapargs)
	if (sliderPressed == 0) then
		return
	end
	sliderProcess(mapargs.context_event_data)
end


function CBSliderRelease(mapargs)
	if (sliderPressed==0) then
		return
	end
	sliderProcess(mapargs.context_event_data)
	sliderPressed = 0
end


---A simple toggle
function CBTogglePress()
	local key = "controls_layer.toggle.value"
	local data = gre.get_data(key)
	if (data[key]==1) then
		data[key] = 0
	else
		data[key] = 1
	end
	gre.set_data(data)
end
