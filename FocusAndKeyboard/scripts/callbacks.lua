
local path
local previous_control_focused
local green = gre.rgb(0,255,0)
local black = gre.rgb(0,0,0)

function CBgotFocus(mapargs) 
  local screen = mapargs.context_screen
  local control = mapargs.context_control
  local row = mapargs.context_row
  local column = mapargs.context_col
  
  path = tostring(screen.."."..control.."."..row.."."..column)

end

function CBselect(mapargs) 
  local data = {}
  data["Layer.output.text"] = path
  gre.set_data(data)
end

-- Handle keyboard inputs
function CBkeypress(mapargs)
  local key = mapargs.context_event_data.key
  
  --left=37, right=39, enter=13
  if (key == 37) then
    --if the left arrow is pressed, travel to the previous index
    print('left arrow')
    gre.send_event('previous_focus_index')
  elseif (key == 39) then
    --if the right arrow is pressed, travel to the next index
    print('right arrow')
    gre.send_event('next_focus_index')
  elseif (key == 13) then
    --if enter is pressed, populate the text box with the selected control
    gre.set_value("Layer2.message.text", "You've selected " .. previous_control_focused)
  end
  
end

--Handle set the control which just got focus to be highlighted
function CBcontrolgotfocus(mapargs)
  local focused_control = mapargs.context_control
  
  --set the color of the control previously in focus to be black
  if(previous_control_focused ~= nil) then
    gre.set_value(string.format('%s.color',previous_control_focused), black)
  end
  
  --set the color of the control now in focus to be green
  gre.set_value(string.format('%s.color', focused_control), green)
  previous_control_focused = focused_control
  
  print('now in focus: ' .. focused_control)
end

--- @param gre#context mapargs
function cb_next_screen(mapargs)
  if (mapargs.context_screen == 'Screen') then
    gre.set_value('target_screen', 'Screen2')
  else
    gre.set_value('target_screen', 'Screen')
    gre.set_value('Layer2.message.text', '')
  end

  gre.send_event('screen_navigate')
end
