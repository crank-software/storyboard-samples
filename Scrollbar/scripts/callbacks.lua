--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local table = {}
local is_table_dragging_enabled = true

function CBInitTable(mapargs)
    local data = gre.get_table_attrs("scrollingTable_layer.scrollingTable","height","rows")
    for i=1, data.rows do
        gre.set_value("scrollingTable_layer.scrollingTable.rowText."..i..".1", tostring(i))
    end
    table.height = data.height
    table.rows = data.rows
end

local function GetTotalTableHeight()
    local cell = gre.get_table_cell_attrs("scrollingTable_layer.scrollingTable", 1, 1, "height")
    local height = table.rows * cell.height - table.height
    return height
end

--This moves the scrollbar when interacting/scrolling the table.
--This is called when the grd_yoffset of the table is changed.
function CBUpdateScrollbar()
    local yoffset = gre.get_value("scrollingTable_layer.scrollingTable.grd_yoffset")
    local height = gre.get_value("scrollingTable_layer.scrollbar.height")
    local tableHeight = GetTotalTableHeight()
    local percentage = math.abs(yoffset) / tableHeight

    if yoffset < 0 and yoffset > -1 * tableHeight then
        if percentage < .5 then
            gre.set_value("scrollingTable_layer.scrollbar.y", math.floor((table.height-height)*percentage))
        else
            gre.set_value("scrollingTable_layer.scrollbar.y", math.ceil((table.height-height)*percentage))
        end
    end
end

--This moves/scrolls the table when dragging the scrollbar.
local function UpdateTable()
    local y = gre.get_value("scrollingTable_layer.scrollbar.y")
    local height = gre.get_value("scrollingTable_layer.scrollbar.height")
    local tableHeight = GetTotalTableHeight()
    local percentage = y / (table.height-height)
    if y > 0 and y < table.height-height then
        if percentage < .5 then
            gre.set_value("scrollingTable_layer.scrollingTable.grd_yoffset", math.floor(tableHeight * percentage * -1))
        else
            gre.set_value("scrollingTable_layer.scrollingTable.grd_yoffset", math.ceil(tableHeight * percentage * -1))
        end
    end
end

--This moves the scrollbar when interacting with the scrollbar itself
function CBDragScrollbar(mapargs)
    local pressed = gre.get_value("scrollingTable_layer.scrollbarPressed")
    if pressed == 1 then
        local y = mapargs.context_event_data.y - gre.get_value("scrollingTable_layer.scrollbar.grd_y") - gre.get_value("scrollingTable_layer.scrollbar.height")
        if y >= 0 then
            local maxY = gre.get_value("scrollingTable_layer.scrollbar.grd_height") - gre.get_value("scrollingTable_layer.scrollbar.height")
            if (y > maxY) then
              y = maxY
            end
            gre.set_value("scrollingTable_layer.scrollbar.y", y)
        end
    end
    UpdateTable()
end

function CBAutoScrollStart(mapargs)
  table.scrollTimer = gre.timer_set_interval(CBUpdateScrollbar, 16)
end

function CBAutoScrollFinish(mapargs)
  if (table.scrollTimer ~= nil) then
    gre.timer_clear_interval(table.scrollTimer)
    table.scrollTimer = nil
  end
  CBUpdateScrollbar()
end

function CBEventHandler(mapargs)
  if (gre.get_value("scrollingTable_layer.scrollbarPressed") == 1) then
    CBDragScrollbar(mapargs)
  end
end

function CBRelease(mapargs)
  gre.set_value("scrollingTable_layer.scrollbarPressed", 0)
end

-- this toggles whether the user can scroll the table by dragging their finger over it.
function CBToggleDraggingTable(mapargs)
  if (is_table_dragging_enabled == true) then
    is_table_dragging_enabled = false
  else
    is_table_dragging_enabled = true
  end
  
  local data = {}
  data["scrollingTable_layer.scrollingTable.grd_scroll_enabled"] = is_table_dragging_enabled
  data["checkbox_layer.checkmark_control.grd_hidden"] = is_table_dragging_enabled
  gre.set_data(data)
end
