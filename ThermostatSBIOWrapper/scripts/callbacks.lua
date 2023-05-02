--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local csv = require("csv")

local gTemp
local gTargetTemp
local gMinTemp
local gMaxTemp
local gTempUnit
local gDashWidth = 12
local gNumDash = 27
local gTimeoutID = nil
local gBackendChannel = "thermostat_backend"


function ChangeDegrees(state)
	local data = {}
	if (state == 0) then
		--fahrenheit
		data["thermostat_layer.temp_scale.text"] = "Fahrenheit"
		data["weather_current_layer.current_temperature.text"] = "3°F"
		gMinTemp = 46
		gMaxTemp = 95
		gTempUnit = 0		
	else
		--celsius
		data["thermostat_layer.temp_scale.text"] = "Celsius"
		data["weather_current_layer.current_temperature.text"] = "-16°C"
		gMinTemp = 8
		gMaxTemp = 35
		gTempUnit = 1		
	end
	
--	data["thermostat_layer.temp_value.text"] = string.format('%d°', gTemp)
	gre.set_data(data)
	SetBarTemp(gTemp)	
end

function CBTempUp(mapargs) 
	gre.send_event_data (
    "increase_temperature",
    "4u1 num", 
    {num = 1}, 
    gBackendChannel
  )
end

function CBTempDown(mapargs) 
  gre.send_event_data (
    "decrease_temperature", 
    "4u1 num", 
    {num = 1}, 
    gBackendChannel
  )
end

function SetBarTemp(cur_temp)
	local data = {}
	local width = math.ceil((cur_temp - gMinTemp)/(gMaxTemp - gMinTemp) * gNumDash) * gDashWidth
	data["thermostat_layer.full_scale.grd_width"] = width
	gre.set_data(data)
end

function DisplayTargetTemp()
  local data = {}
  data["thermostat_layer.temp_value.text"] = string.format('%d°', gTargetTemp)
  gre.timer_clear_timeout(gTimeoutID)
  gTimeoutID = gre.timer_set_timeout(DisplayActualTemp,1500)
  gre.set_data(data)
end

function DisplayActualTemp()
  local data ={}
  gTimeoutID = nil
  data["thermostat_layer.temp_value.text"] = string.format('%d°', gTemp)
  gre.set_data(data)
end

--If multiple languages are included in one csv file, col_num should be specified,
--If no column number is passed to the function, the column number will default to 2.
function LoadLanguage(fname,col_num)
  local data = {}
  local column
  local k 
  
  if(col_num == nil)then
    column = 2
  else
    column = col_num
  end
  
  local f = csv.open(gre.SCRIPT_ROOT.."/../translations/"..fname)
  for fields in f:lines() do
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

function CBUpdateThermostat(mapargs) 
  local ev_data = mapargs.context_event_data
  
  if (ev_data.current_temperature ~= nil and ev_data.current_temperature ~= gTemp) then
    gTemp = ev_data.current_temperature
    DisplayActualTemp()
  end
  if (ev_data.target_temperature ~=nil and ev_data.target_temperature ~= gTargetTemp) then
    gTargetTemp = ev_data.target_temperature
    DisplayTargetTemp()
  end
  if (ev_data.ac ~= nil) then  
    CBSetToggle('fan_layer.slider_ac_control', ev_data.ac)
  end
  if (ev_data.fan ~= nil) then
    CBSetToggle('fan_layer.slider_fan_control', ev_data.fan)
  end
  if (ev_data.timer ~= nil) then
    CBSetToggle('fan_layer.slider_timer_control', ev_data.timer)
  end
  if (ev_data.units ~= nil) then
    ChangeDegrees(ev_data.units)
    CBSetToggle('settings_layer.degrees_toggle', gTempUnit)
  end  
end