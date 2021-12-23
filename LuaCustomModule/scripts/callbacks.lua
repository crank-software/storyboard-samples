--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

--
-- This configures the module path so that it will look in the 
-- project's scripts directory in an OS and CPU specific location
--
local info = gre.env({ "target_cpu","target_os" })
local moddir = string.format("%s/%s-%s", gre.SCRIPT_ROOT, info.target_os, info.target_cpu)

package.cpath = string.format("%s/?.so;%s", moddir, package.cpath)

-- This statement is what will cause our binary module to be loaded
require("sbmodule")

--
-- This callback invokes our module's function in two different manners:
-- - Without an argument our hello() call returns no greeting
-- - With an argument our hello() returns a string with a greeting
--
-- We print both responses to the console and also populate the UI
-- with the returned values.
--
function cb_invokeModule(mapargs) 
	local data = {}
	local ret, msg
	
	ret = sbmodule.hello()
	msg = "hello() =\n[" .. tostring(ret) .. "]"
  print(msg)
	data["MainLayer.greet1.text"] = msg
	
	ret = sbmodule.hello("Storyboard")
	msg = "hello(\"Storyboard\") =\n[" .. tostring(ret) .. "]"
	print(msg)
	data["MainLayer.greet2.text"] = msg

	gre.set_data(data)
end
