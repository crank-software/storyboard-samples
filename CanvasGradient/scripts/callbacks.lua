local canvasControl = "gradientLayer.gradientCanvas"
local startAlphaGroup = "controlsLayer.startAlphaGroup"
local endAlphaGroup = "controlsLayer.endAlphaGroup"
local canvasName = "canvas"
local startColor = {
  r = 114,
  g = 169,
  b = 255
}
local endColor = {
  r = 113,
  g = 230,
  b = 255
}
local startAlpha = 255
local endAlpha = 255
local direction = "leftToRight"
local steps = 60
local maxSteps = 100
local minSteps = 5
local minAlpha = 0
local maxAlpha = 255

--- Move the selector in a group to show which control is the selection
local function MoveSelector(mapargs)
  local selected = gre.get_control_attrs(mapargs.context_control, "x", "y", "width", "height")
  local selector = gre.get_control_attrs(mapargs.context_group..".selector", "width", "height")
  gre.set_control_attrs(mapargs.context_group..".selector", { x = selected.x, y = selected.y })
end

--- Selects the start color of the gradient
function CBSelectStartColor(mapargs) 
  local newColor = string.format("%06x", gre.get_value(mapargs.context_control..".color"))
  -- Convert hex colour string to decimals and separate the R, G, and B values
  startColor.r = tonumber(string.sub(newColor, 1, 2), 16)
  startColor.g = tonumber(string.sub(newColor, 3, 4), 16)
  startColor.b = tonumber(string.sub(newColor, 5, 6), 16)
  MoveSelector(mapargs)
  UpdateGradient()
end

--- Selects the end color of the gradient
function CBSelectEndColor(mapargs) 
  local newColor = string.format("%06x", gre.get_value(mapargs.context_control..".color"))
  -- Convert hex colour string to decimals and separate the R, G, and B values
  endColor.r = tonumber(string.sub(newColor, 1, 2), 16)
  endColor.g = tonumber(string.sub(newColor, 3, 4), 16)
  endColor.b = tonumber(string.sub(newColor, 5, 6), 16)
  MoveSelector(mapargs)
  UpdateGradient()
end

--- Selects the direction of the gradient
function CBSelectDirection(mapargs) 
  direction = gre.get_value(mapargs.context_control..".direction")
  MoveSelector(mapargs)
  UpdateGradient()
end

--- Increase number of steps by 5
function CBIncreaseSteps(mapargs)
  if (steps < maxSteps) then
    steps = steps + 5
  end
  gre.set_value(mapargs.context_group..".value.text", steps) 
  UpdateGradient()
end

--- Decrease number of steps by 5
function CBDecreaseSteps(mapargs)
  if (steps > minSteps) then
    steps = steps - 5
  end
  gre.set_value(mapargs.context_group..".value.text", steps) 
  UpdateGradient()
end

--- Increase alpha by 15
function CBIncreaseAlpha(mapargs)
  if (mapargs.context_group == startAlphaGroup) and (startAlpha < maxAlpha) then
    startAlpha = startAlpha + 15
    gre.set_value(mapargs.context_group..".value.text", startAlpha) 
  elseif (mapargs.context_group == endAlphaGroup) and (endAlpha < maxAlpha) then
    endAlpha = endAlpha + 15
    gre.set_value(mapargs.context_group..".value.text", endAlpha)
  end
  UpdateGradient()
end

--- Decrease alpha by 15
function CBDecreaseAlpha(mapargs)
  if (mapargs.context_group == startAlphaGroup) and (startAlpha > minAlpha) then
    startAlpha = startAlpha - 15
    gre.set_value(mapargs.context_group..".value.text", startAlpha) 
  elseif (mapargs.context_group == endAlphaGroup) and (endAlpha > minAlpha) then
    endAlpha = endAlpha - 15
    gre.set_value(mapargs.context_group..".value.text", endAlpha)
  end
  UpdateGradient()
end

--- Calculates the next step color in the gradient
--- @param startValue The start color's r, g, or b value
--- @param endValue The end color's r, g, or b value
--- @param step The current step in the gradient
--- @param totalSteps The total amount of steps in the gradient
local function Interpolate(startValue, endValue, step, totalSteps)
  -- Interpolate needs a 0 based step start, so we subtract 1 from step and totalSteps
  step = step - 1
  totalSteps = totalSteps - 1
  if (startValue > endValue) then
    return ((endValue - startValue) * (step / totalSteps)) + startValue
  else
    return ((startValue - endValue) * (1 - (step / totalSteps))) + endValue
  end
end

--- Updates the gradient control to display selections.
function UpdateGradient()
  local stepSize = 1
  local control = gre.get_control_attrs(canvasControl, "width", "height")
  local canvas = gre.get_canvas(canvasName)
  canvas:clear_rect(0, 0, control.width, control.height)
  local stepColor = {
    r = startColor.r, 
    g = startColor.g, 
    b = startColor.b 
  }
  local rect = {
    x1 = 0,
    x2 = 0,
    y1 = 0,
    y2 = 0
  }
  
  -- Calculate the stepSize given the direction and the amount of steps
  if (direction == "leftToRight") or (direction == 'rightToLeft') then
    stepSize = control.width / steps
  elseif (direction == "topToBottom") or (direction == 'bottomToTop') then
    stepSize = control.height / steps
  end
  
  for i = 1, steps do
    -- Calculate color for current step (i)
    stepColor.r = Interpolate(startColor.r, endColor.r, i, steps)
    stepColor.g = Interpolate(startColor.g, endColor.g, i, steps)
    stepColor.b = Interpolate(startColor.b, endColor.b, i, steps)
    -- Convert values to one hex color value
    local color = tonumber(string.format('0x%02x%02x%02x', stepColor.r, stepColor.g, stepColor.b))
    local stepAlpha = math.floor(Interpolate(startAlpha, endAlpha, i, steps))
    
    -- Set up rectangle coordinates (-1 from "to" coordinate to prevent 1px overlap)
    if (direction == "leftToRight") then
      rect.x1 = (i - 1) * stepSize
      rect.y1 = 0
      rect.x2 = (i * stepSize) - 1
      rect.y2 = control.height
    elseif (direction == "rightToLeft") then
      rect.x1 = control.width - ((i - 1) * stepSize) - 1
      rect.y1 = 0
      rect.x2 = (control.width - (i * stepSize))
      rect.y2 = control.height
    elseif (direction == "topToBottom") then
      rect.x1 = 0
      rect.y1 = ((i - 1) * stepSize)
      rect.x2 = control.width
      rect.y2 = (i * stepSize) - 1
    elseif (direction == "bottomToTop") then
      rect.x1 = 0
      rect.y1 = (control.height - ((i - 1) * stepSize)) - 1
      rect.x2 = control.width
      rect.y2 = control.height - (i * stepSize)
    end
    
    -- Add a colored rectangle to the canvas at the previously calculated coordinates
    canvas:set_alpha(stepAlpha)
    canvas:fill_rect(round(rect.x1), round(rect.y1), round(rect.x2), round(rect.y2), color)
  end
end

--- Round a given number to the neareast digit
function round(x)
  return math.floor(x + 0.5)
end

