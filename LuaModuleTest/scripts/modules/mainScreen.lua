---
-- @module mainScreen
--  This class contains functions to underpin the mainScreen funtionality. 
mainScreen = {}
mainScreen.__index = mainScreen

print("loaded module mainScreen.lua")

-- Create a new module instance and update metatable 
function mainScreen.new(subsystem)
  local self = setmetatable({}, mainScreen)
  self:init(subsystem)
  return self
end 

-- Perform any dynamic screen specific configuration here
function mainScreen:init(mapargs) 

print("mainScreen:init()")

end

-- Perform any dynamic screen specific tear-down here
function mainScreen:exit(mapargs) 

print("mainScreen:exit()" )

end

-- Callback for 'Press' button to be triggered by gre.press action
function mainScreen:CBHandlePress(mapargs) 

local data={}
data["mainLayer.status_text.text"] = "Activated"
gre.set_data(data)

end


-- Callback for 'Press' button to be triggered by gre.release and gre.outbound actions
--- @param gre#context mapargs
function mainScreen:CBHandleRelease(mapargs) 

local data={}
data["mainLayer.status_text.text"] = "Deactivated"
gre.set_data(data)

end
