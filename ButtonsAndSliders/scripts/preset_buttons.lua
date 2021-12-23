--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gPresetStr = "PresetsLayer.Preset%d"
local gNumPresets = 6

function CBPresetPress(mapargs)
	local data = {}
	
	for i = 1, gNumPresets do
		local preset_name = string.format(gPresetStr, i)
		if (preset_name == mapargs.context_control) then	
			data[preset_name..".text_colour"] = 0xFFDD000
			data[preset_name..".image"] = "images/preset_on.png"
		else
			data[preset_name..".text_colour"] = 0x252525
			data[preset_name..".image"] = "images/preset_off.png"
		end
	end
	gre.set_data(data)	
end

function CBPresetPowerOn(mapargs)
	local data = {}
	local preset_name = string.format(gPresetStr, 1)
	data[preset_name..".text_colour"] = 0xFFDD000
	data[preset_name..".image"] = "images/preset_on.png"
	
	for i = 2, gNumPresets do
		preset_name = string.format(gPresetStr, i)
		data[preset_name..".text_colour"] = 0x252525
		data[preset_name..".image"] = "images/preset_off.png"
	end
	gre.set_data(data)	
end

function CBPresetPowerOff(mapargs)
	local data = {}
	
	for i = 1, gNumPresets do
		local preset_name = string.format(gPresetStr, i)
		data[preset_name..".text_colour"] = 0x252525
		data[preset_name..".image"] = "images/preset_off.png"
	end
	gre.set_data(data)	
end
