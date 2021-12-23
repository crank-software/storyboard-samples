--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local SLIDER_MIN = 8
local SLIDER_MAX = 108
local SLIDER_HEIGHT = 54
local MAX_TICKS = 6 
local gActiveSlider = nil


function CalcSliderPosition(mapargs)
	local press_y = mapargs.context_event_data.y
	local v = {}
	local control = gre.get_control_attrs(mapargs.context_control, "y")
	local new_y = press_y - control["y"] - (SLIDER_HEIGHT / 2)
	
	if (new_y < SLIDER_MIN) then
		new_y = SLIDER_MIN
	elseif new_y > SLIDER_MAX then
		new_y = SLIDER_MAX
	end
	
	gre.set_value(mapargs.context_control..".slider_offset", new_y)
	
	local num_ticks = (MAX_TICKS + 1) - math.ceil((new_y / (SLIDER_MAX - SLIDER_MIN)) * MAX_TICKS)
	local slider_num = gre.get_value(mapargs.context_control..".slider_num")
	SetEqualizer(slider_num, num_ticks)
end

function CBSliderPress(mapargs)
	gActiveSlider = mapargs.context_control
	CalcSliderPosition(mapargs)
end

function CBSliderMotion(mapargs)
	if (gActiveSlider == nil) then
		return
	end
	
	if (gActiveSlider == mapargs.context_control) then
		CalcSliderPosition(mapargs)
	end
end

function CBSliderRelease(mapargs)
	gActiveSlider = nil	
end

function SetEqualizer(eq_num, num)
	local data = {}
	local name_str = "EqualizerLayer.Equalizer%d.alpha.%d.1"
	
	for i=1, 6 do
		local name = string.format(name_str, eq_num, i)
		if (i >  (6 - num)) then
			data[name] = 255
		else
		 	data[name] = 0
		end
	end
	gre.set_data(data)
end

function CBEqualizerOn(mapargs)
	SetEqualizer(1,3)
	SetEqualizer(2,3)
	SetEqualizer(3,3)
	SetEqualizer(4,3)
	SetEqualizer(5,3)
	SetEqualizer(6,3)
end

function CBEqualizerOff(mapargs)
	SetEqualizer(1,0)
	SetEqualizer(2,0)
	SetEqualizer(3,0)
	SetEqualizer(4,0)
	SetEqualizer(5,0)
	SetEqualizer(6,0)
end
