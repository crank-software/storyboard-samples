--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gState = "PAUSE"
local gProgress = 0
local gTimerID = nil

function CBPlayPause(mapargs)
	local data = {}
	
	if (gState == "PAUSE") then 
		gState = "PLAY"
		gTimerID = gre.timer_set_interval(CBProgressTimer, 50)
		data["ProgressBarLayer.PlayPause.image"] = "images/play_pause_up.png"
	else
		gState = "PAUSE"
    if (gTimerID ~= nil) then
		  gre.timer_clear_timeout(gTimerID)
		  gTimerID = nil
		end
		data["ProgressBarLayer.PlayPause.image"] = "images/play_pause_down.png"
	end
	gre.set_data(data)
end

function CBProgressTimer(mapargs)
	local data = {}
	local progress_max_width = 225
	
	gProgress = gProgress + 0.1
	data["ProgressBarLayer.ProgressBarFill.progress_width"] = math.ceil((gProgress / 100) * progress_max_width)

	-- if we are greater that 100% reset and pause
	if (gProgress > 100)	then
		gState = "PAUSE"
    if (gTimerID ~= nil) then
		  gre.timer_clear_timeout(gTimerID)
		  gTimerID = nil
		end
		data["ProgressBarLayer.PlayPause.image"] = "images/play_pause_down.png"	
		data["ProgressBarLayer.ProgressBarFill.progress_width"] = 0
		gProgress = 0
	end
	gre.set_data(data)
end

function CBProgressPowerOff(mapargs)
	local data = {}
	
	gState = "PAUSE"
	if (gTimerID ~= nil) then
		gre.timer_clear_timeout(gTimerID)
    gTimerID = nil
	end
	data["ProgressBarLayer.PlayPause.image"] = "images/play_pause_down.png"
	data["ProgressBarLayer.ProgressBarFill.progress_width"] = 0
	gProgress = 0
	gre.set_data(data)
end
