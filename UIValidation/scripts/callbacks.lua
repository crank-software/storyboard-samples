local SCREENCAP_FMT = ".png" -- can be one of .png, .bmp, .tga
local TEST_DIR = gre.APP_ROOT.."/screenshots/"

local counter_buttons = {
  "Buttons.ClickedNever",
  "Buttons.ClickedOnce",
  "Buttons.ClickedN"
}

-- Callback to drive UI
--- @param gre#context mapargs
function CBButtonClick(mapargs)
  local counter = gre.get_value(mapargs.active_context..".clicks") + 1
  gre.set_value(mapargs.active_context..".clicks", counter)
  gre.set_value(mapargs.active_context..".text", tostring(counter))
end

--
-- Testing
--

local tests_completed = 0
local tests = {}

tests["ClickOnce"] = function() 
  SimulateClick(counter_buttons[2])
  gre.send_event_target("control_capture", counter_buttons[2])
end

tests["ClickN"] = function()
  local nClicks = 7
  for _=1,nClicks do
    SimulateClick(counter_buttons[3])
  end
  gre.send_event_target("control_capture", counter_buttons[3])
end

tests["ClickNone"] = function()
  gre.send_event_target("control_capture", counter_buttons[1])
end

local n_tests = 0
for _,_ in pairs(tests) do
  n_tests = n_tests + 1
end

local control_listeners = {}
local screencap_listener
local cleanup_listener

-- Cause an artificial gre.press event on the model object pointed to by fqn
function SimulateClick(fqn)
  local fqn_data = gre.get_data(fqn..".grd_x", fqn..".grd_y")
  gre.touch(fqn_data[fqn..".grd_x"], fqn_data[fqn..".grd_y"])
end

-- Callback to take a screencapture of a model object
--- @param gre#context mapargs
function CBControlCapture(mapargs)
  local screencap = {["name"] = "gre.screencapture.fqn", ["format"] = "1s0 fqn 1s0 filename", ["data"] = {}}
  screencap.data = {["fqn"] = nil, ["filename"] = nil}
  screencap.data.fqn = mapargs.active_context
  screencap.data.filename = TEST_DIR..mapargs.active_context..SCREENCAP_FMT
  gre.log(gre.LOG_ALWAYS, "[CAPT] "..screencap.data.filename)
  gre.send_event(screencap)
end

-- Callback to set up and run tests
--- @param gre#context mapargs
function CBRunTests(mapargs)
  for _,button in pairs(counter_buttons) do
    control_listeners[#control_listeners + 1] = gre.add_event_listener("control_capture", button, CBControlCapture)
  end
    
  -- Counter to ensure we don't exit until all captures have completed
  screencap_listener = gre.add_event_listener("gre.screendump.complete", "", function()
    tests_completed = tests_completed + 1
    if tests_completed == n_tests then
      gre.send_event("test_cleanup")
    end
  end)
  
  -- Unbind event listeners before exit
  cleanup_listener = gre.add_event_listener("test_cleanup", "", function()
    for _,l in pairs(control_listeners) do
      gre.remove_event_listener(l)
    end
    if screencap_listener then
      gre.remove_event_listener(screencap_listener)
    end
    gre.remove_event_listener(cleanup_listener)
    gre.send_event("gre.quit")
  end)
  
  -- Manipulate UI state with simulated touches
  for k,v in pairs(tests) do
    gre.log(gre.LOG_ALWAYS, "[TEST] "..k)
    v()
  end
end


