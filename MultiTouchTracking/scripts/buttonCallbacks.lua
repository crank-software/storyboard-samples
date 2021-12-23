--[[
Copyright 2018, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--
local plugin_dir = os.getenv("SB_PLUGINS")
print(plugin_dir)
print(gre.PLUGIN_ROOT)

local debounceTimers = {}

local STATE_RELEASED = 0
local STATE_DEBOUNCING = 1
local STATE_PRESSED = 2

local states = {
                  ["ButtonLayer.button1"]=0, 
                  ["ButtonLayer.button2"]=0,
                  ["ButtonLayer.button3"]=0
               }
               
--Id's for each finger on a control
local touches = {
                  ["ButtonLayer.button1"]={}, 
                  ["ButtonLayer.button2"]={},
                  ["ButtonLayer.button3"]={}
               }

local labels = {
                  ["ButtonLayer.button1"]="A",
                  ["ButtonLayer.button2"]="B",
                  ["ButtonLayer.button3"]="C"    
               }
               
local function CBAPressed()
  print("A Pressed")
end

local function CBBPressed()
  print("B Pressed")
end

local function CBCPressed()
  print("C Pressed")
end 
               
local pressCB = {
                  ["ButtonLayer.button1"]=CBAPressed,
                  ["ButtonLayer.button2"]=CBBPressed,
                  ["ButtonLayer.button3"]=CBCPressed    
                }
                
local function CBAReleased()
  print("A Released")
end

local function CBBReleased()
  print("B Released")
end

local function CBCReleased()
  print("C Released")
end 
               
local releaseCB = {
                    ["ButtonLayer.button1"]=CBAReleased,
                    ["ButtonLayer.button2"]=CBBReleased,
                    ["ButtonLayer.button3"]=CBCReleased    
                  }

---This function is responsible for updating the 'A | B | C' label
local function updateLabel()
  --Sort the keys so they appear in order A | B | C
  local keys = {}
  for c,s in pairs(touches) do
    table.insert(keys, c)
  end
  table.sort(keys)

  local activeButtons = {}
  for _,key in ipairs(keys) do
    if(states[key] == STATE_PRESSED) then
      table.insert(activeButtons, key)
    end
  end
  
  local output = ""
  local numActive = #activeButtons
  if(numActive >= 1) then
    local label = labels[activeButtons[1]]
    output = label
  end
  
  if(numActive >= 2) then
    local label = labels[activeButtons[2]]
    output = string.format("%s | %s", output, label)
  end
  
  if(numActive >= 3) then
    local label = labels[activeButtons[3]]
    output = string.format("%s | %s", output, label)
  end
  gre.set_value("ButtonLayer.state.text",output)
end

---Real Press
local function ControlPressed(control)
  gre.set_value(control .. ".image", "images/MultiButtonDown.png")

  --In this example, we use pressCB table to hold callback funtions for each control,
  --to be executed when a 'real' press happens
  local cb = pressCB[control]
  if(cb ~= nil) then
    cb()
  end
  
  states[control] = STATE_PRESSED
  updateLabel()
end

---No more touch points on control, might be a 'real' release
local function ControlReleased(control)
  gre.set_value(control .. ".image", "images/MultiButton.png")
  
  local state = states[control]
  if(state == STATE_DEBOUNCING) then
    --This was not a real realease since the control wasn't actually pressed
    local timer = debounceTimers[control]
    if(timer ~= nil) then
      gre.timer_clear_timeout(timer)
    end
  elseif(state == STATE_PRESSED) then
    --This button was 'really' pressed.  Trigger a 'real' release.
    local cb = releaseCB[control]
    if(cb ~= nil) then
      cb()
    end
  end
  
  states[control] = STATE_RELEASED
  updateLabel()
end 

local function addId(t, id)
  for _,i in pairs(t) do
    if(i == id) then
      --It's already in the list
      return
    end
  end
  
  table.insert(t, id)
end

local function remId(t, id)
  for n,i in pairs(t) do
    if(i == id) then
      table.remove(t,n)
      return
    end
  end
end

--- Each control has a list of id's for the active touch points.
--  When the list is emptied, then the ControlRelease function is called.
--- @param control, the context control
--- @param isAdded, true for press and inbound, false for release and outbound
local function updateTouchPoints(control, isAdded, id)
  if(isAdded) then
    addId(touches[control], id)
  else
    remId(touches[control], id)
  end
  
  if(#touches[control] == 0) then
    ControlReleased(control)
  end
end

--- This function will start a 250ms timer.  If the user removes their
--  finger from the button within 250ms, the press will be discarded.
--  if the user keeps their fingers in the control for 250ms then
--  a 'real' press will be triggered by the ControlPressed function.
--- @param gre#context mapargs
function CBPressDebounce(mapargs)
  local control = mapargs.context_control 
  
  if(states[control] == STATE_RELEASED) then
    states[control] = STATE_DEBOUNCING
    --This function will be executed if the input is a 'real' press
    local f = function()
                  debounceTimers[control] = nil
                  --'real press'
                  ControlPressed(control)
              end
    
    local timer = gre.timer_set_timeout(f, 250)
    debounceTimers[control] = timer
  end
  
  local event_data = mapargs.context_event_data
  local id = event_data.id
  updateTouchPoints(control, true, id)
end

--- If the control's touch point count has reached 0, then this will trigger
--  the realease behavior which will cancel the debounce timer(if one exists) and will
--  set the button image back to it's up state
--- @param gre#context mapargs
function CBRelease(mapargs)
  local event_data = mapargs.context_event_data
  local id = event_data.id
  local control = mapargs.context_control
  updateTouchPoints(control, false, id)
end

--- This function will trigger release behavior if the control's
--  touch point count has reached 0
--- @param gre#context mapargs
function CBOutbound(mapargs)
  local event_data = mapargs.context_event_data
  --Ingnore outbound unless a button is pressed
  if(event_data.button == 0) then
    return
  end

  local id = event_data.id
  local control = mapargs.context_control 
  updateTouchPoints(control, false, id)
end

--- This function will not trigger any press behavior
--  but it will upate the control's touch point count.
--- @param gre#context mapargs
function CBInbound(mapargs)
  local event_data = mapargs.context_event_data
  
  --Ingnore inbound unless a button is pressed
  if(event_data.button == 0) then
    return
  end
  
  local id = event_data.id
  local control = mapargs.context_control
  updateTouchPoints(control, true, id)
end

