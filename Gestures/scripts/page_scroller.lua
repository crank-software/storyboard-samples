--[[
  Copyright 2019, Crank Software Inc.
  All Rights Reserved.
  For more information email info@cranksoftware.com
  ** FOR DEMO PURPOSES ONLY **
]]--

--[[
  This module will move controls on a layer in the x direction.  It allows the carousel to be
  animated to focus on a new item, depending on the input scroll direction. Once the animation is complete 
  it will trigger a callback to notify the application that a new item has been selected
]]--

page_scroller = {}

---
--  Create a new page scroller instance with the initial values
function page_scroller:new(layer, size, position, duration, cb, delta)
  -- the layer used as a container for controls
  self.layer = layer
  -- x position of selected item
  self.selected_x = position
  -- the total screen/layer width
  self.width = size
  -- a callback to invoke when the scroll is complete
  self.cb = cb
  -- internal list of controls being scrolled
  self.controls = {}
  -- animation for the release
  self.anim = nil
  -- to prevent running multiple anims at same time
  self.anim_active = false
  -- current selected item index
  self.selected_item = 1
  -- complete animation duration
  self.duration = duration
  -- width of individual carousel item
  self.scroll_delta = delta
  
  -- left x threshold to wrap back to the right
  self.left_threshold = self.selected_x 
  -- right x threshold to wrap back to the left
  self.right_threshold = self.selected_x
end

---
--  add a control to the Scroller instance
function page_scroller:add_control(control)
  table.insert(self.controls, control)
end

---
--  Dump the list of controls for debugging
--  @param none
--  @return none
function page_scroller:dump()
  print("== Controls ==")
  for k,v in ipairs(self.controls) do
     print(k,v)
  end
end

---
--  Animation complete callback for scrolling
--  @param number id - id of completed animation
function page_scroller:animate_complete(id)
  self.anim = nil
  self.anim_active = false
  -- trigger the user callback
  if (self.cb) then
    self.cb(self.controls[self.selected_item])
  end
end

---
--  Animate carousel items to new positions based on input direction
--  @param #string direction - direction of swipe ("right" or "left")
--  @return none
function page_scroller:cycle_next_page(direction)
  if(self.anim_active == true) then
    return
  end
  
  local data = {}
  -- index of newly-selected menu item
  local new_index = self.selected_item
    
  if (direction == "left") then
    -- increase selected item index
    new_index = self.selected_item + 1
    if (new_index > #self.controls) then
      new_index = 1
    end
  elseif(direction == "right") then
    -- decrease selected item index
    new_index = self.selected_item - 1
    if (new_index <= 0) then
      new_index = #self.controls
    end
  end
  
  -- wrap first/last menu items to other side, depending on swipe direction
  self:shift_menu_items(direction)
  -- update selected item index
  self.selected_item = new_index
  -- set new positions for wrapped items
  gre.set_data(data)
  -- animate menu to show new selected item, based on direction
  self:animate_scroller(direction)
end

---
--  Shift left/right-most menu items to the opposite side to wrap
--  @param #string direction - direction of swipe ("right" or "left")
--  @return none
function page_scroller:shift_menu_items(direction)
  -- current position of menu item being adjusted
  local cur_pos = self.selected_x
  -- new position of menu item being adjusted
  local new_pos = self.selected_x
  -- path of menu item to shift
  local path = ""
  -- left x position at which to wrap back to the right
  local left_threshold = self.selected_x - (self.scroll_delta*(#self.controls/2))
  -- right x position at which to wrap back to the left
  local right_threshold = self.selected_x + (self.scroll_delta*(#self.controls/2))
  
  if(direction == "left") then
    -- move the leftmost item to the far right
    for i=1, #self.controls do
      path = self.layer.."."..self.controls[i]..".grd_x"
      cur_pos = gre.get_value(path)
      if(cur_pos <= left_threshold) then
        new_pos = right_threshold
        gre.set_value(path, new_pos)
      end
    end
  elseif(direction == "right") then
    -- move the rightmost item to the far left
    for i=1, #self.controls do
      path = self.layer.."."..self.controls[i]..".grd_x"
      cur_pos = gre.get_value(path)
      if(cur_pos >= right_threshold) then
        local new_pos = left_threshold
        gre.set_value(path, new_pos)
      end
    end
  end
end

---
-- animate menu to show new selected item
-- @param string direction - direction of swipe
-- @return none
function page_scroller:animate_scroller(direction)
  local anim_data = {}
  
  -- create the animation with the complete callback
  local animation_cb = function(id)
    self:animate_complete(id)
  end
  
  -- setup animation constant values
  self.anim = gre.animation_create(30, 1,animation_cb)
  anim_data["rate"] = "easeout"
  anim_data["duration"] = self.duration
  anim_data["offset"] = 0

  -- show animation step
  anim_data["to"] = self.selected_x
  anim_data["key"] = self.layer.."."..self.controls[self.selected_item]..".grd_x"
  gre.animation_add_step(self.anim, anim_data)
    
  -- move all other controls off-screen
  local cur_pos = self.selected_x
  for i=1,#self.controls do
    if (i ~= self.selected_item) then
      anim_data["key"] = self.layer.."."..self.controls[i]..".grd_x"
      cur_pos = gre.get_value(anim_data["key"])
      if(direction == "left") then
        anim_data["to"] = cur_pos - self.scroll_delta
      elseif(direction == "right") then
        anim_data["to"] = cur_pos + self.scroll_delta
      end
      gre.animation_add_step(self.anim, anim_data)
    end
  end
    
  -- trigger complete animation
  gre.animation_trigger(self.anim)
  self.anim_active = true
end

return page_scroller
