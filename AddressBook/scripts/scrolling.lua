--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

-- Constants
local gContactTable = "TableLayer.ContactListTable"

-- Variables
local gCellHeight
local gTableHeight
local gTableMaxHeight
local gVisibleCells
local gScrollTimer = 0


function CBInitScroll()
    local cell_data = gre.get_table_cell_attrs(gContactTable, 1, 1, "height")
    local table_data = gre.get_table_attrs(gContactTable, "rows", "height")     
                         
    gCellHeight = cell_data.height
    gTableHeight = table_data.height
    gTableMaxHeight = gCellHeight * table_data.rows
    gVisibleCells = math.ceil(gTableHeight / gCellHeight)
end

function ScrollUp(inc)
    local table_data = gre.get_table_attrs(gContactTable,"yoffset", "rows")
    local attrs = {}
    
    if (table_data.rows < gVisibleCells) then
      attrs.yoffset = 0
    else
      if (table_data.yoffset + inc <= 0) then
          attrs.yoffset = table_data.yoffset + inc
      else
          attrs.yoffset = 0
          if (gScrollTimer and gScrollTimer ~= 0) then
              gre.timer_clear_interval(gScrollTimer)
              gScrollTimer = 0
          end  
      end
    end
    gre.set_table_attrs(gContactTable, attrs)
end

function CBScrollUpPress(mapargs) 
    local scroll = gre.get_value("scroll")
    
    if (scroll == 1) then
        gScrollTimer = gre.timer_set_interval(function() ScrollUp(1) end, 5)
    end
end

function ScrollDown(inc)
    local table_data = gre.get_table_attrs(gContactTable,"yoffset", "rows")
    local attrs = {}
    
    if (table_data.rows < gVisibleCells) then
      attrs.yoffset = 0
    else
      if (math.abs(table_data.yoffset) - inc <= gTableMaxHeight - gTableHeight - 5) then
          attrs.yoffset = table_data.yoffset - inc
      else
          attrs.yoffset = (gTableMaxHeight - gTableHeight - 4)*-1
          if (gScrollTimer and gScrollTimer ~= 0) then
              gre.timer_clear_interval(gScrollTimer)
              gScrollTimer = 0
          end  
      end
    end
    gre.set_table_attrs(gContactTable, attrs)
end

function CBScrollDownPress(mapargs) 
    local scroll = gre.get_value("scroll")
    
    if (scroll == 1) then
        gScrollTimer = gre.timer_set_interval(function() ScrollDown(1) end, 5)
    end
end

function CBScrollRelease(mapargs) 
    local scroll = gre.get_value("scroll")
    
    if (scroll == 1) then
        if (gScrollTimer and gScrollTimer ~= 0) then
            gre.timer_clear_interval(gScrollTimer)
            gScrollTimer = 0
        end
    end
end
