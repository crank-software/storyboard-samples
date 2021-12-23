--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gLastPressedControl = nil
local gFront = 100

-- this function is called on motion events
function CBDrag(mapargs)
	local ev_data = mapargs.context_event_data;
	
	-- if no control is selected just return
	if (gLastPressedControl == nil) then
		return
	end
	
	--set postion to touch co-ord, center the control on the screen location
	local size = gre.get_control_attrs(gLastPressedControl, "width", "height")
	
	local pos = {}
	pos["x"] = ev_data.x - (size.width / 2)
	pos["y"] = ev_data.y -  (size.height / 2)
	
	-- set the control to the new position
	gre.set_control_attrs(gLastPressedControl, pos)
end

-- When a control is pressed, save the name of the control
function CBPress(mapargs)
	gLastPressedControl = mapargs.context_control
	gFront = gFront + 1
	
	local data = {}
	data[mapargs.context_control..".grd_zindex"] = gFront
	gre.set_data(data)
end

-- When a release happens, clear the saved control name
function CBRelease(mapargs)
	gLastPressedControl = nil
end
