--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local graph1
local graph2
local graph3
local graph4

function CBGraphsSetup()
  local initData = {}
  initData.type = "bar"
  initData.ticks = 5
  initData.control = "graphLayer.canvas1"
  initData.name = "canvas_1"
  initData.border = 0x000000
  initData.color = 0x007700
  initData.graphFill = 0xE3E6E9
  graph1 = Graph.create(initData)

  initData.name = "canvas_2"
  initData.type = "line"
  initData.control = "graphLayer.canvas2"
  graph2 = Graph.create(initData)

  initData.name = "canvas_3"
  initData.type = "line"
  initData.ticks = 8
  initData.fill = 0x00ffff
  initData.color = 0xff7700

  initData.control = "graphLayer.canvas3"
  graph3 = Graph.create(initData)

  initData.name = "canvas_4"
  initData.type = "bar"
  initData.ticks = 3
  initData.border = false
  initData.control = "graphLayer.canvas4"
  graph4 = Graph.create(initData)

  DoEverything()
end


function CBCanvas1()
  graph1:Clear()
  local dataTable = {}
  for i = 1, math.random(2, 5) do
    local dataPoint = {}
    dataPoint.value = math.random(0, 500)
    dataPoint.label = string.format("Label %s", i)
    if (i % 2 == 1) then
      dataPoint.color = 0x90ff90
    end
    table.insert(dataTable, dataPoint)
  end
  graph1:DrawBarGraph(dataTable)
end

function CBCanvas2()
  graph2:Clear()
  local dataTable = {}
  for i = 1, math.random(3, 10) do
    local dataPoint = {}
    dataPoint.value = math.random(0, 20)
    dataPoint.label = string.format("%s", i)
    table.insert(dataTable, dataPoint)
  end
  graph2:DrawLineChart(dataTable)
end

function CBCanvas3()
  graph3:Clear()
  local dataTable = {}
  for i = 1, math.random(3, 6) do
    local dataPoint = {}
    dataPoint.value = math.random(0, 5000)
    dataPoint.label = string.format("Label %s", i)
    table.insert(dataTable, dataPoint)
  end
  graph3:DrawLineChart(dataTable)
end

function CBCanvas4()
  graph4:Clear()
  local dataTable = {}
  for i = 1, math.random(2, 5) do
    local dataPoint = {}
    dataPoint.value = math.random(0, 2222)
    dataPoint.label = string.format("Label %s", i)
    table.insert(dataTable, dataPoint)
  end
  graph4:DrawBarGraph(dataTable)
end

function DoEverything()
  CBCanvas1()
  CBCanvas2()
  CBCanvas3()
  CBCanvas4()
end

local ticker = nil
local timerBool = false

function CBTimerToggle(mapargs)
  if(timerBool)then
    timerBool = false
    gre.set_value("graphLayer.randomizeButton.text", "") --e037
    gre.timer_clear_interval(ticker)
  else
    gre.set_value("graphLayer.randomizeButton.text", "") --e047
    ticker = gre.timer_set_interval(DoEverything, 100)
    timerBool = true
  end
end

function CBLeaveScreen(mapargs)
  if(timerBool)then
    timerBool = false
    gre.set_value("graphLayer.randomizeButton.text", "")
    gre.timer_clear_interval(ticker)
  end
end
