--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--


local gLuaTracingEnabled = false


-- This callback dumps out all of the context that is available
-- to a Lua callback function.  It also shows the use of the 
-- table dumping utility function.
function CBDumpContext(mapargs)
	print("--- LUA DUMP CONTEXT ---")
  print(" Triggered by event : " .. mapargs.context_event)
  print(" Event was targeting : " .. mapargs.active_context)
    
  print("\nThe callback arguments contain:")    
  for k,v in pairs(mapargs) do
      print("  Arg key = " .. tostring(k))
      print("    value = " .. tostring(v)) 
      print("     type = " .. type(v))
  end
    
  print("\nThe context_event_data table contains:")
  for k,v in pairs(mapargs.context_event_data) do
	print(string.format("  [%s] = [%s]", tostring(k), tostring(v)))
  end
  
  -- Alternatively you can dump all of the arguments as a table
  print("\n--- Argument Table ---")
  DumpTable(mapargs)
end 

-- This callback demonstrates how you can extract the event name
-- and use that to adjust the operation of your callback.
function CBChangeText(mapargs)
  local evt = mapargs.context_event
  local data = {}
  
  if(evt == "gre.press") then
    data["text"] = "Button Pressed"
  elseif(evt == "gre.release") then
    data["text"] = "Button Released"
  end
  
  gre.set_data(data)
end

-- This callback demonstrates how to pass arguments to a Lua function
-- and how to dynamically resize a table control and fill in the table
-- cells with dynamically assigned content.
function CBFillTable(mapargs)
  -- Extract the new row and colums count from the callback arguments  
  local numRows = tonumber(mapargs.num_rows)
  local numCols = tonumber(mapargs.num_cols)
  
  -- This variable specifies the path to our table control
  local aTable = "example_layer.table_control"
  
  -- If we have 0 rows or 0 columns, then hide the table
  -- We can use the Lua notation { key = value } as shorthand for single entry Lua tables
  if(numRows == 0 or numCols == 0) then
    gre.set_control_attrs(aTable, { hidden = 1 })
    return
  end
  
  -- Set the new row column values
  local data = {}
  data["rows"] = numRows
  data["cols"] = numCols
  data["yoffset"] = 0 -- Reset the display origin 
  gre.set_table_attrs(aTable, data)
  gre.set_control_attrs(aTable, { hidden = 0 })
  
  -- For each of those row/col values set some text
  -- The cell variables are post-fixed with .<row>.<col>
  data = {}
  for r=1,numRows do
    for c=1,numCols do
      local key = string.format("example_layer.table_control.text.%d.%d", r, c)
      data[key] = string.format("R:%d of %d\nC:%d of %d", r, numRows, c, numCols)
    end
  end
   
  gre.set_data(data)
end

-- This callback toggles the state of Lua function tracing
-- and demonstrates how a global lua variable can be used to
-- track state information.
function CBTraceLua(mapargs)
  -- Toggle the tracing based on the global variable state
  gLuaTracingEnabled = not gLuaTracingEnabled
  
  -- Update the UI display to act as a toggle
  local data = {}
  if(gLuaTracingEnabled) then
      data["example_layer.trace_button.text"] = "Disable Lua Callback Tracing"
      data["example_layer.trace_button.color"] = 0x1b455f   --Hex RGB color for dark blue
  else
      data["example_layer.trace_button.text"] = "Enable Lua Callback Tracing"
      data["example_layer.trace_button.color"] = 0xefefef   --Hex RGB color for off white
  end
  gre.set_data(data);

  TraceControl(gLuaTracingEnabled)
end
