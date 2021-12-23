--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local DEFAULT_TABLE_HEIGHT = 350
local DEFAULT_TABLE_OUTLINE_PADDING = 4

function PopulateMenu(mapargs)
  local data = {}
  local targetTable
  local tableMenu
  local menuGroupPath
  local tableGroupPath
  local targetMenu

  if (mapargs) then
    if (mapargs.direction) then
      data["screenDirection"] = "left"
    end
  else
     data["screenDirection"] = "right"
  end

  if (gCurrentScreen == "main_screen") then
    targetTable = "mainMenu2_layer.tableGroup.table"
    targetMenu = "mainMenu2_layer.menuGroup.breadcrumb.text"
    data["nextScreen"] = "main_screen2"
    gCurrentScreen = "altScreen"
    menuGroupPath = "mainMenu2_layer.menuGroup"
    tableGroupPath = "mainMenu2_layer.tableGroup"
  else
    targetTable = "mainMenu_layer.tableGroup.table"
    targetMenu = "mainMenu_layer.menuGroup.breadcrumb.text"
    data["nextScreen"] = "main_screen"
    gCurrentScreen = "main_screen"
    menuGroupPath = "mainMenu_layer.menuGroup"
    tableGroupPath = "mainMenu_layer.tableGroup"
  end
  
  data[targetMenu] = ""
  if (#gMenuStack < 1) then
    gCurrentMenu = mainMenu
    table.insert( gMenuStack, mainMenu )
    data[targetMenu] = gCurrentMenu.title
  else
    gCurrentMenu = gMenuStack[#gMenuStack]
    data[targetMenu] = gMenuStack[1].title
    for i = 2, #gMenuStack do
      data[targetMenu] = string.format("%s > %s",data[targetMenu],gMenuStack[i].title)
    end
  end

  --  Hide the back button if we are on root and slide the title to the left
  if (gCurrentMenu == mainMenu) then
    data[menuGroupPath..".backButton.grd_hidden"] = 1
    data[menuGroupPath..".breadcrumb.grd_x"] = 30
  else
    data[menuGroupPath..".backButton.grd_hidden"] = 0
    data[menuGroupPath..".breadcrumb.grd_x"] = 60
  end

  for k,v in pairs(gCurrentMenu.items) do
    local titleText = string.format("%s.text.%s.1", targetTable, k)
    local valueText = string.format("%s.value.%s.1", targetTable, k)
    data[titleText] = v.title
    if (v.value ~= nil) then
      data[valueText] = v.value
    else
      data[valueText] = ""
    end
  end

  local cell_data = gre.get_table_cell_attrs(targetTable, 1, 1, 'height')
  local tableData = {}
  tableData.rows = table.getn(gCurrentMenu.items)
  local table_height = tableData.rows * cell_data.height
  
  if (table_height < DEFAULT_TABLE_HEIGHT) then
    tableData.height = table_height
  else
    tableData.height = DEFAULT_TABLE_HEIGHT
  end
  
  data[tableGroupPath .. ".tableOutline.grd_height"] = tableData.height + DEFAULT_TABLE_OUTLINE_PADDING   
  tableData.yoffset = 0
  
  gre.set_table_attrs(targetTable, tableData)
  gre.set_data(data)
  gre.send_event("swapScreen")
end

function InitPoly()
  local data = gre.get_data("mainMenu_layer.menuGroup.backButton.grd_width", "mainMenu_layer.menuGroup.backButton.grd_height")
  local width = data["mainMenu_layer.menuGroup.backButton.grd_width"]
  local height = data["mainMenu_layer.menuGroup.backButton.grd_height"]
  
  local poly_points = {}
  table.insert(poly_points, {x=0, y=math.floor(height/2)})
  table.insert(poly_points, {x=math.floor(width/2), y=0})
  table.insert(poly_points, {x=math.floor(width/2), y=height})
  local string = gre.poly_string(poly_points)
  gre.set_value("poly", string)
end
