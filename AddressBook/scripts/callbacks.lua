--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

require "contacts"

-- Variables
local gPreviousIndex = 0
local gIndex = 0


--- @param gre#context mapargs
function CBInit(mapargs) 
    if (gre.env("target_os") == "macos") then
        KEYCODE_BACKSPACE = 127
    else
        KEYCODE_BACKSPACE = 8
    end
end

-- load the initial list of contacts into the ContactListTable
function CBLoadList(mapargs) 
    local data = {}

    table.sort(gAddressBook, 
        function(e1, e2)
            return e1.last_name < e2.last_name
        end
    )

    for i=1, table.maxn(gAddressBook) do
        data["TableLayer.ContactListTable.txt."..i..".1"] = gAddressBook[i].first_name.." "..gAddressBook[i].last_name
        data["TableLayer.ContactListTable.img."..i..".1"] = "images/cell_1.png"
        if (gAddressBook[i].fav == 1)  then
            data["TableLayer.ContactListTable.fav_alpha."..i..".1"] = 255
        else
            data["TableLayer.ContactListTable.fav_alpha."..i..".1"] = 0
        end
    end
    gre.set_data(data)
	  
    data = {}
    data["rows"] = table.maxn(gAddressBook) 
    if (data["rows"] == 0) then
      data["hidden"] = 1
    else
      data["hidden"] = 0
    end
    gre.set_table_attrs("TableLayer.ContactListTable", data)
    CBInitScroll()
end

-- When the user selects a contact from the list
function CBContactPress(mapargs) 
    local data = {}
	
    if (mapargs.context_screen == "AddressBookScreen") then
        gre.send_event("CONTACT_SCREEN")
    end
	
	 -- the row that was pressed in the table
    gIndex = mapargs.context_row
	
    data["TableLayer.ContactListTable.img."..gPreviousIndex..".1"] = "images/cell_1.png"
    data["TableLayer.ContactListTable.img."..gIndex..".1"] = "images/cell_highlight-2.png"
    gPreviousIndex = gIndex
	
    data["ContactSelectLayer.ContactName.text"] = gAddressBook[gIndex].first_name.." "..gAddressBook[gIndex].last_name
    data["ContactSelectLayer.HomePhone.text"] = gAddressBook[gIndex].home
    data["ContactSelectLayer.MobilePhone.text"] = gAddressBook[gIndex].mobile
    data["ContactSelectLayer.OfficePhone.text"] = gAddressBook[gIndex].office
    data["ContactSelectLayer.Email.text"] = gAddressBook[gIndex].email
    data["ContactSelectLayer.Address.text"] = gAddressBook[gIndex].address
    data["ContactSelectLayer.ProfilePicture.img"] = gAddressBook[gIndex].image
    LoadContact(gAddressBook[gIndex], gIndex)
    gre.set_data(data)
end

function CBFavToggle(mapargs)
    local data = {}
    if (gAddressBook[gIndex].fav == 0)  then
        gAddressBook[gIndex].fav = 1
        data["TableLayer.ContactListTable.fav_alpha."..gIndex..".1"] = 255
    else
        gAddressBook[gIndex].fav = 0
        data["TableLayer.ContactListTable.fav_alpha."..gIndex..".1"] = 0
    end
    gre.set_data(data)	
end

function CBRemoveContact(mapargs)
    local data = {}
    table.remove(gAddressBook, gIndex)
    CBLoadList()
end

function CBDeletePress(mapargs) 
    local data = {}
    data["DeleteContactLayer.DeleteName.text"] = gAddressBook[gIndex].first_name.." "..gAddressBook[gIndex].last_name
    gre.set_data(data)
    
    gre.send_event("DELETE_SCREEN")
end
