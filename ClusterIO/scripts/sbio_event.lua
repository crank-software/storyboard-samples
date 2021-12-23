--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

---
-- Update handler for Speed and RPM 
function CBUpdateEvent(mapargs)
	local ev = mapargs.context_event_data
	local data  = {}

	local speed_rot = (ev.speed * (214/200)) - 107
	local rpm_rot = (ev.rpm / 10000) * 49
	
	data["speedometer.pointer_speedometer.rot"] = speed_rot 
	data["speedometer_content.speed.text"] = tostring(ev.speed)
	data["tach_exterior.pointer_tach_exterior.rot"] = rpm_rot
	
	gre.set_data(data)
end
--- 
-- Sets the battery level icons based battery level as a percentage 
-- @param battery as a percentage 
function SetBatteryLevel(battery)
  local data = {} 
  data["battery.bat_8.grd_hidden"] = 1 
  data["battery.bat_9.grd_hidden"] = 1 
  data["battery.bat_10.grd_hidden"] = 1 
  data["battery.bat_11.grd_hidden"] = 1 
  data["battery.bat_12.grd_hidden"] = 1 
  data["battery.bat_13.grd_hidden"] = 1 
  data["battery.bat_14.grd_hidden"] = 1 
  data["battery.bat_15.grd_hidden"] = 1 
  data["battery.bat_16.grd_hidden"] = 1 
  data["battery.bat_17.grd_hidden"] = 1 
  
  if (battery > 10 ) then 
    data["battery.bat_8.grd_hidden"] = 0 
  end 
  if (battery > 20 ) then 
    data["battery.bat_9.grd_hidden"] = 0 
  end 
  if (battery > 20 ) then 
    data["battery.bat_10.grd_hidden"] = 0
  end 
  if (battery > 30 ) then  
    data["battery.bat_11.grd_hidden"] = 0
  end 
  if (battery > 40 ) then  
    data["battery.bat_12.grd_hidden"] = 0
  end 
  if (battery > 50 ) then  
    data["battery.bat_13.grd_hidden"] = 0
  end 
  if (battery > 60 ) then  
    data["battery.bat_14.grd_hidden"] = 0
  end 
  if (battery > 70 ) then  
    data["battery.bat_15.grd_hidden"] = 0
  end 
  if (battery > 80 ) then  
    data["battery.bat_16.grd_hidden"] = 0
  end 
  if (battery > 90 ) then  
    data["battery.bat_17.grd_hidden"] = 0 
  end
  gre.set_data(data)
end 

--- 
-- Sets the fuel level icons based fuel level as a percentage 
-- @param fuel as a percentage 
function SetFuelLevel(fuel)
  local data = {} 
  data["gas_exterior.full_1.grd_hidden"] = 1 
  data["gas_exterior.full_2.grd_hidden"] = 1 
  data["gas_exterior.full_3.grd_hidden"] = 1 
  data["gas_exterior.full_4.grd_hidden"] = 1 
  data["gas_exterior.full_5.grd_hidden"] = 1 
  data["gas_exterior.full_6.grd_hidden"] = 1 
  data["gas_exterior.full_7.grd_hidden"] = 1 
  data["gas_exterior.full_8.grd_hidden"] = 1 
  data["gas_exterior.full_9.grd_hidden"] = 1 
  data["gas_exterior.full_10.grd_hidden"] = 1 
  
  if (fuel > 10 ) then 
    data["gas_exterior.full_1.grd_hidden"] = 0 
  end 
  if (fuel > 20 ) then 
    data["gas_exterior.full_2.grd_hidden"] = 0 
  end 
  if (fuel > 20 ) then 
    data["gas_exterior.full_3.grd_hidden"] = 0
  end 
  if (fuel > 30 ) then  
    data["gas_exterior.full_4.grd_hidden"] = 0
  end 
  if (fuel > 40 ) then  
    data["gas_exterior.full_5.grd_hidden"] = 0
  end 
  if (fuel > 50 ) then  
    data["gas_exterior.full_6.grd_hidden"] = 0
  end 
  if (fuel > 60 ) then  
    data["gas_exterior.full_7.grd_hidden"] = 0
  end 
  if (fuel > 70 ) then  
    data["gas_exterior.full_8.grd_hidden"] = 0
  end 
  if (fuel > 80 ) then  
    data["gas_exterior.full_9.grd_hidden"] = 0
  end 
  if (fuel > 90 ) then  
    data["gas_exterior.full_10.grd_hidden"] = 0 
  end
  gre.set_data(data)
end 

--- 
-- Sets the oil level icons based oil level as a percentage 
-- @param oil as a percentage 
function  SetOilLevel(oil)
  local data = {} 

  data["oil.0_glow.grd_hidden"] = 1
  data["oil.0half_glow.grd_hidden"] = 1  
  data["oil.1_glow.grd_hidden"] = 1
  data["oil.1half_glow.grd_hidden"] = 1  
  data["oil.2_glow.grd_hidden"] = 1
  data["oil.2half_glow.grd_hidden"] = 1  
  data["oil.3_glow.grd_hidden"] = 1
  data["oil.3half_glow.grd_hidden"] = 1  
  data["oil.4_glow.grd_hidden"] = 1 
 
  if (oil > 10 ) then 
    data["oil.0_glow.grd_hidden"] = 0
  end 
  if (oil > 20 ) then 
    data["oil.0half_glow.grd_hidden"] = 0  
  end 
  if (oil > 30 ) then 
    data["oil.1_glow.grd_hidden"] = 0
  end 
  if (oil > 40 ) then 
    data["oil.1half_glow.grd_hidden"] = 0  
  end 
  if (oil > 50 ) then 
    data["oil.2_glow.grd_hidden"] = 0
  end 
  if (oil > 60 ) then 
    data["oil.2half_glow.grd_hidden"] = 0
  end 
  if (oil > 70 ) then   
    data["oil.3_glow.grd_hidden"] = 0
  end 
  if (oil > 80 ) then 
    data["oil.3half_glow.grd_hidden"] = 0
  end 
  if (oil > 90 ) then   
    data["oil.4_glow.grd_hidden"] = 0
  end 

  gre.set_data(data)
end 

---
-- Update handler for system data 
function CBUpdateSystemEvent(mapargs) 
  local ev = mapargs.context_event_data
  
  SetOilLevel(ev.oil)
  SetFuelLevel(ev.fuel)
  SetBatteryLevel(ev.battery)
  
  local data  = {}
  if (tonumber(ev.engine_code) == 0) then 
    data["indicators.brake_glow.grd_hidden"] = 1
    data["indicators.engine_glow.grd_hidden"] = 1
    data["indicators.ABS_glow.grd_hidden"] = 1
    data["indicators.seatbelt_glow.grd_hidden"] = 1
  else
    data["indicators.brake_glow.grd_hidden"] = 0
    data["indicators.engine_glow.grd_hidden"] = 0
    data["indicators.ABS_glow.grd_hidden"] = 0
    data["indicators.seatbelt_glow.grd_hidden"] = 0
  end 
  data["trip_odo.trip.text"] = string.format("%09d",ev.trip)
  data["trip_odo.odometer.text"] = string.format("%09d",ev.odometer)
    
  gre.set_data(data)
end 

