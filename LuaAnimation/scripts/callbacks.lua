local clone_number = 1
local pause = "false"
local played = "false"
local progress


-- Callback triggered when Start control is pressed
-- Creates and plays animation with 3 steps: circle progress, bar progress, and text percentages
-- If pressed again, animation will reset and continue playing
function CBStart(mapargs) 
  local data = {}
  
  --Resets Pause Button to its starting state
  pause = "false"
  gre.set_value("LuaAnimation_layer.Pause.image", "images/pause.png" )
  
  -- If animation exists already (or is curently playing), it will clear and restart
  if (played == "true") then gre.animation_destroy(progress) end
  
  -- Create an animation of 60 frames, with auto destroy enabled
  progress = gre.animation_create(60,1)
  
  -- Circle Progress animates from an arc angle of 0 - 360 in 5000ms
  data["rate"] = "linear"
  data["duration"] = 5000
  data["from"] = 0
  data["to"] = 360
  data["key"] = "LuaAnimation_layer.circleEndAngle"
  gre.animation_add_step(progress, data)
  
  -- Bar Progress animates from a width of 0 - 200 in 5000ms(using same rate & duration as above step)
  data["from"] = 0
  data["to"] = 200
  data["key"] = "LuaAnimation_layer.barWidth"
  gre.animation_add_step(progress, data)
  
  -- Animates Percentage Text from 0 - 100 % by 5's, numbers update at 50ms intervals
  local n = 0
  while (n < 105) do
    data["duration"] = 0
    data["offset"] = 50 * n
    data["to"] = n.."%"
    data["key"] = "LuaAnimation_layer.percentage"
    gre.animation_add_step(progress, data)
    n = n + 5
  end
  
  -- Play
  gre.animation_trigger(progress)
  played = "true"
  
end

-- Callback triggered when Pause control is pressed
-- Pauses the animation while it is playing. Press a second time to Resume
-- If animation has completed or hasn't started, Pause is disabled
function CBPause(mapargs)
  
  --Check to see if animation exists and has stopped playing
  if (gre.get_value("LuaAnimation_layer.percentage") ~= "100%") and (played == "true") then
  
    -- Pauses animation and sets button image to Resume Icon
    if (pause == "false") then
      gre.animation_pause(progress)
      pause = "true"
      gre.set_value("LuaAnimation_layer.Pause.image", "images/resume.png" )
    
    -- Resumes animation and sets button image to Pause Icon
    else
      gre.animation_resume(progress)
      pause = "false"
      gre.set_value("LuaAnimation_layer.Pause.image", "images/pause.png" )
    end
  end
end

-- Callback triggered when Clone control is pressed
-- Clones Circle and Bar groups, changes color and changes x values
function CBClone(mapargs)
  local data = {}
  
  -- Clone the controls
  if (clone_number < 2) then
    
    -- Change image render of Clone Switch to green
    gre.set_value("LuaAnimation_layer.Clone.image", "images/cloneSwitch_green.png")
    
    -- Clone both groups, rename them, and set their x values
    data["x"] = 520
    gre.clone_control("LuaAnimation_layer.CircleProgress_Group", "CircleProgress_2_Group", "LuaAnimation_layer", data)
    gre.clone_control("LuaAnimation_layer.BarProgress_Group", "BarProgress_2_Group", "LuaAnimation_layer", data)
    
    -- Change color variables of new groups to green
    data["LuaAnimation_layer.CircleProgress_2_Group.color"] = 768907
    data["LuaAnimation_layer.BarProgress_2_Group.color"] = 768907
    
    -- Change x values of old groups
    data["LuaAnimation_layer.CircleProgress_Group.grd_x"] = 240
    data["LuaAnimation_layer.BarProgress_Group.grd_x"] = 240
    
    gre.set_data(data)
    clone_number = clone_number + 1
  
  else 
    -- Delete green clones
    gre.delete_control("LuaAnimation_layer.CircleProgress_2_Group")
    gre.delete_control("LuaAnimation_layer.BarProgress_2_Group")
    
    -- Recenter Blue Clones
    data["LuaAnimation_layer.CircleProgress_Group.grd_x"] = 380
    data["LuaAnimation_layer.BarProgress_Group.grd_x"] = 380
    gre.set_data(data)
    gre.set_value("LuaAnimation_layer.Clone.image", "images/cloneSwitch_blue.png")
    
    clone_number = 1
  end
  
end
