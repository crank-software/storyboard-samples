local startAlphaGroup = "controlsLayer.startAlphaGroup"
local endAlphaGroup = "controlsLayer.endAlphaGroup"
local innerRadiusGroup = "controlsLayer.innerRadiusGroup"
local outerRadiusGroup = "controlsLayer.outerRadiusGroup"
local startAngleGroup = "controlsLayer.startAngleGroup"
local endAngleGroup = "controlsLayer.endAngleGroup"

local startColor = gre.rgb(114, 169,255)
local endColor = gre.rgb(113, 230, 255)
local startAlpha = 255
local endAlpha = 255

--- Move the selector in a group to show which control is the selection
local function MoveSelector(mapargs)
  local selected = gre.get_control_attrs(mapargs.context_control, "x", "y", "width", "height")
  gre.set_control_attrs(mapargs.context_group..".selector", { x = selected.x, y = selected.y })
end

function UpdateGradient() 
  local startAlpha = gre.get_value(startAlphaGroup ..".value.text")
  local endAlpha = gre.get_value(endAlphaGroup ..".value.text")
    
  gre.set_value("gradientLayer.gradientCanvas.startAlpha", tonumber(startAlpha))
  gre.set_value("gradientLayer.gradientCanvas.endAlpha", tonumber(endAlpha))
  gre.set_value("gradientLayer.gradientCanvas.startColor", startColor)
  gre.set_value("gradientLayer.gradientCanvas.endColor", endColor)

  local innerRadius = gre.get_value(innerRadiusGroup ..".value.text")
  local outerRadius = gre.get_value(outerRadiusGroup ..".value.text")
  gre.set_value("gradientLayer.gradientCanvas.innerRadius", innerRadius)
  gre.set_value("gradientLayer.gradientCanvas.outerRadius", outerRadius)

  local startAngle = gre.get_value(startAngleGroup ..".value.text")
  local endAngle = gre.get_value(endAngleGroup ..".value.text")
  gre.set_value("gradientLayer.gradientCanvas.startAngle", startAngle)
  gre.set_value("gradientLayer.gradientCanvas.endAngle", endAngle)
end

--- Selects the start color of the gradient
function CBSelectStartColor(mapargs) 
  startColor = gre.get_value(mapargs.context_control..".color")
  MoveSelector(mapargs)
  UpdateGradient()
end

--- Selects the end color of the gradient
function CBSelectEndColor(mapargs) 
  endColor = gre.get_value(mapargs.context_control..".color")
  MoveSelector(mapargs)
  UpdateGradient()
end

function AdjustValue(var, min, max, incr) 
  local value = gre.get_value(var)
  value = tonumber(value) + incr
  if(value > max) then
    value = max
  elseif(value < min) then
    value = min
  end
  gre.set_value(var, value)
end

--- Increase alpha 
function CBIncreaseAlpha(mapargs)
  AdjustValue(mapargs.context_group..".value.text", 0, 255, 5) 
  UpdateGradient()
end

--- Decrease alpha
function CBDecreaseAlpha(mapargs)
  AdjustValue(mapargs.context_group..".value.text", 0, 255, -5) 
  UpdateGradient()
end

--- Increase radius 
function CBIncreaseRadius(mapargs)
  AdjustValue(mapargs.context_group..".value.text", -1, 600, 5) 
  UpdateGradient()
end

--- Decrease radius
function CBDecreaseRadius(mapargs)
  AdjustValue(mapargs.context_group..".value.text", -1, 600, -5) 
  UpdateGradient()
end

--- Increase radius 
function CBIncreaseAngle(mapargs)
  AdjustValue(mapargs.context_group..".value.text", 0, 360, 5) 
  UpdateGradient()
end

--- Decrease radius
function CBDecreaseAngle(mapargs)
  AdjustValue(mapargs.context_group..".value.text", 0, 360, -5) 
  UpdateGradient()
end

function CBSelectDirection(mapargs)
  gre.set_value("gradientLayer.gradientCanvas.style", mapargs.style)
  if(mapargs.style == "sweep") then
    gre.set_control_attrs("controlsLayer.RadiusOverlay", { hidden = true })
    gre.set_control_attrs("controlsLayer.AngleOverlay", { hidden = true })    
  elseif(mapargs.style == "radial") then
    gre.set_control_attrs("controlsLayer.RadiusOverlay", { hidden = true })
    gre.set_control_attrs("controlsLayer.AngleOverlay", { hidden = false })    
  else
    gre.set_control_attrs("controlsLayer.RadiusOverlay", { hidden = false })
    gre.set_control_attrs("controlsLayer.AngleOverlay", { hidden = false })    
  end
  
  if(mapargs.direction) then
    gre.set_value("gradientLayer.gradientCanvas.direction", mapargs.direction)
  end
  MoveSelector(mapargs)
  UpdateGradient()
end
