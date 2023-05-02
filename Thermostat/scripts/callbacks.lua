--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local csv = require("csv")

local gTemp = 68
local gMinTemp = 46
local gMaxTemp = 95
local gDashWidth = 12
local gNumDash = 27


function CBTempInit(mapargs)
	SetBarTemp(gTemp)
end

function ChangeDegrees(state)
	local data = {}
	
	if (state == false) then
		--fahrenheit
		data["thermostat_layer.temp_scale.text"] = "Fahrenheit"
		data["weather_current_layer.current_temperature.text"] = "3°F"
		gTemp = math.floor((gTemp * (9/5)) + 32)
		gMinTemp = 46
		gMaxTemp = 95		
	else
		--celsius
		data["thermostat_layer.temp_scale.text"] = "Celsius"
		data["weather_current_layer.current_temperature.text"] = "-16°C"
		gTemp = math.ceil((gTemp - 32) * (5/9))
		gMinTemp = 8
		gMaxTemp = 35		
	end
	
	data["thermostat_layer.temp_value.text"] = string.format('%d°', gTemp)
	gre.set_data(data)
	SetBarTemp(gTemp)	
end

function CBTempUp(mapargs) 
	local data = {}
	gTemp = gTemp + 1
	if (gTemp > gMaxTemp) then
		gTemp = gMaxTemp
	end
	data["thermostat_layer.temp_value.text"] = string.format('%d°', gTemp)
	gre.set_data(data)
	SetBarTemp(gTemp)
end

function CBTempDown(mapargs) 
	local data = {}
	gTemp = gTemp - 1
	if (gTemp < gMinTemp) then
		gTemp = gMinTemp
	end	
	data["thermostat_layer.temp_value.text"] = string.format('%d°', gTemp)
	gre.set_data(data)
	SetBarTemp(gTemp)
end

function SetBarTemp(cur_temp)
	local data = {}
	local width = math.ceil((cur_temp - gMinTemp)/(gMaxTemp - gMinTemp) * gNumDash) * gDashWidth
	data["thermostat_layer.full_scale.grd_width"] = width
	gre.set_data(data)
end

--If multiple languages are included in one csv file, col_num should be specified,
--If no column number is passed to the function, the column number will default to 2.
function LoadLanguage(fname,col_num)
	local data = {}
  local column
  
  if(col_num == nil)then
    column = 2
  else
    column = col_num
  end
  
  local f = csv.open(gre.SCRIPT_ROOT.."/../translations/"..fname)
  for fields in f:lines() do
    local k
    for i, v in ipairs(fields) do 
      if(i == 1)then
        k = v
      elseif(i == column)then  
        data[k]=v
      end
    end
  end
	
	return data
end

function CBLoadLanguage(mapargs) 
	local lang_data = {}
	lang_data = LoadLanguage(mapargs.language)
	gre.set_data(lang_data)
end
