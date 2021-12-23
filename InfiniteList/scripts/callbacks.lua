--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local InfiniteList = require("sbt_infinite_list")

---@field #list<#string>
local wordList

---@field sbt_infinite_list#InfiniteList
myList = nil

---@field #map<#number,#boolean>
local TouchedList = {}

local function CBRenderText(list, dataIndex, cellIndex)
  local colData = {}
  local col1 = {}
  col1["text"] = wordList[dataIndex]
  
  local clr = TouchedList[dataIndex]
  if(clr == true) then
    col1["clr"] = 0xb94542
  else
    col1["clr"] = 0xf9dbd8
  end
  colData[1] = col1 
  
  return colData
end

local function CBScrollUpdate()
  local percent = myList:GetScrollPercent()
  
  local data = gre.get_data("Layer.InfiniteList.grd_y",
                            "Layer.InfiniteList.grd_height",
                            "Layer.Scroll.grd_height")
                            
  local y = data["Layer.InfiniteList.grd_y"]
  local height = data["Layer.InfiniteList.grd_height"]
  local scrollHeight = data["Layer.Scroll.grd_height"]
  
  local scrollY = y + (height - scrollHeight) * percent
  gre.set_value("Layer.Scroll.grd_y", scrollY)  
end


function CBInit(mapargs)
  local file = assert(loadfile(gre.SCRIPT_ROOT .. "/words/wordList.txt"))
  if(file) then
    wordList = file()
    
    myList = InfiniteList.new("Layer.InfiniteList", CBRenderText, CBScrollUpdate, #wordList, 60)
  end
end

function CBCellTouch(mapargs) 
  local row = mapargs.context_row
  local dataIndex = myList:GetDataIndexFromCell(row)
  print(string.format("Touched Table Row %d Data Index %d", row, dataIndex))
 
  -- Toggle a flag in the touched field
  if(TouchedList[dataIndex] == true) then
    TouchedList[dataIndex] = nil
  else
    TouchedList[dataIndex] = true
  end
  myList:RefreshCell(row)
end

local scrollbarPressed = false
local scrollbarY = 0
local scrollbarYOffset = 0
--- @param gre#context mapargs
function CBScrollbar(mapargs)
  local ev = mapargs.context_event 
  if(ev == "gre.press") then
    scrollbarPressed = true
    
    local data = gre.get_data("Layer.Scroll.grd_y")
    scrollbarY = data["Layer.Scroll.grd_y"]
    scrollbarYOffset = scrollbarY - mapargs.context_event_data.y
  elseif(scrollbarPressed == true) then
    if(ev == "gre.motion") then
      local scrollY = mapargs.context_event_data.y + scrollbarYOffset                  
      local data = gre.get_data("Layer.InfiniteList.grd_y",
                            "Layer.InfiniteList.grd_height",
                            "Layer.Scroll.grd_height")
          
      local y = data["Layer.InfiniteList.grd_y"]
      local height = data["Layer.InfiniteList.grd_height"]
      local scrollHeight = data["Layer.Scroll.grd_height"]
      
      scrollY = math.max(scrollY, y)
      scrollY = math.min(scrollY, y + height - scrollHeight)
      
      local percent = (scrollY - y) / (height - scrollHeight)

      data = {}
      data["Layer.Scroll.grd_y"] = scrollY
      gre.set_data(data)
      
      myList:SetScrollPercent(percent)
    elseif(ev == "gre.release" or ev == "gre.outbound") then
      scrollbarPressed = false
    end
  end
end
