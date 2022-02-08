---
-- @module callbacks
--  This class contains functions to underpin the general callbacks funtionality. 
--  It is intended to be an application global utility class
--  
callbacks = {}
callbacks.__index = callbacks

print("loaded callbacks.lua")
-- Load sub module on start-up
--require("modules/mainScreen")
--require("modules/secondScreen")
--print("Lua memory used:"..collectgarbage("count").."KB")

-- Create a new module instance and update metatable 
function callbacks.new(subsystem)
  local self = setmetatable({}, callbacks)
  self:init(subsystem)
  return self
end

-- Perform any dynamic module specific configuration here
function callbacks:init(mapargs) 

  print("callbacks:init()")

end

--- @param gre#context mapargs
function callbacks:CBHandleScreenShow(mapargs) 

  -- Load sub module on demand
  -- NOTE: this context strategy requires that the lua module for the screen
  -- is named the same as the screen
  local module_name = "modules." .. mapargs.context_screen 
  require( module_name )
  
  -- Invoke loaded screen module specific initialisation function
  local module = _G[mapargs.context_screen]
  module:init(mapargs)
  --print("Lua memory used:"..collectgarbage("count").."KB")
end

--- @param gre#context mapargs
function callbacks:CBHandleScreenHide(mapargs) 

  -- Unload sub module on exit
  -- NOTE: this context strategy requires that the lua module for the screen
  -- is named the same as the screen
  local module_name = "modules." .. mapargs.context_screen 
  local module = _G[mapargs.context_screen]
  print("unloading module : " .. module_name )
  
  -- Invoke loaded screen module specific tear-down function
  module:exit()
  
  -- Release and clean-up sub module on demand
  package.loaded[ module_name ] = nil
  collectgarbage("collect") --if you aren't using the gc option at engine level
  --print("Lua memory used:"..collectgarbage("count").."KB")
end
