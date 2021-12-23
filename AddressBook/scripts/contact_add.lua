--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

-- Global Variables
KEYCODE_BACKSPACE = 8

-- Variables
local gBlankEntry = {
		first_name = "",
		last_name = "",
		address = "",
		email = "",
		office = "",
		mobile = "",
		home = "",
		image = "images/profile_pic.png",
		fav = 0
}

local gEntryOrder = {
	{
		display = "FIRST NAME",
		var = "InputLayer.FirstName.text",
		name = "first_name",
		y = 14
	},
	{
		display = "LAST NAME",
		var = "InputLayer.LastName.text",
		name = "last_name",
		y = 34	
	},
	{
		display = "HOME",
		var = "InputLayer.HomeEntry.text",
		name = "home",
		y = 53
	},
	{
		display = "MOBILE",
		var = "InputLayer.MobileEntry.text",
		name = "mobile",
		y = 73
	},
	{
		display = "OFFICE",
		var = "InputLayer.OfficeEntry.text",
		name = "office",
		y = 93
	},
	{
		display = "EMAIL",
		var = "InputLayer.EmailEntry.text",
		name = "email",
		y = 113
	},
	{
		display = "ADDRESS",
		var = "InputLayer.AddressEntry.text",
		name = "address",
		y = 133
	},
}
local gTempEntry = {}
local gCurrentEntry = {}
local gContactIndex = 0
local gEntryIndex = 1
local EDIT_LABEL = "InputLayer.FieldTitle.text"
local gEditingContact = false


function LoadContact(contact, index)
    gCurrentEntry = contact
    gContactIndex = index
end

local function LoadEntry(index)
    local data = {}
    data[EDIT_LABEL] = gEntryOrder[index].display
    data["InputLayer.SelectionArrow.grd_y"] = gEntryOrder[index].y 
    data["InputLayer.InputField.text"] = gTempEntry[gEntryOrder[index].name]
    gre.set_data(data)
end

function CBPreviousEntry(mapargs)
    local data = {}
    data[gEntryOrder[gEntryIndex].var] = gTempEntry[gEntryOrder[gEntryIndex].name]
    gre.set_data(data)

    gEntryIndex = gEntryIndex - 1
    if (gEntryIndex < 1) then
        gEntryIndex = 1
    end
    LoadEntry(gEntryIndex)
end

function CBNextEntry(mapargs)
    local data = {}
    data[gEntryOrder[gEntryIndex].var] = gTempEntry[gEntryOrder[gEntryIndex].name]
    gre.set_data(data)
    gEntryIndex = gEntryIndex + 1
    if (gEntryIndex > table.maxn(gEntryOrder)) then
        gEntryIndex = table.maxn(gEntryOrder)
    end
    LoadEntry(gEntryIndex)
end

function CBEntrySubmit(mapargs)
    --if we're editing a contact, not making a new one, then we must delete the previous contact entry.
    if (gEditingContact == true) then
      table.remove(gAddressBook, gContactIndex)
    end
    gCurrentEntry = ShallowCopy(gTempEntry)
    gTempEntry = ShallowCopy(gBlankEntry)
    table.insert(gAddressBook, gCurrentEntry)
    CBLoadList()
end

--- @param gre#context mapargs
function CBCancelEntry(mapargs) 
    gTempEntry = ShallowCopy(gBlankEntry)
    if (gContactIndex == 0) then
      gre.set_value("screenName", "AddressBookScreen")
    else
      gre.set_value("screenName", "ContactScreen")
    end
    
    if (gEditingContact == true) then
      local data = {}
      for i=1, table.maxn(gEntryOrder) do
        local variable = gEntryOrder[i].name
        data[gEntryOrder[i].var] = gCurrentEntry[variable]
      end
      gre.set_data(data)
    end
    
    gre.send_event("ScreenTransition")
end

function ShallowCopy(orig)
    local origType = type(orig)
    local copy
    if (origType == 'table') then
        copy = {}
        for origKey, origValue in pairs(orig) do
            copy[origKey] = origValue
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function CBSetupNewEntry(mapargs)
    gEditingContact = false
    gCurrentEntry = ShallowCopy(gBlankEntry)
    gTempEntry = ShallowCopy(gBlankEntry)
    
    local data = {}
	
    for i=1, table.maxn(gEntryOrder) do
        data[gEntryOrder[i].var] = ""
    end
    gre.set_data(data)
	
    gEntryIndex = 1
    LoadEntry(gEntryIndex)
end

function CBSetupEditEntry(mapargs)
    gEditingContact = true
    gTempEntry = ShallowCopy(gCurrentEntry)
    
    local data = {}
    
    for i=1, table.maxn(gEntryOrder) do
        local variable = gEntryOrder[i].name
        data[gEntryOrder[i].var] = gCurrentEntry[variable]
    end
    gre.set_data(data)
  
    gEntryIndex = 1
    LoadEntry(gEntryIndex)
end

function CBInputKeyEvent(mapargs)
    local data = {}
    local key = mapargs.context_control..".text"
    data = gre.get_data(key)
    local evData = mapargs.context_event_data
    
    if (evData.code == nil) then
      return
    end
    
    if (evData.code == KEYCODE_BACKSPACE) then
        -- backspace key
        local len = string.len(data[key])
        len = len - 1

        local new = string.format("%s", string.sub(data[key],1,len))
        data[key] = new
        gre.set_data(data)
    elseif (evData.code == 13) then
        -- enter key
        data[gEntryOrder[gEntryIndex].var] = gTempEntry[gEntryOrder[gEntryIndex].name]
        gre.set_data(data)
        gTempEntry[gEntryOrder[gEntryIndex].name] = data[key]
        CBNextEntry()
    else	
        data[key] = data[key]..string.char(evData.code)
        gre.set_data(data)
    end
	
    if (mapargs.context_event_data.code ~= 13) then
        -- not the enter key
        gTempEntry[gEntryOrder[gEntryIndex].name] = data[key]
    end
end
