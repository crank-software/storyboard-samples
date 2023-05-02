--[[
Copyright 2016 Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

local  load_gredom = function()
	if(gredom == nil) then
  		require("gredom")
	end
end

pcall(load_gredom)

--Used to calculate new font size based on current layer size.
local ORIGINAL_LAYER_WIDTH = 480
local ORIGINAL_LAYER_HEIGHT = 272
local ORIGINAL_FONT_SIZE = 14

--
-- This is the interface to a virtual keyboard.

-- This keyboard was derived from the JavaScript virtual keyboard
--  https://github.com/timovn/js-keyboard
-- and converted to a Lua/Storyboard Engine implementation
--
-- Main Lua conversion notes/issues/differences
-- * Lua doesn't do \uXXXX (4 hex) in UCS2 it does \ddd (3 dec) in UTF8
-- * Lua arrays start at 1, not at 0
-- * CSS classes aren't used, template variables instead

require("sbt_virtual_keyboard_assignment")

---@module sbt_virtual_keyboard
local Constructor = {}

---@type VKI_layout
-- @field #string name
-- @field #table keys
-- @field #list<#string> lang

---@type VKI
-- @field #map<#string,#VKI_layout> VKI_layout
-- @field #boolean VKI_emulate
-- @field #boolean VKI_shiftlock
-- @field #boolean VKI_shift
-- @field #boolean VKI_altgrlock
-- @field #boolean VKI_altgr
-- @field #string VKI_kt
-- @field #string VKI_target
-- @field #string kb_layer_instance
-- @field #string kb_layer
-- @field #string kb_control
-- @field #string kb_label_font
-- @field #map<#string, #string> cached_controls
local VKI = {}

--
-- Generic Utility Functions
--
local function alert(msg)
  print("ALERT: " .. msg)
end

-- Layout a series of controls evenly in a row
local function RowLayout(x, width, pad, controlList, center)
  local controlMetrics = {}
  local totalControlWidth = 0;

  -- Gather all of the control metrics and global measurements
  for c=1,#controlList do
    local cInfo = gre.get_control_attrs(controlList[c], "width")
    table.insert(controlMetrics, cInfo)
    totalControlWidth = totalControlWidth + cInfo.width
  end
  -- Account for padding between all of the controls
  totalControlWidth = totalControlWidth + (pad * #controlList - 1)

  -- Determine where we are putting controls ...
  local xPos, xPosEnd, extraGapSpace
  if(center) then
    xPos = x + math.floor((width - totalControlWidth) / 2)
    xPosEnd = xPos + totalControlWidth
    extraGapSpace = 0
  else
    xPos = x
    xPosEnd = x + width
    extraGapSpace = (width - totalControlWidth) / (#controlList - 1)
  end

  -- Put the controls there, spread the extra gap space evenly avoiding rounding accumulation
  local data = {}
  for c=1,#controlList-1 do
    data[string.format("%s.grd_x", controlList[c])] = xPos + math.floor((c-1) * extraGapSpace)
    xPos = xPos + controlMetrics[c].width + pad
  end

  -- Make the last control butt up to the end
  local c = #controlList
  data[string.format("%s.grd_x", controlList[c])] = xPosEnd - controlMetrics[c].width

  gre.set_data(data)
end

local ROW_PADDING = 5
---
--@param #string screen name
--@param #string layer name
--@param #string key_template control name
--@param #string target_var the storyboard variable to update as the keyboard receives input.
--@param #string default_language the default language to which the UI will be initialized.
--@param #string label_font the default font for labels
--@return #VKI
function Constructor.new(screen, layer, key_template, target_var, default_language, label_font, language_list_table)
  local vki = {}
  setmetatable(vki, {__index=VKI})

  if(screen == nil) then
    error("screen argument cannot be nil", 2)
  elseif(gredom ~= nil) then
    local domscreen = pcall(gredom.get_object,screen)
    if(domscreen == false) then
      error(string.format("screen (%s) not found in application", screen), 2)
    end
  end

  if(layer == nil) then
    error("layer argument cannot be nil", 2)
  elseif(gredom ~= nil) then
    local domlayer = pcall(gredom.get_object,string.format("%s.%s",screen,layer))
    if(domlayer == false) then
      error(string.format("layer (%s) not found on screen (%s)", layer, screen), 2)
    end
  end

  if(key_template == nil) then
    error("key_template argument cannot be nil", 2)
  elseif(gredom ~= nil) then
    local domcontrol = pcall(gredom.get_object,string.format("%s.%s",screen,layer))
    if(domcontrol == false) then
      error(string.format("control (%s) not found on layer (%s)", key_template, layer), 2)
    end
  end

  -- First thing we do is hide the template control
  gre.set_control_attrs(key_template, { hidden = true })

  if(default_language == nil) then
  	default_language = "us-int"
  end

  if(label_font == nil) then
  	label_font = "fonts/Roboto-Regular.ttf"
  end

  -- match everything up to the last 'dot' This may include a group ...
  vki.kb_layer_instance = string.format("%s.%s",screen,layer)
  vki.kb_layer = layer
  vki.kb_control = key_template
  vki.kb_label_font = label_font
  vki.VKI_target = target_var

  vki.cached_controls = {}

  --CRANK TF: Set the default keyboard
  vki.VKI_kt = default_language

  --CRANK TF: Emulate indicates if we should generate a keycode event
  --vki.VKI_emulate = (param[1]) ? true : false;
  vki.VKI_emulate = false;

  vki.VKI_shiftlock = false;
  vki.VKI_shift = vki.VKI_shiftlock

  vki.VKI_altgrlock = false;
  vki.VKI_altgr = vki.VKI_altgrlock

   vki.VKI_clickless = 0; --// point to click : 0 = disabled, >0 = delay in ms (recommended : 400 to 800)
  vki.VKI_onDraging = false;

  --/* ***** Create keyboards ************************************** */
  vki.VKI_layout = {};
  AssignKeyboards(vki.VKI_layout)

  --TODO: Add layouts to baseclass, not instance

  --/* ***** Define Dead Keys ************************************** */
  vki.VKI_deadkey = {};
  AssignDeadKeys(vki.VKI_deadkey)

  --TODO: Add deadkeys to baseclass, not instance

  vki.VKI_deadkeysOn = false

  --/* ***** Define Symbols **************************************** */
--  vki.VKI_symbol = {
--   ['\u00a0'] = "NB\nSP", ['\u200b'] = "ZW\nSP", ['\u200c'] = "ZW\nNJ", ['\u200d'] = "ZW\nJ"
--  };


  -- Build a list of language codes based on the names
  -- CRANK TF: We likely don't need this since we don't do content matching ...
--  vki.VKI_langCode = {};
--
--  local VKI_layout = vki.VKI_layout
--  for ktype,v in pairs(VKI_layout) do
--    if (VKI_layout[ktype].lang == nil) then
--      VKI_layout[ktype].lang = {};
--    end
--
--    local lang = VKI_layout[ktype].lang
--    for x = 1,#lang do
--      --this.VKI_layout[ktype].lang[x].toLowerCase().replace(/-/g, "_")
--      local name = string.gsub(string.lower(lang[x]), "-", "_")
--      vki.VKI_langCode[name] = ktype;
--    end
--  end

  --/* ***** Build the keyboard interface ************************** */
  if (vki.VKI_layout[vki.VKI_kt] == nil) then
    return alert('No keyboard named "' .. vki.VKI_kt .. '"');
  end

  vki:VKI_buildKeys()

  gre.set_value(key_template..".grd_hidden" , 1)

  vki:VKI_PopulateLanguageList(language_list_table)

  return vki
end

---Enable emulation
-- @param #VKI self
-- @param #function emulateCB
function VKI:SetEmulation(emulateCB)
  self.VKI_emulate = emulateCB
end

--- Get the keyboard types associated with this virtual keyboard
-- @param #VKI self
-- @return list<#string> An array of keyboard types supported by this class
function VKI:KeyboardTypeList()
  local types = {}
  for k,_ in pairs(self.VKI_layout) do
    table.insert(types, k)
  end
  return types
end

--- Get the english name for a keyboard for a keyboard type
-- @param #VKI self
---@param #string type The type of keyboard to get the name of
---@return #string A string containing the keyboard name
function VKI:KeyboardTypeEnglishName(type)
  local fullName = self:KeyboardTypeName(type)
  if(fullName == nil) then
    return nil
  end

  local endIndex = fullName:find("%s%-%s")

  if(endIndex ~= nil and endIndex < fullName:len()) then

    local name = fullName:sub(1, endIndex - 1)
    return name
  end

  return fullName
end

--- Get the user name for a keyboard for a keyboard type
-- @param #VKI self
---@param #string type The type of keyboard to get the name of
---@return #string A string containing the keyboard name
function VKI:KeyboardTypeName(type)
  local VKI_layout = self.VKI_layout[type]
  if(VKI_layout ~= nil and VKI_layout.name ~= nil) then
    return VKI_layout.name
  end

  return tostring(type)
end

--- Get the user name of the current keyboard
-- @param #VKI self
---@return #string A string containing the current keyboard name
function VKI:CurrentKeyboardName()
  return self:KeyboardTypeName(self.VKI_kt)
end

--- Get the keyboard type of the current keyboard
-- @param #VKI self
---@return #string A string containing the current keyboard name
function VKI:CurrentKeyboardType()
  return self.VKI_kt
end

--- Change the current keyboard type
-- @param #VKI self
---@param #string type The new type of the keyboard to select
function VKI:ChangeKeyboardType(type)
    self.VKI_kt = type;
    self:VKI_buildKeys()
end

--- Re-layout the keyboard
-- @param #VKI self
function VKI:UpdateSize()
  self:VKI_buildKeys()
end

--- Retreive a control to use for the keyboard at key grid position x, y
-- @param #VKI self
-- @param #number x
-- @param #number y
-- @return #string The name of a control to use for this key (may not be visible)
local function GetKeyName(vki, x, y)
    local baseName = string.format("_key_%d_%d", x, y)
    local fullName = string.format("%s.%s", vki.kb_layer, baseName)

    --Check the cache for a control first
    local control = vki.cached_controls[fullName]
    if(control ~= nil) then
      return control
    end

    --We don't have a control, make a new one
    local data = {}
    data.hidden = 0
    gre.clone_control(vki.kb_control, baseName, vki.kb_layer, data)

    vki.cached_controls[fullName] = fullName

    return fullName
end

--- Hide all of the keys that have been created for the keyboard
local function HideAllKeys(vki)
  local data = {}
  for k,v in pairs(vki.cached_controls) do
    local var = string.format("%s.grd_hidden", k)
    data[var] = 1
  end
  gre.set_data(data)
end

--- Utility routine for setting the color variable for a control
--- @param #string controlName The name of the control we're setting
--- @param #number clr The new color variable we are setting
--- @param #table dataTable An optional table to set instead of setting the variable directly
local function SetControlTextColor(controlName, clr, dataTable)
  local nameKey = string.format("%s.clr", controlName)
  if(dataTable ~= nil) then
    dataTable[nameKey] = clr
  else
    gre.set_value(nameKey, clr)
  end
end

---Based on the shift/alt state, determine the character index
-- @param #VKI self
function VKI:GetKeyCharacterIndex()
    local vchar = 1
    if ((not self.VKI_shift) ~= (not self.VKI_shiftlock)) then
      vchar = vchar + 1;
    end
    if ((not self.VKI_altgr) ~= (not self.VKI_altgrlock)) then
      vchar = vchar + 2;
    end
    return vchar
end

---
-- @param #VKI self
function VKI:VKI_keyClick(lkey)
    --/* ******************** Private table cell attachment function for generic characters **/
    local vki = self;
    local done = false;

    local vchar = self:GetKeyCharacterIndex()

    local character = lkey[vchar]
    if(character == "\xa0") then
      return
    end

    if (vki.VKI_deadkeysOn and vki.VKI_dead) then
      if (self.VKI_dead ~= character) then
        if (character ~= " ") then
          if (vki.VKI_deadkey[vki.VKI_dead][character]) then
            self:VKI_insert(vki.VKI_deadkey[vki.VKI_dead][character]);
            done = true;
          end
        else
          self:VKI_insert(vki.VKI_dead);
          done = true;
        end
      else
        done = true;
      end
    end
    vki.VKI_dead = false;

    if (not done) then
      if (vki.VKI_deadkeysOn and vki.VKI_deadkey[character]) then
        vki.VKI_dead = character;
        if (vki.VKI_shift) then
          self:VKI_modify("Shift");
        end
        if (vki.VKI_altgr) then
          self:VKI_modify("AltGr");
        end
      else
        self:VKI_insert(character);
      end
    end

    self:VKI_modify("");
end

---Triggered on gre.press of any key
-- @param #VKI self
function VKI:Press(mapargs)
  local control = mapargs.context_control
  local lkey = self.kb_lookup[control]

  local shiftKeyValue = lkey[2]
  if(not(shiftKeyValue == "Caps" or shiftKeyValue == "Shift" or
     shiftKeyValue == "Alt"  or shiftKeyValue == "AltGr" or shiftKeyValue == "AltLk")) then
	  if(shiftKeyValue == "Tab") then
  	    self:VKI_insert("\t")
	  elseif(shiftKeyValue == "Bksp") then
  	    self:VKI_insert("\b")
	  elseif(shiftKeyValue == "Enter") then
	      self:VKI_insert("\n");
  	else
	      self:VKI_keyClick(lkey);
    end
    self.VKI_shift = false
  end
  self:VKI_modify(lkey[1])
end

-- This is just an approximation ... need a true row layout here
--TODO: We need to do something better than this
local ControlWidthScaleFactor = {
["Bksp"] = 1.9,
["Tab"] = 1.5,
["Caps"] = 2,
["Shift"] = 2.6,
["Alt"] = 1.5,
["AltGr"] = 1.5,
["AltLk"] = 1.5,
["Enter"] = 1.9,
[" "] = 6.5,
}

---
-- @param #VKI self
function VKI:VKI_buildKeys()
  --/* **************** Build or rebuild the keyboard keys **/
  self.VKI_shift = false
  self.VKI_shiftlock = false
  self.VKI_altgr = false
  self.VKI_altgrlock = false

  local layerInfo = gre.get_layer_attrs(self.kb_layer_instance, "width", "height")
  local keyControlInfo = {}

  local font_size = ORIGINAL_FONT_SIZE
  local widthPercent = layerInfo.width / ORIGINAL_LAYER_WIDTH
  local heightPercent = layerInfo.height / ORIGINAL_LAYER_HEIGHT
  if(widthPercent <= heightPercent) then
    font_size = widthPercent * ORIGINAL_FONT_SIZE
  else
    font_size = heightPercent * ORIGINAL_FONT_SIZE
  end

  -- Hide all of the keys created to date, clear our keyboard cache
  HideAllKeys(self)
  self.kb_lookup = {}

  local padding = layerInfo.width * 0.008
  local keyLayerInfo = {width = layerInfo.width - 2 * padding, height = layerInfo.height - 2 * padding}

  --Get size of keys
  --1. Find max size of the keys
  --2. Calculate the total width of the keys per row
  --3. Center each row with the keys in place.  Center the keyboard to the center of the layer.
  local rows = {}
  local VKI_layout = self.VKI_layout[self.VKI_kt]
  local maximum_key_width = nil
  local maximum_key_height = nil
  for x = 1,#VKI_layout.keys do
    local keys_in_row = 0
    local width_of_row = 0
    local lyt = VKI_layout.keys[x]
    for y = 1,#lyt do
      keys_in_row = keys_in_row + 1
      local lkey = lyt[y]
      if(ControlWidthScaleFactor[lkey[2]] ~= nil) then
        local controlWidth = ControlWidthScaleFactor[lkey[2]]


        local prev_lyt = VKI_layout.keys[x-1]
        if(lkey[2] == "Shift" and y == 1 and #prev_lyt == #lyt) then
          controlWidth = controlWidth - 1
        end
        width_of_row = width_of_row + controlWidth
      else
        width_of_row = width_of_row + 1
      end
    end

    rows[x] = {keys=keys_in_row,width=width_of_row}
    if(maximum_key_width ~= nil) then
      maximum_key_width = math.min(maximum_key_width, keyLayerInfo.width/rows[x].width)
    else
      maximum_key_width = keyLayerInfo.width / rows[x].width
    end
  end

  local maximum_key_height = keyLayerInfo.height / #VKI_layout.keys
  local size = math.floor(math.min(maximum_key_width, maximum_key_height) - padding)
  keyControlInfo.width = size
  keyControlInfo.height = size

  -- Get information about the row widths
  local row_widths = {}
  local yPos = padding
  for x = 1,#VKI_layout.keys do
    local controlsOnRow = {}

    local xPos = padding
    local lyt = VKI_layout.keys[x]
    for y = 1,#lyt do
      local lkey = lyt[y]

      local keyWidth = keyControlInfo.width
      if(ControlWidthScaleFactor[lkey[2]] ~= nil) then
        local factor = ControlWidthScaleFactor[lkey[2]]
        if(x > 1 and lkey[2] == "Shift" and y == 1) then
          local prev_lyt = VKI_layout.keys[x-1]

          if(#prev_lyt == #lyt) then
            factor = factor - 1
          end
        end
        keyWidth = keyWidth * factor
      end

      xPos = xPos + keyWidth + padding

-- CRANK TF: Other than filling out all four key slots, the deadkey code is dead
--        for z = 1,4 do
--          lkey[z] = lkey[z] or ""       -- Fill all keyslots out with 4 values
--          if (vki.VKI_deadkey[lkey[z]]) then
--            hasDeadKey = true;
--          end
--        end
    end
    yPos = yPos + keyControlInfo.height + padding
    row_widths[x] = xPos

    --Make a nice row out of the keys, center if only a few
    --RowLayout(0, keyLayerInfo.width, padding, controlsOnRow, #lyt <= 3)
  end

  --Center each row.  Butt-up the leftmost and rightmost buttons to the ends.
  yPos = padding + (layerInfo.height - yPos) / 2
  for x = 1,#VKI_layout.keys do
      local controlsOnRow = {}

      local xPos = padding
      local lyt = VKI_layout.keys[x]
      for y = 1,#lyt do
        local lkey = lyt[y]

        local controlName = GetKeyName(self, x, y)

        table.insert(controlsOnRow, controlName)
        self.kb_lookup[controlName] = lkey
        local keyData = {}
        local keyWidth = keyControlInfo.width
        if(ControlWidthScaleFactor[lkey[2]] ~= nil) then
          local factor = ControlWidthScaleFactor[lkey[2]]
          if(self.label_font) then
            keyData[string.format("%s.font", controlName)] = self.label_font
          end

          if(lkey[2] == "Shift" and y == 1) then
            local prev_lyt = VKI_layout.keys[x-1]

            if(#prev_lyt == #lyt) then
              factor = factor - 1
            end
          end
          keyWidth = keyWidth * factor
        end

        if(#lyt > 3) then
          if(y == 1 or y == #lyt) then
            keyWidth = keyWidth + ((layerInfo.width - row_widths[x]) / 2)
          end
        else
          if(y == 1) then
            xPos = xPos + ((layerInfo.width - row_widths[x]) / 2)
          end
        end

        keyData[string.format("%s.grd_width", controlName)] = keyWidth
        keyData[string.format("%s.grd_height", controlName)] = keyControlInfo.width
        keyData[string.format("%s.grd_y", controlName)] = yPos
        keyData[string.format("%s.grd_x", controlName)] = xPos
        keyData[string.format("%s.font_size", controlName)] = font_size
        keyData[string.format("%s.grd_hidden", controlName)] = false
        keyData[string.format("%s.label", controlName)] = JSUCS2StringDecode(lkey[1])

        xPos = xPos + keyWidth + padding

        gre.set_data(keyData)

    end
    yPos = yPos + keyControlInfo.height + padding
  end
end

---
-- @param #VKI self
-- @param #string type
function VKI:VKI_modify(type)
   --/* ********************** Controls modifier keys **/
    if(type == "Alt" or type == "AltGr") then
      self.VKI_altgr = not self.VKI_altgr
    elseif(type == "AltLk") then
      self.VKI_altgr = false;
      self.VKI_altgrlock = not self.VKI_altgrlock;
    elseif(type == "Caps") then
      self.VKI_shift = false;
      self.VKI_shiftlock = not self.VKI_shiftlock;
    elseif(type == "Shift") then
      self.VKI_shift = not self.VKI_shift
    end

  local vchar = self:GetKeyCharacterIndex()

  local VKI_layout = self.VKI_layout[self.VKI_kt]

  local data = {}
  for x = 1,#VKI_layout.keys do
      local lyt = VKI_layout.keys[x]
      for y = 1,#lyt do
        local lkey = lyt[y]
        local controlName = GetKeyName(self, x, y)
        local className = {}

        local color = gre.get_value(string.format("%s.clr",controlName))
        if(lkey[2] == "Alt" or lkey[2] == "AltGr") then
          -- No visual change ..
        elseif(lkey[2] == "AltLk") then
          -- No visual change ..
        elseif(lkey[2] == "Shift") then
          -- No visual change ..
        elseif(lkey[2] == "Caps") then
          -- No visual change ..
        elseif(lkey[2] == "Tab" or lkey[2] == "Enter" or lkey[2] == "Bksp") then
          -- No visual change ..
        else
            if (type) then
              local labelKey = string.format("%s.label", controlName)
              data[labelKey] = lkey[vchar]
            end

--            if (this.VKI_deadkeysOn) then
--              local character = tds[y].firstChild.nodeValue || tds[y].firstChild.className;
--              if (this.VKI_dead) {
--                if (character == this.VKI_dead) className.push("pressed");
--                if (this.VKI_deadkey[this.VKI_dead][character]) className.push("target");
--              }
--              if (this.VKI_deadkey[character]) className.push("deadkey");
--            end
        end
    end
  end

  gre.set_data(data)
end

---Triggered on gre.outbound of any key
-- @param #VKI self
function VKI:Outbound()
  self:ChangeVisuals()
end

---
-- @param #VKI self
function VKI:ChangeVisuals()
 local vchar = self:GetKeyCharacterIndex()

  local VKI_layout = self.VKI_layout[self.VKI_kt]

  local kbVisual = {}

  for x = 1,#VKI_layout.keys do
      local lyt = VKI_layout.keys[x]
      for y = 1,#lyt do
        local lkey = lyt[y]
        local controlName = GetKeyName(self, x, y)
        local className = {}

        SetControlTextColor(controlName, 0xefefef, kbVisual)
        if(lkey[2] == "Alt" or lkey[2] == "AltGr") then
            if (self.VKI_altgr) then
              SetControlTextColor(controlName, 0xefefef, kbVisual)
            end
        elseif(lkey[2] == "AltLk") then
            if (self.VKI_altgrlock) then
              SetControlTextColor(controlName, 0xefefef, kbVisual)
            end
        elseif(lkey[2] == "Shift") then
            if (self.VKI_shift) then
              SetControlTextColor(controlName, 0xefefef, kbVisual)
            end
        elseif(lkey[2] == "Caps") then
            if (self.VKI_shiftlock) then
              SetControlTextColor(controlName, 0xefefef, kbVisual)
            end
        elseif(lkey[2] == "Tab" or lkey[2] == "Enter" or lkey[2] == "Bksp") then
            -- No visual change ..
        else
            -- No visual change ..
        end
    end
  end

  gre.set_data(kbVisual)
end

---Triggered on gre.release of any key
-- @param #VKI self
-- @param type
function VKI:Release(mapargs)
  self:ChangeVisuals()
end

---Insert text
-- @param #VKI self
function VKI:VKI_insert(jstext)
  if(jstext == nil) then
  	print("VKI_insert text is nil, very strange...")
  	return
	end

  local text = jstext

  if(self.VKI_emulate ~= nil) then
    -- UTF8 --> UCS2 transform
    local ucs2Value = UTF8ToUCS2(text)[1]
    -- Pass in UCS2 _and_ UTF8 character(s) and shift/ctrl/alt modifiers
    if(type(self.VKI_emulate) == 'function') then
      -- Custom key emulation (stuff ...)
      self.VKI_emulate(ucs2Value, text, modifiers, self)
    elseif(self.VKI_emulate == true) then
      --Generic key emulation (keydown/keyup)
    end
  end

  if(self.VKI_target ~= nil) then
    local value = gre.get_value(self.VKI_target)

    if(text == "\b") then
      value = UTF8Delete(value)
    else
      value = value .. text
    end

    gre.set_value(self.VKI_target, value)
  end
end

---Populate the language list
-- @param #VKI self
function VKI:VKI_PopulateLanguageList(languageListTable)
  local list = self:KeyboardTypeList()

  local data = {}
  data["rows"] = #list

  gre.set_table_attrs(languageListTable,data)

  data = {}
  for i=1,#list do
    data[languageListTable..".language."..i..".1"] = self:KeyboardTypeName(list[i])
    data[languageListTable..".alpha."..i..".1"] = 0
  end

  gre.set_data(data)
end

return Constructor