--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gStartX = 0
local gStartY = 150
local gAmplitude = 60
local gFrequency = 30
local gIncY = 0
local gMaxIdx = 560 --[280
local gCurWIndex = 1
local gWrapped = 0 
local gCurrentRad = 0
local gYValues = {}


function CBChangeFrequency(mapargs)
	gFrequency = gFrequency + mapargs.frequency
	gAmplitude = gAmplitude + mapargs.amplitude
	if (gFrequency  < 1) then
		gFrequency = 1
	end
	if (gAmplitude  < 0) then
		gAmplitude = 0
	end		
end

function DrawTrend(mapargs)
	local points
	local v = {}
	local iter
	local points = ""
	local radinc
	local theta
	
	-- Use a circular buffer to keep points in a sin wave, adjusting position in screen
	-- and then change points into a polygon string  
	if (gCurWIndex > gMaxIdx) then
		gCurWIndex = 1
		gWrapped = 1
	end		
	
	--frequency calcuated as increments need to reach 2 pi.
	radinc = 6.283185/gFrequency
	
	if (gCurrentRad > 6.283185) then
		gCurrentRad = gCurrentRad - 6.283185
	end
	
	-- get sin value at current pos, magnify to match amplitude
	tmp = math.sin(gCurrentRad)	
	tmp = tmp * gAmplitude			
	gYValues[gCurWIndex] = math.floor(tmp) + gIncY + gStartY
	iter = gCurWIndex
	points = {}
	
	while (iter > 0) do
		newstr = string.format("%d:%d", gMaxIdx - (gCurWIndex-iter) - 1, gYValues[iter])
		table.insert(points, newstr)
		iter = iter -1
	end
	
	-- Gone around once so now fill in the old point data
	if (gWrapped == 1) then
		iter = gMaxIdx
		
		while (iter > gCurWIndex) do		
			newstr = string.format("%d:%d", iter - gCurWIndex - 1, gYValues[iter])
			table.insert(points, newstr)
			iter = iter -1
		end
	else
		-- extend to start of trend window for a flat line 
		if (gCurWIndex < gMaxIdx) then 
			newstr = string.format(" %d:%d", gStartX, gStartY)		
			table.insert(points, newstr)
		end
	end

	gCurWIndex = gCurWIndex + 1
	gCurrentRad = gCurrentRad + radinc
	v["trendpoly_1"] = table.concat(points, " ")
	
	gre.set_data(v)
end
