--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--


local gPower = 0

function CBTogglePower(mapargs) 
	local data = {}
	
	if (gPower == 0) then
		gPower = 1
		data["VULayer.Power.image"] = "images/power_on.png"
		gre.send_event("POWER_ON")
		gre.send_event("START_PLAYING")		
	else
		gPower = 0
		data["VULayer.Power.image"] = "images/power_off.png"
		gre.send_event("POWER_OFF")
	end
	gre.set_data(data)
end
