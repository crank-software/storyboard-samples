--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local screenWidth=800
local bkgWidth=1800-screenWidth
local pictureWidth=3343-screenWidth

--This function gets the total percentage of movement from the image layer and applies
--it to the total percentage of the background layer.
--NOTE: offsets are in the negative direction to move layers to the left
function CBParalaxUpdate(mapargs) 
  local xoffset=gre.get_layer_attrs("picturesLayer","xoffset")
  bkgOffset=xoffset["xoffset"]*-1/pictureWidth*bkgWidth*-1
  local data={}
  data["xoffset"]=bkgOffset
  gre.set_layer_attrs("bkgLayer",data)
end
