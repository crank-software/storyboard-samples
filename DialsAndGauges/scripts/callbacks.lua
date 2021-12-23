--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local counter= 1
local dataset={}

--[[
sets up a dataset of values to go through using a random number.
We set up the speed of our changes between their previous values. 
This ensures that the needles never go too fast or too slow.
If it's already running shut it down.
]]--

function CBStart(mapargs) 
	if(#dataset>1)then
		counter=1
		dataset={}
		gre.send_event("shut_down")
	else
		dataset={}
		local prev_perc=0
		for i=1,21 do
		local step={}
		local perc=math.random(100)/100
		step.speed=math.abs(perc-prev_perc)*3000
		step.pressure=perc*270-45
		step.voltage=perc*360
		step.temp_h=math.floor(perc*190)
		step.temp_y = 288-step.temp_h
		
		prev_perc=perc
		table.insert(dataset,step)
		end
		CBPlayNext()
	end	
end

--set the values to the ones stored in our dataset and send an event to play them.
--If we're out of values, shut it down.
function CBPlayNext(mapargs)
	if(counter>21)then
		counter=1
		dataset={}
		gre.send_event("shut_down")
	elseif(#dataset>1)then
		local data={}

		data["pressure_target"]=dataset[counter].pressure
		data["temp_y"]=dataset[counter].temp_y
		data["temp_target"]=dataset[counter].temp_h
		data["relative_speed"]=dataset[counter].speed
		data["voltage_target"]=dataset[counter].voltage
		
		gre.set_data(data)
		gre.send_event("play_step")
		counter=counter+1
	end

end
