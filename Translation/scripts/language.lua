--[[
Copyright 2016 Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]

local csv = require "csv"

--[[
This function loads the data from from the csv file passed in
and returns a table that can be used with gre.data_set()

In this example we read the cvs file in each time but it could be cached for performance

If multiple languages are included in one csv file, col_num must be specified,
If no column number is passed to the function, the column number will default to 2.
]]
function LoadLanguage(fname, col_num)
	local data = {}
	local column
  
  if(col_num == nil)then
    column = 2
  else
    column = col_num
  end

	local f = csv.open(gre.SCRIPT_ROOT.."/../translations/"..fname)
  for fields in f:lines() do
    for i, v in ipairs(fields) do 
      if(i == 1)then
        k = v
      elseif(i == column)then  
        data[k]=v
      end
    end
  end
	
	return data
end

-- This func sets the data from the file passed in as "lang_file"
function CBLoadLanguage(mapargs)
	local lang_data = {}

	lang_data = LoadLanguage(mapargs.lang_file)
	gre.set_data(lang_data)
end
