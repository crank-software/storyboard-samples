--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gNote = "Textfield_layer.notetext"
local gKeyPressTimeoutId
local gSI

require("text_scroll")

function CBInit(mapargs)
  local data = gre.get_data(gNote..".font", gNote..".font_size")
  gSI = ScrollInfo.create(gNote, data[gNote..".font"], data[gNote..".font_size"], true, nil, nil, nil, nil, 3)
  gSI:init(true)
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
local gScrollPress = 0
local gScroll

function CBScrollDrag(mapargs)
  local y
  local scrollPercent
  local yDelta
  gScroll = gre.get_data(gScrollBarY, gScrollBarHeight, gScrollButtonHeight, gScrollHandleHeight, gScrollHandleY)

  if(mapargs.context_event == "gre.press") then
    gPressed = true
    gScrollPress = mapargs.context_event_data.y
  elseif(mapargs.context_event == "gre.motion") then
    if(gPressed) then
      if(gSI:getValue("target_height") > gSI:getValue("max_y")) then
        return
      end
      yDelta = mapargs.context_event_data.y - gScrollPress
      gScrollPress = mapargs.context_event_data.y
      y = gScroll[gScrollHandleY] + yDelta

      if(y <= (gScroll[gScrollButtonHeight])) then
        y = gScroll[gScrollButtonHeight]
        scrollPercent = 0
      elseif(y >= (gScroll[gScrollBarHeight] - gScroll[gScrollButtonHeight] - gScroll[gScrollHandleHeight])) then
        y = gScroll[gScrollBarHeight] - gScroll[gScrollButtonHeight] - gScroll[gScrollHandleHeight]
        scrollPercent = 1
      else
        scrollPercent = y / (gScroll[gScrollBarHeight] - (gScroll[gScrollButtonHeight] * 2) - gScroll[gScrollHandleHeight])
      end
      gre.set_value(gScrollHandleY,y)
      gSI:scrollArea(scrollPercent)
    end
  elseif(mapargs.context_event == "gre.release" or mapargs.context_event == "gre.outbound") then
    gPressed = false
    gScrollPress = 0
  end
end

--- @param gre#context mapargs
function CBScrollPress(mapargs) 
  local extent = gre.rtext_text_extent(gre.get_value("Textfield_layer.notetext.text"),"Textfield_layer.notetext")
  
  if (extent.height > gre.get_value("Textfield_layer.notetext.grd_height")) then
    gPressed = true
    gScrollPress = mapargs.context_event_data.y
    
    local scrollArea = gre.get_control_attrs("Textfield_layer.ScrollBar.scrollArea","y", "height")
    local minY = scrollArea["y"]
    local maxY = scrollArea["height"]
    local scrollBarY = gre.get_value("Textfield_layer.ScrollBar.grd_y")
    local scrollMarkerHeight = gre.get_value("Textfield_layer.ScrollBar.marker.grd_height")
    local newY = gScrollPress - scrollBarY - (scrollMarkerHeight/2)
    local scrollPercent = newY/maxY
    
    if (newY < minY) then
      newY = minY
      scrollPercent = 0
    elseif(newY > maxY) then
      newY = maxY
      scrollPercent = 1
    end
    
    gre.set_value(gScrollHandleY,newY)
    gSI:scrollArea(scrollPercent)
  end
end


local function changeText(text) 
  local extent = gre.rtext_text_extent(text,"Textfield_layer.notetext")
  local data = {}
  data["Textfield_layer.notetext.text"] = text
  data["Textfield_layer.notetext.text_height"] = extent.height
  gre.set_data(data)
  
  gSI:init(true)
  -- override the max_y being calculated by text_scroll since we've already done it
  gSI.max_y = extent.height
  gSI.scroll_y = extent.height - 268
  CBUpdateScrollBar()
end

local text1 = [[
<style>
  @font-face {
    font-family: roboto-bold;
    src: url('file:fonts/Roboto-Bold.ttf')
  }
  @font-face {
    font-family: light;
    src: url('file:fonts/Roboto-Light.ttf')
  }
</style>
<p style="text-align:left">Left Aligned </p>
<p style="text-align:right"> Right Aligned </p>
<p style="text-align:center"> Aligned Center </p>
<p> <b> <u> I am Bold </u> </b> <br>I should be on my own line <br>
  <i> I am italic </i> <nobr>This long text should not be broken up.
  This long text should not be broken up.This long text should not be broken up.
  </nobr></p>
<p>
  <ol>
    <li> item 1 </li>
    <li> item 2 </li>
    <li> item 3 </li>
  </ol>
  <ul>
    <li> item A </li>
    <li> item B </li>
    <li> item C </li>
  </ul>
</p>
<p style="font-family:roboto-bold"> Roboto Bold </p>
<p style="font-family:light"> Roboto Light </p>
<p style="font-size: 50px"> 50px </p>
<p style="text-align:right">right aligned <span style="color:blue">combined with blue</span></p>
<p style="text-align:center">mixed styles: <span style="font-family:roboto-bold;color:blue">blue and bold</span> or <span style="color:green"><i>Green italic</i></span></p>]]

local text2 = [[
<p><span style="font-size:24px;color:blue"><b>Method</b></span></p>
<p>
  <ol>
    <li>Heat 1 tbsp oil in a frying pan, add the leeks, garlic, chilli and a good pinch of seasoning and cook until the leeks have softened, about 6-8 mins.</li>
    <li>Once the leeks are nearly done, push them to the side of the pan and fry the eggs in the remaining oil. Cooking over a medium heat to begin with ensures cooked whites and runny-yolk satisfaction.</li>
    <li>Toast the bread, then spread each slice with some Greek yogurt, top each with the leeks and squeeze over the lemon. Top with a fried egg, a scattering of sea salt and a few more chilli flakes to serve.</li>
  </ol>
</p>]]

local text3 = [[
<p>
  <span style="font-size:24px"><b>Ingredients</b></span>
  <br />
  <span style="font-size:10px">(The following list items are single-line only)</span>
</p>
<p>
  <i><ul><nobr>
    <li>2 tbsp olive oil</li>
    <li>1 large leek, sliced</li>
    <li>1 garlic clove, crushed</li>
    <li>good pinch chilli flakes, plus extra to serve</li>
    <li>2 eggs</li>
    <li>2 slices of sourdough</li>
    <li>2 tbsp Greek yogurt</li>
    <li>squeeze of lemon </li>
  </nobr></ul></i>
</p>]]

function CBChangeText1(mapargs) 
  changeText(text1)
end

function CBChangeText2(mapargs) 
  changeText(text2)
end

function CBChangeText3(mapargs) 
  changeText(text3)
end