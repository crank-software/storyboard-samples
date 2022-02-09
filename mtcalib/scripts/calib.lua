--[[
Copyright 2014, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com

More information related to the demo can be found at http://www.cranksoftware.com/forums/viewtopic.php?f=5&t=152

Calibrate an mtdev based touchscreen
]]--

-- location goes clockwise from top left corner and then center
local location = 0
local target = {height=50,width=50}
local display_size = {}
-- calibration values
local cal_x = {}
local cal_y = {}
local cal_a = {}
-- target positions
local pos_x = {}
local pos_y = {}
-- Minimum values for x,y
local left_touch_val_x = nil
local top_touch_val_y = nil
-- Maximum values for x,y
local right_touch_val_x = nil
local low_touch_val_y = nil

local function round(what)
	local precision = 8
   return math.floor(what*math.pow(10,precision)+0.5) / math.pow(10,precision)
end

local function output_vals()
	local idata = {}
	idata["Instruction.information.text"] = string.format("-omtdev,bounds=%d:%d:%d:%d",left_touch_val_x, top_touch_val_y, right_touch_val_x, low_touch_val_y)		
	gre.set_data(idata)
	
	print(string.format("\n-omtdev,bounds=%d:%d:%d:%d",left_touch_val_x, top_touch_val_y, right_touch_val_x, low_touch_val_y))
end

local function perform_calculation(i)
	local x = 0
	local y = 0

	if(i == 5)then
		--Calculate the leftmost x value the touch screen will return.
    local average_left_pos_x=(pos_x[1] + pos_x[4])/2
    local average_left_touch_x= (cal_x[1] + cal_x[4])/2
--    left_touch_val_x = (display_size["width"] * average_left_touch_x / average_left_pos_x)
--		print("left_touch_val_x", left_touch_val_x, display_size["width"], average_left_touch_x, average_left_pos_x)
	
    --Calculate the highest y value the touch screen will return.
    local average_top_pos_y=(pos_y[1] + pos_y[2])/2
    local average_top_touch_y= (cal_y[1] + cal_y[2])/2
--    top_touch_val_y = (display_size["height"] * average_top_touch_y / average_top_pos_y)
    
    --Calculate the rightmost x value
		local average_right_pos_x=(pos_x[2] + pos_x[3])/2
		local average_right_touch_x= (cal_x[2] + cal_x[3])/2
--		right_touch_val_x = (display_size["width"] * average_right_touch_x / average_right_pos_x)
		
		--Calculate the lowest y value the touch screen will return.
		local average_lower_pos_y=(pos_y[3] + pos_y[4])/2
		local average_lower_touch_y= (cal_y[3] + cal_y[4])/2
--		low_touch_val_y = (display_size["height"] * average_lower_touch_y / average_lower_pos_y)
		
		print("average_right_touch_x, average_left_touch_x", average_right_touch_x, average_left_touch_x)
		
		
		local pixel_diff_x = display_size["width"] - (average_left_pos_x + (display_size["width"] - average_right_pos_x))
		local touch_diff_x = math.abs(average_left_touch_x - average_right_touch_x)
		local touch_size_x = display_size["width"] * (touch_diff_x/pixel_diff_x)
		local leftover_touch_x = (touch_size_x - touch_diff_x)/2
		print("pixel_diff_x", pixel_diff_x)
		print("touch_diff_x", touch_diff_x)
		print("touch_size_x", touch_size_x)
    print("leftover_touch_x", leftover_touch_x)
		if(average_right_touch_x - average_left_touch_x < 0) then
		  left_touch_val_x = average_left_touch_x + leftover_touch_x
		  right_touch_val_x = average_right_touch_x - leftover_touch_x
		else
		  left_touch_val_x = average_left_touch_x - leftover_touch_x
      right_touch_val_x = average_right_touch_x + leftover_touch_x 
		end
    print("left_touch_val_x, right_touch_val_x", left_touch_val_x, right_touch_val_x)		

    local pixel_diff_y = display_size["height"] - (average_top_pos_y + (display_size["height"] - average_lower_pos_y))
		local touch_diff_y = math.abs(average_top_touch_y - average_lower_touch_y)
		local touch_size_y = display_size["height"] * (touch_diff_y/pixel_diff_y)
		local leftover_touch_y = (touch_size_y - touch_diff_y)/2
		
		if(average_lower_touch_y - average_top_touch_y < 0) then
		  top_touch_val_y = average_top_touch_y + leftover_touch_y
      low_touch_val_y = average_lower_touch_y - leftover_touch_y
		else
		  top_touch_val_y = average_top_touch_y - leftover_touch_y
      low_touch_val_y = average_lower_touch_y + leftover_touch_y
		end
    print("top_touch_val_y", "low_touch_val_y", top_touch_val_y,low_touch_val_y)		
		
