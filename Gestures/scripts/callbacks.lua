--[[
Copyright 2016 Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local page_scroller = require('page_scroller')

--- 
-- ititialize app
-- @param gre#context mapargs
-- @return none
function cb_init(mapargs) 
  -- create a new scroller 
  -- page_scroller:new((layer, screen width, x-padding, animation duration in msec, select callback, amount to scroll (with padding))
   page_scroller:new("swipe_layer", 800, 245, 500, nil, 350)

   -- add controls to the scroller
   page_scroller:add_control("settings")
   page_scroller:add_control("climate")
   page_scroller:add_control("security")
   page_scroller:add_control("calendar")
end

--- 
-- register swipe gestures
-- @param gre#context mapargs
-- @return none
function cb_swipe_gestures(mapargs)
  local x = "window_layer.Crank_Logo_Swipe.grd_x"
  local y = "window_layer.Crank_Logo_Swipe.grd_y"
  local data = gre.get_data(x, y)
  data[x] = data[x] + mapargs.context_event_data.x_move
  data[y] = data[y] + mapargs.context_event_data.y_move
  --71,22,660,310
  
  local size = gre.get_control_attrs("window_layer.Crank_Logo_Swipe", "width", "height")
  local client_area = gre.get_control_attrs("window_layer.Crank_Logo_Scale", "x", "y", "width", "height")
  
  if(data[x] < client_area.x)then 
    -- left edge
    data[x] = client_area.x
  elseif(data[x] > ((client_area.x + client_area.width) - size.width))then
    --right edge  
    data[x] = (client_area.x + client_area.width) - size.width
  end
  
  if(data[y] < client_area.y) then
    data[y] = client_area.y
  elseif(data[y] > ((client_area.y + client_area.height) - size.height)) then
    data[y] = (client_area.y + client_area.height) - size.height
  end
  
  gre.set_data(data)
end

--- 
-- register rotate gesture
-- @param gre#context mapargs
-- @return none
function cb_rotate_gesture(mapargs) 
  local data = gre.get_data("window_layer.Crank_Logo_Rotate.angle")
  local shift = tonumber(mapargs.context_event_data.value)
  local angle = tonumber(data["window_layer.Crank_Logo_Rotate.angle"])
  local new_angle = angle + shift
  data["window_layer.Crank_Logo_Rotate.angle"] = new_angle
  gre.set_data(data)
end

--- 
-- register pinch gesture
-- @param gre#context mapargs
-- @return none
function cb_pinch_gesture(mapargs)
  local x_scale = "window_layer.Crank_Logo_Scale.wScale"
  local y_scale = "window_layer.Crank_Logo_Scale.hScale"
  local data = gre.get_data(x_scale, y_scale)
  local shift = tonumber(mapargs.context_event_data.value)
  
  data[x_scale] = data[x_scale] * shift
  data[y_scale] = data[y_scale] * shift
  if data[x_scale] > 358 * 1.75 then
    data[x_scale] = 358 * 1.75
  end
  if(data[x_scale] < 358 * 0.5) then
    data[x_scale] = 358 * 0.5
  end
  if data[y_scale] > 72 * 1.75 then
    data[y_scale] = 72 * 1.75
  end
  if data[y_scale] < 72 * 0.5 then
    data[y_scale] = 72 * 0.5
  end
  gre.set_data(data);
end


--- 
-- register single-finger swipe gestures
-- @param gre#context mapargs
-- @return none
function cb_swipe_carousel(mapargs) 
  local ev_data = mapargs.context_event_data
  local direction = mapargs.direction
  
  -- update carousel based on swipe direction
  page_scroller:cycle_next_page(direction)
end
