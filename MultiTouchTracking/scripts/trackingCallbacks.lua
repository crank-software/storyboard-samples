--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

-- Track the multi-touch id to control id
local MAX_POINTS = 5
local points = {}

local function getControlName(id)
  return "TPLayer.tp" .. tostring(id)
end

local function getPointId(inputId, create)
  local insertIndex = 0
  
  -- Look for a matching touch number and convert it to an id
  for i= 1, MAX_POINTS do
    if points[i] == inputId then
      return i
    elseif insertIndex == 0 and points[i] == -1 then
      insertIndex = i
    end
  end
  
  -- If we found an insertion index, we wanted to add so put it in
  if(create == true and insertIndex ~= 0) then
    points[insertIndex] = inputId    
    gre.set_control_attrs(getControlName(insertIndex), { hidden = 0 })
    
    return insertIndex
  end
   
  return 0
end

-- Clear a single point from the display and mapping table
local function clearPointId(id)
  points[id] = -1
  gre.set_control_attrs(getControlName(id), { hidden = 1 })
end

-- Clear all points from the display and mapping table
local function clearAllPoints()
  for i= 1, MAX_POINTS do
    clearPointId(i)
  end
end

-- Center a point on based on an x,y press event location
local function centerPoint(eventData, create)
  local id = getPointId(tonumber(eventData.id), create)
  if id == 0 then
    return id
  end
 
  local name = getControlName(id)
  local x = tonumber(eventData.x)
  local y = tonumber(eventData.y)
  
  local cinfo = gre.get_control_attrs(name, "x", "y", "width", "height")
  
  local ninfo = {}
  ninfo.x = x - (cinfo.width / 2)
  ninfo.y = y - (cinfo.height / 2)
  
  -- We can be flooded with input events on high resolution system so debounce it a bit
  if(ninfo.x ~= cinfo.x or ninfo.y ~= cinfo.y) then
    gre.set_control_attrs(name, ninfo)
  end
  
  return id
end

---
-- Callback functions that drive the UI
--- 

-- Initialize the number of points we are supporting
function setup()
  clearAllPoints()
end

-- Respond to a press/mt press event by adding a point
function addPoint(mapargs)
	local id = centerPoint(mapargs.context_event_data, true)
	if(id == 0) then
	   return
	end

  -- Add the ID to the label
	local data = {}
	data[string.format("%s.text", getControlName(id))] = tostring(id)
	gre.set_data(data)
end

-- Respond to a motion/mt motion event by moving a point
function movePoint(mapargs)
  centerPoint(mapargs.context_event_data, false)
end

-- Respond to a release/mt release event by removing a point
function remPoint(mapargs)
  local inputId = tonumber(mapargs.context_event_data.id)
  local id = getPointId(inputId, false)
  if(id == 0) then
     return
  end 

	clearPointId(id)
end

