--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

require "graphs"
local bargraph
math.randomseed(os.time())

function CBGenerateSimpleGraph() 
  bargraph:Clear()
  local dataTable = {}
  dataTable.fill = false
  for i = 1, math.random(5, 11) do
    local dataPoint = {}
    dataPoint.value = math.random(0, 500)
    dataPoint.label = string.format("Label %s", i)
    table.insert(dataTable, dataPoint)
  end
  bargraph:DrawLineChart(dataTable)
end

function CBInit()
  local initData = {}
  initData.type = "bar"
  initData.control = "Layer.canvas"
  initData.name = "main_canvas"
  initData.border = 0x000000
  initData.color = 0x007700
  initData.graphFill = 0xE3E6E9
  bargraph = Graph.create(initData)
  CBGenerateSimpleGraph()
end

function CBInfoToggle(mapargs)
  local state = gre.get_value("infoLayer.infoGroup.grd_hidden")
  if(state == 1) then
    gre.set_value("infoLayer.infoGroup.grd_hidden", 0)
  else
    gre.set_value("infoLayer.infoGroup.grd_hidden", 1)
  end
end
