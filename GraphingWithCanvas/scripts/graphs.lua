--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

Graph = {}
Graph.__index = Graph

function Graph.create(initData)
  local grph = {}
  setmetatable(grph, Graph)
  grph.type = initData.type
  grph.control = initData.control
  grph.canvas = gre.get_canvas(initData.name)
  if(grph.canvas == nil) then
    print("FAIL: I didn't get a canvas!")
    return
  end

  grph.margin = initData.margin or 41
  local canvasSize = grph.canvas:get_dimensions()
  grph.width = canvasSize.width
  grph.height = canvasSize.height
  grph.fillColor = initData.graphFill or 0xffffff
  grph.font = initData.font or "fonts/Roboto-Medium.ttf"
  grph.color = initData.color or 0xff0000
  grph.border = initData.border or false
  grph.ticks = initData.ticks or 10
  grph.canvas:fill(grph.fillColor)
  if(initData.fill ~= nil)then
    grph.fill = initData.fill
  end
  grph.minX = grph.margin
  grph.maxX = grph.width - grph.margin
  grph.minY = grph.height - grph.margin
  grph.maxY = grph.margin

  return grph
end

function Graph:Clear()
  self.canvas:fill(self.fillColor)
  self.canvas:stroke_line(self.minX - 1, self.minY + 1, self.maxX, self.minY + 1, 0x000000) -- x axis
  self.canvas:stroke_line(self.minX - 1, self.minY, self.minX - 1, self.maxY -1, 0x000000) -- y axis
end

function Graph:DrawBarGraph(data)
  local width = (self.maxX - self.minX) / #data *0.7 --40% of this will be padding
  local xPosition = self.margin

  local values = {}
  for i = 1, #data do
    table.insert(values, data[i].value)
  end

  local top = math.max(unpack(values))
  local upperBound = self:DrawScales(top)
  local height
  for i = 1, #data do
    height = data[i].value / upperBound * (self.minY - self.maxY)
    
    if height ~= height then --check for NAN value returned from divide by zero
      height = 0
    end
    
    self:DrawBar(xPosition + width * 0.4, width, height, data[i].color or self.color)
    self:DrawBottomLabel({label = data[i].label, x = xPosition + width * 0.4 + width / 2}) --the midpoint of the bar
    self:DrawScales(top)
    xPosition = xPosition + width * 0.4 + width
  end

  self.canvas:stroke_line(self.minX - 1, self.minY + 1, self.maxX, self.minY + 1, 0x000000) -- x axis
  self.canvas:stroke_line(self.minX - 1, self.minY, self.minX - 1, self.maxY-1, 0x000000) -- y axis
end

function Graph:DrawScales(top)
  local ticks = self.ticks or 10
  local minimum = top / ticks
  local magnitude = 10 ^ math.floor(math.log10(minimum))
  local residual = minimum / magnitude
  
  if residual ~= residual then --check for NAN value returned from divide by zero
    residual = 0
  end
  
  local step = nil
  if (residual > 5) then
    step = 10 * magnitude
  elseif (residual > 2) then
    step = 5 * magnitude
  elseif (residual > 1) then
    step = 2 * magnitude
  else
    step = magnitude
  end

  local ySteps = (self.maxY - self.minY) / ticks
  for i = 0, ticks do
    local yVal = self.minY + i*ySteps
    self.canvas:stroke_line(self.minX - 5, yVal, self.minX - 1, yVal, 0x000000)
    local attrs = {}
    attrs.size = 9
    local sizes = gre.get_string_size(self.font, attrs.size, string.format("%s", i*step))
    attrs.x = self.minX - sizes.width - 10 -- center the text
    attrs.y = yVal - sizes.height / 2
    attrs.font = self.font
    attrs.color = 0x000000
    self.canvas:draw_text(i * step, attrs)
  end
  return step * ticks --return the max value for calculating bar heights
end

function Graph:DrawBar(xorigin, width, height, color)
  self.canvas:fill_rect(xorigin, self.minY, xorigin + width, self.minY - height, color)
  if (self.border) then
    self.canvas:stroke_rect(xorigin, self.minY + 1, xorigin + width, self.minY - height, self.border)
  end
end

function Graph:DrawBottomLabel(data)
  if (data.label == nil) then return end
  local attrs = {}
  attrs.size = data.fontSize or 9
  local sizes = gre.get_string_size(self.font, attrs.size, data.label)
  attrs.x = math.floor(data.x) - sizes.width / 2 -- center the text
  attrs.y = self.height - self.margin / 2 - attrs.size / 2
  attrs.font = self.font
  attrs.color = 0x000000
  self.canvas:draw_text(data.label, attrs )
end

function Graph:DrawLineChart(data)
  local values = {}
  for i = 1, #data do
    table.insert(values, data[i].value)
  end
  local top = math.max(unpack(values))
  local upperBound = self:DrawScales(top)
  local steps = (self.maxX - self.minX) / #data
  local fillPointData = {}
  local pointData = {}

  if (data.fill ~= nil) then --if we're supplied a fill use that one
    self.fill = data.fill
  end

  for i = 1, #data do
    local point = {}
    point.y = self.minY - (data[i].value / upperBound * (self.minY - self.maxY))
    point.x = self.minX + i * steps - steps / 2
    table.insert(pointData, point)
    if(self.fill) then
      table.insert(fillPointData, point)
    end
  end
  if(self.fill) then
    local firstpoint = {x=pointData[1].x, y=self.minY + 1}
    table.insert(fillPointData,1,firstpoint)
    local lastpoint = {x=pointData[#pointData].x, y=self.minY + 1}
    table.insert(fillPointData, lastpoint)
    self.canvas:fill_poly(fillPointData, self.fill)
  end
  self.canvas:stroke_poly(pointData, self.border)
  for i = 1, #pointData do
    self.canvas:fill_rect(pointData[i].x - 2, pointData[i].y + 2 , pointData[i].x + 2, pointData[i].y - 2, self.color)
  end
  Graph:DrawBottomLabel(data)
  for i=1, #data do
    self:DrawBottomLabel({label = data[i].label, x = pointData[i].x}) --the midpoint of the bar
  end

end
