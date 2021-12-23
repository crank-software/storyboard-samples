--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

gLastValue = nil

function PopulateIncrementer(mapargs)
  local data = {}
  gLastValue = gCurrentMenu.items[gLastRow].value
  data["incrementerControls_layer.currentValue.value"] = gLastValue

  local targetMenu = "incrementerControls_layer.menuGroup.breadcrumb.text"
  data[targetMenu] = gMenuStack[1].title
  gCurrentMenu = gMenuStack[#gMenuStack]
  
  for i = 2, #gMenuStack do
    data[targetMenu] = string.format("%s > %s", data[targetMenu], gMenuStack[i].title)
  end
  
  data[targetMenu] = string.format("%s > %s", data[targetMenu], gCurrentMenu.items[gLastRow].title)
  data["nextScreen"] = "incrementer_screen"
  data["screenDirection"] = "right"
  gre.set_data(data)
  gre.send_event("swapScreen")
end

function CBChangeValue(mapargs)
  local data = {}
  local curVal = gre.get_value("incrementerControls_layer.currentValue.value")
  local newValue = curVal + mapargs.value
  
  data["incrementerControls_layer.currentValue.value"] = newValue
  gLastValue = newValue
  gre.set_data(data)
end
