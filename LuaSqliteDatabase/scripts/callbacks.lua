--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

 -- This is where we do all of the Database interaction and initialization.
 -- we connect, query, and update our target database table via the sqlite3 plugin
local myenv = gre.env({ "target_os", "target_cpu" })
if(myenv.target_os=="win32" or myenv.target_os=="windows")then
  package.cpath = gre.SCRIPT_ROOT .. "\\" .. myenv.target_os .. "-" .. myenv.target_cpu .."\\luasql_sqlite3.dll;" .. package.cpath 
else
  package.cpath = gre.SCRIPT_ROOT .. "/" .. myenv.target_os .. "-" .. myenv.target_cpu .."/luasql_sqlite3.so;" .. package.cpath 
end

luasql = require("luasql_sqlite3")

local database = "usersettings.sqlite"
local env = assert(luasql.sqlite3())
local db = assert(env:connect(gre.SCRIPT_ROOT .. "/"..database, "Failed to connect to database"))

local users = {}
local currentUser = 1

---Pull the currently shown Data from the screen and update the database
local function SaveCurrent()
	local data = gre.get_data("controls_layer.switch.value", "controls_layer.stepper.value", "controls_layer.slider.value", "controls_layer.toggle.value")
	local control1 = data["controls_layer.switch.value"]
	local control2 = data["controls_layer.stepper.value"]
	local control3 = data["controls_layer.slider.value"]
	local control4 = data["controls_layer.toggle.value"]
	local statement = string.format("UPDATE users SET control1 = %s, control2 = %s, control3 = '%.1f', control4 = %s WHERE `id` = %s;", control1, control2, control3, control4, currentUser)
	local update = db:execute(statement)
end

---We are only storing names and user IDs locally. Get the data for this particular user
---Get the control data for the user and populate our UI with their values
local function SwitchUser()
	local statement = string.format("SELECT * from users where id=%s", users[currentUser].id)
	local cur = db:execute(statement)
	local row = cur:fetch({}, "a")
	-- query the users control data and set it to the UI
	local data = {}
	data["username_layer.username.text"] = users[currentUser].username
	data["controls_layer.switch.value"] = row.control1
	data["controls_layer.stepper.value"] = row.control2
	data["controls_layer.slider.value"] = row.control3
	data["controls_layer.toggle.value"] = row.control4
	gre.set_data(data)
end


--- On init we pull all users down to a local table so we don't have to keep querying the Database.
--- For large databses this is not a good idea. Notice that this is only the usernames and IDs.
function CBInit(mapargs) 
	local cur = db:execute(string.format("SELECT id,username from users"))
	local row = cur:fetch ({}, "a")

	-- Iterate through the results and populate the lua table
	while row do 
		local data={}
		data["username"] = row.username
		data["id"]=row.id
		table.insert(users,data)
		--We're done with this row of data so switch with the next
		row = cur:fetch({}, "a")
	end
	SwitchUser()
end


function CBNextUser(mapargs)
	SaveCurrent()
	currentUser = currentUser + 1
	if (currentUser>#users) then
		currentUser = 1
	end
	SwitchUser()	
end


function CBPrevUser(mapargs)
	SaveCurrent() 
	currentUser = currentUser-1
	if (currentUser==0) then
		currentUser = #users
	end
	SwitchUser()	
end