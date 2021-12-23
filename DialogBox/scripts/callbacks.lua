--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local timer = 10
local timerID = nil

local function SetTimerUI() 
	local data = {}
	data["timed_layer.popup_auto.timeleft"] = string.format("%d",timer)
	gre.set_data(data)
end

function CBReset()
	timer = 10
	SetTimerUI()
end

function CBSetDialogTimer()
	timerID = gre.timer_set_interval(CBTick,1000)
	
end

function CBTick(mapargs)
	if (timer>0) then
		timer = timer - 1
		SetTimerUI()
	else
		CBAutoClose()
	end
end

--Reset the timer we started in cb_set_dialotimer 
--Send the event to play the hide animation
function CBAutoClose(mapargs)
	 gre.timer_clear_timeout(timerID)
	 gre.send_event("close_popup")

end

--simple show/hide toggle with no animation.
function CBInfoToggle(mapargs) 
	local check=gre.get_layer_attrs("info_layer", "hidden")
	local data={}
	if (check["hidden"]==1) then
		data["hidden"] = 0
	else
		data["hidden"] = 1
	end
	gre.set_layer_attrs("info_layer",data)
end

