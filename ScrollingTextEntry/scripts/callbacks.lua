--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gDelKey = 8
local gEnterKey = 13
local gCtrlKey = 2
local gNote = "Textfield_layer.notetext"
local gKeyPressTimeoutId
local gSI

require("text_scroll")

function CBInit(mapargs)
  local data = gre.get_data(gNote..".font", gNote..".font_size")
  gSI = ScrollInfo.create(gNote, data[gNote..".font"], data[gNote..".font_size"], true, nil, nil, nil, nil, 3)
  gSI:init(true)
end

function CBKeyPress(mapargs)
  local keyPressed = mapargs.context_event_data.code
  local modifier = mapargs.context_event_data.modifiers
  local data = {}
  local text = gre.get_data(gNote..".text")[gNote..".text"]
  
  if (modifier ~= gCtrlKey) then
  if (keyPressed == gDelKey) then
    data[gNote..".text"] = string.sub(text,1,-2)
  elseif (keyPressed == gEnterKey) then
    data[gNote..".text"] = string.format("%s\n",text)
  else
    if pcall(function() string.char(keyPressed) end) then
      data[gNote..".text"] = string.format("%s%s",text,string.char(keyPressed))
    else
      -- This is where we could implement some extra logic for special keys
    end
  end
  end
  gre.set_data(data)

  if(gKeyPressTimeoutId ~= nil)then
    gre.timer_clear_timeout(id)
    gKeyPressTimeoutId = nil
  end

  local cb = function()
    if(gSI == nil) then
      print("No Scroll Info for " .. tostring(gNote))
      return
    end
    gSI:init(false)
    gSI:scrollArea(1)
    CBUpdateScrollBar()
  end
  gKeyPressTimeoutId = gre.timer_set_timeout(cb,50)
end

function CBScrollText(mapargs)
  if(gSI == nil) then
    return
  end
  gSI:scroll(mapargs.direction)
  CBUpdateScrollBar()
end

function CBUpdateScrollBar(mapargs)
  if(gSI == nil) then
    print("No Scroll Info for " .. tostring(gNote))
    return
  end

  local data= {}
  local scrollBarMarkerY
  local scrollBarMarkerPercent = 0
  local maxOffset = gSI:getValue("max_y")
  local offsetSize = gSI:getValue("line_height")
  local currentOffset = math.abs(gre.get_data(gNote..".texty")[gNote..".texty"])
  local noteArea = gre.get_control_attrs(gNote,"height")
  local offsetDelta = maxOffset - noteArea.height
  local scrollTicks = math.max(1, math.floor(offsetDelta / offsetSize))
  local scrollBarControlHeight = gre.get_control_attrs("Textfield_layer.ScrollBar.background","height")["height"]
  local scrollBarButtonControlHeight = gre.get_control_attrs("Textfield_layer.ScrollBar.upButton","height")["height"]
  local scrollBarMarkerControlHeight =  gre.get_control_attrs("Textfield_layer.ScrollBar.marker","height")["height"]

  for i = scrollTicks,0,-1 do
    if(currentOffset >= i*offsetSize) then
      scrollBarMarkerPercent = (i * offsetSize)/(scrollTicks * offsetSize)
      break
    end
  end

  scrollBarMarkerY = ((scrollBarControlHeight - (scrollBarMarkerControlHeight + scrollBarButtonControlHeight * 2)) * scrollBarMarkerPercent) + scrollBarButtonControlHeight
  data["y"] = scrollBarMarkerY
  gre.set_control_attrs("Textfield_layer.ScrollBar.marker",data)
end

local gPressed = false
local gScrollBarY = "Textfield_layer.ScrollBar.grd_y"
local gScrollBarHeight = "Textfield_layer.ScrollBar.background.grd_height"
local gScrollButtonHeight  = "Textfield_layer.ScrollBar.downButton.grd_height"
local gScrollHandleHeight = "Textfield_layer.ScrollBar.marker.grd_height"
local gScrollHandleY = "Textfield_layer.ScrollBar.marker.grd_y"
local gScrollableAreaHeight = "Textfield_layer.ScrollBar.scrollableArea.grd_height"
local gScrollPress = 0
local gScroll
local scrollableAreaBounds = 212
local minPercentThreshold = 0.05
local maxPercentThreshold = 0.95


function UpdateScroll(mapargs)
  local y
  local handleY
  local scrollPercent
  gScroll = gre.get_data(gScrollBarY, gScrollBarHeight, gScrollButtonHeight, gScrollHandleHeight, gScrollHandleY, gScrollableAreaHeight)
  
  if(gSI:getValue("target_height") > gSI:getValue("max_y")) then
    return
  end
  
  y = mapargs.context_event_data.y - gScroll[gScrollBarY] - gScroll[gScrollButtonHeight]

  if (y < (gScroll[gScrollButtonHeight]) / 2) then
    handleY = gScroll[gScrollButtonHeight]
  elseif (y > scrollableAreaBounds - (gScroll[gScrollHandleHeight] / 2)) then
    handleY = scrollableAreaBounds
  else
    handleY = mapargs.context_event_data.y - gScroll[gScrollBarY] - gScroll[gScrollButtonHeight] + (gScroll[gScrollHandleHeight] /2)
  end
  
  scrollPercent = y / gScroll[gScrollableAreaHeight]
  
  if (scrollPercent < minPercentThreshold) then
    scrollPercent = 0
  elseif (scrollPercent > maxPercentThreshold) then
    scrollPercent = 1
  end
  
  gre.set_value(gScrollHandleY, handleY)
  gSI:scrollArea(scrollPercent)
end

function CBScrollPress(mapargs)
  gPressed = true
  
  UpdateScroll(mapargs)
end

function CBScrollOutboundRelease(mapargs)
  gPressed = false
end

function CBScrollMotion(mapargs)
  if (gPressed) then
    UpdateScroll(mapargs)
  end
end