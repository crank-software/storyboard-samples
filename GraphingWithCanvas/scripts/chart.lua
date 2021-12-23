--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

Chart = {}
Chart.__index = Chart

function Chart.create(name, config)
   local chart = {}             
   setmetatable(chart, Chart)  
 
   -- TODO: Seed the config with defaults..
   chart.config = config
   
   chart.canvas = gre.get_canvas(name)  
   if(chart.canvas == nil) then
      return nil
   end
   chart.canvas:clear(0xffffff)
  
   local canvasSize = chart.canvas:get_dimensions()
   chart.width = canvasSize.width
   chart.height = canvasSize.height
        
   
   chart:syncMetrics()
   
   chart:draw()
   
   return chart
end

function Chart:getDataSetType(dataSet) 
  if(dataSet ~= nil and dataSet.type ~= nil) then
    return dataSet.type
  end

  if(self.config.type ~= nil) then
    return self.config.type
  end

  return "bar"
end

-- Return an array of data objects
function Chart:getDataSets()
  return self.config.data.datasets
end

function Chart:getDataLabels()
  return self.config.data.labels
end

function Chart:getDataSetProperty(property, dataSet, index, defaultValue)
  local value = dataSet[property]
  print("Looking for " .. tostring(property) .. " is ".. tostring(value))
  local valueType = type(value)
  if(valueType == "number") then
    return value
  end
  if(valueType == "table" and valueType[index] ~= nil) then
    return valueType[index]
  end
  
  return defaultValue
end

function Chart:getBackgroundColor(dataSet, index)
  return self:getDataSetProperty("backgroundColor", dataSet, index, 0xffffff)
end

function Chart:getBorderColor(dataSet, index)
  local value = self:getDataSetProperty("borderColor", dataSet, index, nil)
  if(value ~= nil) then
    return value
  end
  return self:getBackgroundColor(dataSet, index)
end

function Chart:getMetrics(dataSet)
  return self.metrics[dataSet]
end

