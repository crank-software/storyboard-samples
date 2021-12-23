--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

require("tables")
require("incrementer")
require("slider")

--menu stack holds our breadcrumbing data. we derrive the title from gMenuStack[i].title
gMenuStack={mainMenu}

--simple return false for menus that are dead ends.
function nullTableEnd()
  return false
end

incrementerItems = {
  {title = "Item 1", itemFunction = PopulateIncrementer, value = "32"},
  {title = "Item 2", itemFunction = PopulateIncrementer, value = "423"},
  {title = "Item 3", itemFunction = PopulateIncrementer, value = "357"},
  {title = "Item 4", itemFunction = PopulateIncrementer, value = "457"},
  {title = "Item 5", itemFunction = PopulateIncrementer, value = "1"},
  {title = "Item 6", itemFunction = PopulateIncrementer, value = "1237"},
  {title = "Item 7", itemFunction = PopulateIncrementer, value = "4262"},
  {title = "Item 8", itemFunction = PopulateIncrementer, value = "8678"}
}

sliderItems = {
  {title = "Slider 1", itemFunction = PopulateSlider, value = "100"},
  {title = "Slider 2", itemFunction = PopulateSlider, value = "23"},
  {title = "Slider 3", itemFunction = PopulateSlider, value = "57"},
  {title = "Slider 4", itemFunction = PopulateSlider, value = "45"},
  {title = "Slider 5", itemFunction = PopulateSlider, value = "12"},
  {title = "Slider 6", itemFunction = PopulateSlider, value = "23"},
  {title = "Slider 7", itemFunction = PopulateSlider, value = "62"},
  {title = "Slider 8", itemFunction = PopulateSlider, value = "86"}
}

mixedItems = {
  {title = "Slider 1", itemFunction = PopulateSlider, value = "86"},
  {title = "Iterator 1", itemFunction = PopulateIncrementer, value = "1723"},
  {title = "Slider 2", itemFunction = PopulateSlider, value = "12"},
  {title = "Non Value Item", itemFunction = nullTableEnd},
  {title = "Iterator 2", itemFunction = PopulateIncrementer, value = "423"},
  {title = "Slider 3", itemFunction = PopulateSlider, value = "22"}
}


subSystemItems = {
  {title = "Sub System 1", itemFunction = nullTableEnd},
  {title = "Sub System 2", itemFunction = nullTableEnd},
  {title = "Sub System 3", itemFunction = nullTableEnd},
  {title = "Sub System 4", itemFunction = nullTableEnd},
  {title = "Sub System 5", itemFunction = nullTableEnd},
  {title = "Sub System 6", itemFunction = nullTableEnd},
  {title = "Sub System 7", itemFunction = nullTableEnd},
  {title = "Sub System 8", itemFunction = nullTableEnd}
}

--These all have the same menu items to conserve space right now. You could have as many trees as you'd like
--A full menu system could be built out with a database however for the purpose of this sample, a lua table will do
systemItems = {
  {title = "System 1", items = subSystemItems, type = "menu", itemFunction = PopulateMenu},
  {title = "System 2", items = subSystemItems, type = "menu", itemFunction = PopulateMenu},
  {title = "System 3", items = subSystemItems, type = "menu", itemFunction = PopulateMenu},
  {title = "System 4", items = subSystemItems, type = "menu", itemFunction = PopulateMenu},
  {title = "System 5", items = subSystemItems, type = "menu", itemFunction = PopulateMenu},
  {title = "System 6", items = subSystemItems, type = "menu", itemFunction = PopulateMenu},
  {title = "System 7", items = subSystemItems, type = "menu", itemFunction = PopulateMenu},
  {title = "System 8", items = subSystemItems, type = "menu", itemFunction = PopulateMenu}
}

mainMenuItems = {
    {title = "Incrementer", items = incrementerItems, type = "menu", itemFunction = PopulateMenu},
    {title = "System", items = systemItems, type = "menu", itemFunction = PopulateMenu},
    {title = "Sliders", items = sliderItems, type = "menu", itemFunction = PopulateMenu},
    {title = "Mixed Items", items = mixedItems, type = "menu", itemFunction = PopulateMenu}
}

mainMenu = {
  title = "Main Menu", items = mainMenuItems
}