--		for j=1,5,1 do
--			x = cal_x[j]*display_size["width"]/right_touch_val_x
--			y = cal_y[j]*display_size["height"]/low_touch_val_y	
--		end
		
		output_vals()		
	end
	if(i>5)then
		local data = {}
		
		
		---TODO Need to do something with left_touch_val_x
		-- calculate the location of the touch
		x = (cal_x[i]*display_size["width"]/(right_touch_val_x-left_touch_val_x))
		y = (cal_y[i]*display_size["height"]/(low_touch_val_y-top_touch_val_y))
		
		-- move the control
		data["x"] = x-target["width"]/2
		data["y"] = y-target["height"]/2
		gre.set_control_attrs("calib.target", data)
		
		--[[
		-- if the target is off the screen, adjust right_touch_val_x or low_touch_val_y if necessary.
		if (x > display_size["width"]) then
			right_touch_val_x = cal_x[i]
			output_vals()
		end
		if (y > display_size["height"]) then
			low_touch_val_y = cal_y[i]
			output_vals()
		end
		--]]
	end
end


function get_sample(mapargs)
	local data = {}
	local x = 0
	local y = 0
	
	if (location > 0) then
		-- take a sample
		cal_x[location] = mapargs.context_event_data.x
		cal_y[location] = mapargs.context_event_data.y
	end
	
	print(location, mapargs.context_event_data.x, mapargs.context_event_data.y)
	
	perform_calculation(location)
	location = location + 1
	
	if(location < 6) then
		-- move the control
		data["x"] = pos_x[location]-target["width"]/2
		data["y"] = pos_y[location]-target["height"]/2
		gre.set_control_attrs("calib.target", data)
	elseif (location == 6) then
		gre.send_event("done_cal")
		
	end
end

local function fix_target()
  local data = {}
  
  data = gre.get_data("calib.target.line_width")
  
  if(data["calib.target.line_width"] == 0) then
    data["calib.target.line_width"] = 1
    gre.set_data(data)
  end
end

function setup_calibration()
	display_size["width"] = gre.env("screen_width")
	display_size["height"] = gre.env("screen_height")

  fix_target()

	-- calcluate the target positions based on screen size
	-- they move clockwise around the screen from top-left 
	-- and then the last is center
	pos_x[1] = 50
	pos_x[2] = display_size["width"] - 50
	pos_x[3] = pos_x[2]
	pos_x[4] = pos_x[1]
	pos_x[5] = display_size["width"]/2
	
	pos_y[1] = 50
	pos_y[2] = pos_y[1]
	pos_y[3] = display_size["height"] - 50
	pos_y[4] = pos_y[3]
	pos_y[5] = display_size["height"]/2
	
	location = 1
	target["width"] = 50
  target["height"] = 50
	target["x"] = pos_x[location]-target["width"]/2
	target["y"] = pos_y[location]-target["height"]/2
	gre.set_control_attrs("calib.target", target)
end