function Chart:syncMetrics()
  local maxValue, minValue, maxLength, minLength
  
  self.metrics = {}
  
  local dataSet = self:getDataSets()
  for i=1,#dataSet do
    local data = dataSet[i].data
    local dsMaxValue, dsMinValue, dsSum
    
    if(maxLength == nil or #data > maxLength) then
      maxLength = #data
    end
    if(minLength == nil or #data < minLength) then
      minLength = #data
    end
    
    dsSum = 0
    for d=1,#data do
      if(dsMaxValue == nil or data[d] > dsMaxValue) then
        dsMaxValue = data[d]
      end
      if(dsMinValue == nil or data[d] < dsMinValue) then
        dsMinValue = data[d]
      end
      dsSum = dsSum + data[d]
    end
    
    self.metrics[dataSet[i]] = { 
      maxValue = dsMaxValue, 
      minValue = dsMinValue,
      sum = dsSum,
    } 
    
    if(maxValue == nil or dsMaxValue > maxValue) then
      maxValue = dsMaxValue
    end
    if(minValue == nil or dsMinValue < minValue) then
      minValue = dsMinValue
    end
  end
  
  self.maxValue = maxValue
  --self.minValue = minValue
  self.minValue = 0

  self.maxLength = maxLength
  self.minLength = minLength
end

local function drawBarChart(chart, dataSet)
  local canvas = chart.canvas

  local isVertical = true
  local isStacked = false
  
  -- This assumes a uniform scaling on all charts ...
  local metrics = chart:getMetrics(dataSet)
  --Assume we are baselining at a value of 0
  local valueDelta = metrics.maxValue
  local barCount = chart.maxLength
  if(isStacked) then
    valueDelta = metrics.sum
    --barCount = 1
  end
  
  -- A standard bar is <pad><advance-pad><pad><advance-pad>...
  local pixAdvance = 0   -- How many pixels the bar data is
  local pixPadding = 0   -- How many pixels of padding there is 
  local pixPerValue = 0  -- Scale factor for pixel per value
  local baseline = 0     -- The baseline where we start the chart
  
  if(isVertical) then
    pixAdvance = chart.width / barCount
    pixPerValue = -1 * (chart.height / valueDelta)
    baseline = chart.height
  else
    pixAdvance = chart.height / barCount
    pixPerValue = (chart.width / valueDelta)
    baseline = 0
  end
  pixPadding = 0.20 * pixAdvance
  pixAdvance = pixAdvance - pixPadding
  
  local x1, y1, x2, y2, clr  
  local data = dataSet.data 
  for d=1,#data do
    offset = (data[d] * pixPerValue)
    
    if(isStacked) then
      x1 = 0
    else
      x1 = (d - 1) * (pixAdvance + pixPadding)
    end
    y1 = baseline
    x2 = x1 + pixAdvance
    y2 = baseline + offset

    if(not isVertical) then
      x1,y1,x2,y2 = y1,x1,y2,x2 
    end
    
    if(isStacked) then
      baseline = baseline + offset
    end
    
    clr = chart:getBackgroundColor(dataSet, d)
    canvas:fill_rect(x1, y1, x2, y2, clr)
    
    local borderClr = chart:getBorderColor(dataSet, d)
    if(borderClr ~= clr) then
      canvas:stroke_rect(x1, y1, x2, y2, borderClr)
    end
  end  
end

local function drawLineChart(chart, dataSet)
  local canvas = chart.canvas
  local valueDelta = chart.maxValue - chart.minValue

  local pixPerValue = chart.height / valueDelta
  local pixAdvance = chart.width / (chart.maxLength-1)

  local x1,y1,clr
  local xyArray = {}
  
  local data = dataSet.data 
  for d=1,#data do
    x1 = (d - 1) * pixAdvance
    y1 = chart.height - (data[d] * pixPerValue)

    table.insert(xyArray, { x=x1, y=y1 })
       
    --clr = chart:getBackgroundColor(dataSet, d)
    clr = 0xB533FF
    canvas:fill_rect(x1-2, y1-2, x1+2, y1+2, clr)
  end  

  canvas:stroke_poly(xyArray, 0xff0000)
  for i=1,#xyArray-2 do
    local pt0 = xyArray[i]
    local pt1 = xyArray[i+1]
    local pt2 = xyArray[i+2]
    local t = 0.2
    local cp = getControlPoints(pt0.x, pt0.y, pt1.x, pt1.y, pt2.x, pt2.y, t) 
    table.insert(cp, 1, pt0)
    table.insert(cp, pt1)
    
    local newPoints = generateBezierPolygon(cp)
    print("Created " .. tostring(#newPoints))
    local pt = newPoints[#newPoints]
    pt.x = math.floor(pt.x)
    pt.y = math.floor(pt.y)
    for p=#newPoints-1,1,-1 do
        pt = newPoints[p]
        pt.x = math.floor(pt.x)
        pt.y = math.floor(pt.y)
        if(newPoints[p+1].x == pt.x and newPoints[p+1].y == pt.y) then
          table.remove(newPoints,p+1)
        end
    end
    canvas:stroke_poly(newPoints, clr)
  end
end


local ChartDrawFunctions = {
  ["bar"] = drawBarChart,
  ["line"] = drawLineChart,
}

function Chart:draw()
  local dataSet = self:getDataSets()
  for i=1,#dataSet do
    local type = self:getDataSetType(dataSet[i])
    local draw = ChartDrawFunctions[type]
    if(draw ~= nil) then
      draw(self, dataSet[i])
    end
  end
end


---
-- Utility Functions
---

-- Sample derived from Bezier Curve Primer:
-- http://pomax.github.io/bezierinfo/

-- Generate a single draw point based on the input
-- control points and the ratio along the curve 't'
--
--@param points A table containing x/y points
--@param t The ration along the curve in the range from 0-1
--@param draw A drawing callback function to draw a point (x,y)
local function drawCurve(points, t, draw) 
  local pointsLength = #points
  if(pointsLength == 1) then
    draw(points[1])
  else
    local x, y
    local newpoints= {}
    for i=1,pointsLength-1 do
      x = (1-t) * points[i].x + t * points[i+1].x
      y = (1-t) * points[i].y + t * points[i+1].y
      table.insert(newpoints, { x = x, y = y })
    end
    drawCurve(newpoints, t, draw)
  end 
end    
    
-- Generate a table of points ({x,y}) constituring the Bezier curve
-- based on the provided input control point table ({x,y})
--
--@param points A table of control points for the Bezier curve
--@return A table of points on the Bezier curve specified by the control points
function generateBezierPolygon(points) 
  local drawnPoints = {}
  local drawFunction = function(pt)  table.insert(drawnPoints, pt) end
  for t=0,1,.05 do
    drawCurve(points, t, drawFunction)
  end
  return drawnPoints
end

function getControlPoints(x0,y0,x1,y1,x2,y2,t) 
    print(string.format("CP: %d,%d %d,%d %d,%d", x0, y0, x1, y1, x2, y2))
    local d01=math.sqrt(math.pow(x1-x0,2)+math.pow(y1-y0,2));
    local d12=math.sqrt(math.pow(x2-x1,2)+math.pow(y2-y1,2));
    local fa=t*d01/(d01+d12);   -- scaling factor for triangle Ta
    local fb=t*d12/(d01+d12);   -- ditto for Tb, simplifies to fb=t-fa
    local p1x=x1-fa*(x2-x0);    -- x2-x0 is the width of triangle T
    local p1y=y1-fa*(y2-y0);    -- y2-y0 is the height of T
    local p2x=x1+fb*(x2-x0);
    local p2y=y1+fb*(y2-y0);  
    return {{x=p1x,y=p1y}, {x=p2x,y=p2y}};
end
  
  