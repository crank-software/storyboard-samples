---
-- @module secondScreen
--  This class contains functions to underpin the secondScreen funtionality. 
secondScreen = {}
secondScreen.__index = secondScreen

local screen_text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

print("loaded module secondScreen.lua")

-- Create a new module instance and update metatable 
function secondScreen.new(subsystem)
  local self = setmetatable({}, secondScreen)
  self:init(subsystem)
  return self
end 

-- Perform any dynamic screen configuration here
function secondScreen:init(mapargs) 

  print("secondScreen:init()")
  
  local data = {}
  
  data["navLayer.content_text.text"] = screen_text
  gre.set_data(data)

end

-- Perform any dynamic screen specific tear-down here
function secondScreen:exit(mapargs) 

  print("secondScreen:exit()")
  screen_text = nil

end
