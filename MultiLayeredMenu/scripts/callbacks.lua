--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

require("menuDatabase")

gCurrentMenu = nil
gLastRow = nil
gCurrentScreen = nil

function CBInit(mapargs)
  InitPoly()
  InitSlider()
  PopulateMenu()
end

function CBMenuPress(mapargs)
  local pressedControl = gCurrentMenu.items[mapargs.context_row]
  gLastRow = mapargs.context_row
  if (pressedControl.type == "menu") then
    table.insert(gMenuStack,pressedControl)
  end
  pressedControl.itemFunction()
end

function CBBackPress(mapargs)
  mapargs.direction = "left"
  if (#gMenuStack > 1) then
    table.remove(gMenuStack, #gMenuStack)
    PopulateMenu(mapargs)
  end
end

function CBSaveItem(mapargs)
  gCurrentMenu.items[gLastRow].value = gLastValue
  mapargs.direction = "left"
  PopulateMenu(mapargs)
end
