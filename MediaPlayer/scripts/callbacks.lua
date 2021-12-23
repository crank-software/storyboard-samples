--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local gVolume = 50
local gCurTime = 0
local gTotalTime = 32000
local mute = false

function CBVolume(mapargs)
  local change = mapargs.vol
  
  if (mute == false) then
    if (change == "down") then
      if gVolume > 0 then
        gVolume = gVolume - 10
      end
  
    elseif (change == "up") then
      if (gVolume < 100)then
        gVolume = gVolume + 10
      end
    end
  end
  
  if (change == "mute") then
    if (mute == false) then
      gVolume = 0
      gre.set_value("media_control_layer.vol.state", "images/mute_up1.png")
      gre.set_value("media_control_layer.vAlpha", 100)
      mute = true
    else 
      gVolume = 50
      gre.set_value("media_control_layer.vol.state", "images/vol_up1.png")
      gre.set_value("media_control_layer.vAlpha", 255)
      mute = false
    end
  end
  gre.set_value("media_control_layer.volume", gVolume)
end

function CBUpdateCurVideoTime(mapargs)

  local event_data = mapargs.context_event_data
  gCurTime = event_data["time_elapsed"]
    
  CBDuration()
end

function CBSeekForward(mapargs)
  local data = {}
  if (gCurTime < 27000) then
    data["media_control_layer.fwd.seek_forward"] = gCurTime + 5000
    gCurTime = gCurTime + 5000
    gre.set_data(data)
  else
    data["media_control_layer.fwd.seek_forward"] = 32000
    gCurTime = 32000
    gre.set_data(data)
    
    gre.set_value("media_control_layer.stopped", 1)
  end
  
end

function CBSeekBackward(mapargs)
  local data = {}
  if (gCurTime > 5000) then
    data["media_control_layer.back.seek_back"] = gCurTime - 5000
    gCurTime = gCurTime - 5000
    gre.set_data(data)
  
  else
    data["media_control_layer.back.seek_back"] = 0
    gCurTime = 0
    gre.set_data(data)
  end
  
end

function CBDuration()
  if (gCurTime < 33000) then
    local data = {}
    local secsDur = gTotalTime / 1000
    local secsPos = gCurTime / 1000
    local progBar = secsDur / secsPos
    
    local minsDur = secsDur / 60
    secsDur = secsDur % 60
    local duration = (string.format("%1d", minsDur))..":"..(string.format("%02d", secsDur))
    
    local minsPos = secsPos / 60
    secsPos = secsPos % 60
    local position = (string.format("%1d", minsPos))..":"..(string.format("%02d", secsPos))
    
    data["media_control_layer.time_total.time"] = duration
    data["media_control_layer.time.time"] = position
    data["media_control_layer.dur.grd_width"] = 795 / progBar
    gre.set_data(data)
    
    if (gCurTime < 32000) then gre.set_value("media_control_layer.stopped", 0) end
  end
end

function CBScrub(mapargs)
  if (gCurTime < 32000) then
    local press = gre.get_value("media_control_layer.scrub")
    if(press == 1) then
      local data = {}
      local ev_data = mapargs.context_event_data
      local touch_x = ev_data["x"] - gre.get_value("media_control_layer.scrub_touch.grd_x")
     
      data["media_control_layer.dur.grd_width"] = touch_x
      gre.set_data(data)
      
      gCurTime = (touch_x / 795) * gTotalTime
      gCurTime = math.floor(gCurTime / 1000) * 1000
      
      gre.set_value("media_control_layer.scrub_touch.scrub_time", gCurTime)
    end
  end
end

function CBMediaPlay(mapargs)
  local data = {}
  local stopped = gre.get_value("media_control_layer.stopped")
  if (stopped == 1) then
    gre.send_event("MediaPlay")
    gre.send_event("MediaSeek")
  else
    gre.send_event("MediaResume")
  end
end

