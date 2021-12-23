--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local DEGREES_IN_CIRCLE = 360 
local PERCENTAGE_MULTIPLIER = 100 
local ANGLE_OFFSET = 90 
local GAUGE_ANGLE_OFFSET = 225
local DEGREES_IN_GAUGE = 135

function CBUpdateIncrementCircleText(mapargs) 
  local data = {}
  data = gre.get_data("circle1.blue_fill.var")

  local val = data["circle1.blue_fill.var"] + ANGLE_OFFSET
  local percent = val/DEGREES_IN_CIRCLE
  local circle1_value = percent*PERCENTAGE_MULTIPLIER
  
  gre.set_data({["circ1_value"] = tostring(string.format("%d", circle1_value))})
end

function CBUpdateCircularFillText(mapargs) 
  local data = {}
  data = gre.get_data("circle2.orange_fill.var")

  local val = data["circle2.orange_fill.var"] + ANGLE_OFFSET
  local percent = val/DEGREES_IN_CIRCLE
  local circle2_value = percent*PERCENTAGE_MULTIPLIER
  
  gre.set_data({["circ2_value"] = tostring(string.format("%d", circle2_value))})
end

function CBUpdateDashedLineText(mapargs) 
  local data = {}
  data = gre.get_data("circle3.circle3_fill.var")

  local val = data["circle3.circle3_fill.var"] + ANGLE_OFFSET
  local percent = val/DEGREES_IN_CIRCLE
  local circle3_value = percent*PERCENTAGE_MULTIPLIER
  
  gre.set_data({["circ_3_value"] = tostring(string.format("%d", circle3_value))})
end

function CBUpdateBlackFadeText(mapargs) 
  local data = {}
  data = gre.get_data("black_fade.circle_blue.var")

  local val = data["black_fade.circle_blue.var"] + ANGLE_OFFSET
  local percent = val/DEGREES_IN_CIRCLE
  local circle6_value = percent*PERCENTAGE_MULTIPLIER
  
  gre.set_data({["circ_6_value"] = tostring(string.format("%d", circle6_value))})
end

function CBUpdateGaugeText(mapargs) 
  local data = {}
  data = gre.get_data("circle7.circ7_fill.var")

  local val = data["circle7.circ7_fill.var"] + GAUGE_ANGLE_OFFSET
  local percent = val/DEGREES_IN_GAUGE+2
  local circle7_value = percent*PERCENTAGE_MULTIPLIER
  
  gre.set_data({["circ_7_value"] = tostring(string.format("%d", circle7_value))})
end
