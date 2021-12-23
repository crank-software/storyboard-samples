--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local CLOAK = 0

function cb_toggle_cloaking(mapargs) 
	local data = {}
	
	if CLOAK == 0 then
		CLOAK = 1
		data["btn_layer.cloaking_btn.image"] = "images/btn_IndBlkLrg_1.png"
		data["menu_layer.cloaking.image"] = "images/cloaking_down.png"
		gre.send_event_target("CLOAK_ON", "ship_layer.ship")
	else
		CLOAK = 0
		data["btn_layer.cloaking_btn.image"] = "images/btn_IndBlkLrg_0.png"
		data["menu_layer.cloaking.image"] = "images/cloaking_up.png"
		gre.send_event_target("CLOAK_OFF", "ship_layer.ship")
	end
	gre.set_data(data)
end

local SHIELDS = 0

function cb_shields_press(mapargs) 
	local data = {}
	
	if SHIELDS == 0 then
		SHIELDS = 1
		data["menu_layer.shields.image"] = "images/shields_down.png"
		gre.send_event("SHIELDS_SHOW")
	else
		SHIELDS = 0
		data["menu_layer.shields.image"] = "images/shields_up.png"	
		gre.send_event("SHIELDS_STOP")
	end
	gre.set_data(data)
end

function cb_shields_done(mapargs) 
	local data = {}
	
	if SHIELDS == 1 then
		SHIELDS = 0
		data["menu_layer.shields.image"] = "images/shields_up.png"		
	else
	  	data["shield_layer.shield_001.num"] = 0
    	data["shield_layer.shield_002.num"] = 0
    	data["shield_layer.shield_003.num"] = 0
	end
	gre.set_data(data)
end



local SCHEMATIC = 0

function cb_show_schematic(mapargs) 
	local data = {}
	
	if SCHEMATIC == 0 then
		SCHEMATIC = 1
		data["menu_layer.schematic.image"] = "images/schematic_down.png"
		gre.send_event("SCHEMATIC_SHOW")
	else
		SCHEMATIC = 0
		data["menu_layer.schematic.image"] = "images/schematic_up.png"
		gre.send_event("SCHEMATIC_HIDE")
	end
	gre.set_data(data)
end

local TEXT_CRAWL = 0

function cb_text_press(mapargs) 
	local data = {}
	
	if TEXT_CRAWL == 0 then
		TEXT_CRAWL = 1
		gre.send_event_target("CRAWL_TEXT")
		data["menu_layer.text1.image"] = "images/text_down.png"
	else
		TEXT_CRAWL = 0
		gre.send_event_target("CRAWL_TEXT_STOP")
		data["menu_layer.text1.image"] = "images/text_up.png"	
		data["text_layer.text.y_off"] = 1000
		data["Screen1.text_layer.grd_hidden"] = 1		
	end
	gre.set_data(data)
end

function cb_text_done(mapargs) 
	local data = {}
	
	if TEXT_CRAWL == 1 then
		TEXT_CRAWL = 0
		data["menu_layer.text1.image"] = "images/text_up.png"
		gre.set_data(data)
	end
end
