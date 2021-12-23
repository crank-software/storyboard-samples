--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

-- This sample provides a demonstration of the management of text scrolling.
-- It makes use of a Lua helper class/object to manage the basic scroll position
-- information and to perform the appropriate mathmatics for the managing the
-- scrolled content.

--[[ SCROLL CLASS START ]]

--The ScrollInfo class/object assists with the management of text scroll areas
--and provides a basic framework for measuring text and moving a render extension
--ScrollInfo makes a few assumptions about its use:
-- * The target control contains a single text render extension
-- * The target control contains a variable 'text' that contains the string to display
-- * The target control contains variables 'textx' and 'texty' for the x/y render extension position
--
--The lifecycle of a ScrollInfo object is:
-- var = ScrollInfo.create(...)
-- var:init()
-- ... to scroll var:scroll(..)
--
--If the text content changes, then init() must be called to re-calculate values
--To change the font or size a new ScrollInfo object should be created
ScrollInfo = {}
ScrollInfo.__index = ScrollInfo

--This is the constructor call to create a ScrollInfo object
--TODO: Allow a variable to be used for the font_name/font_size
--
--@param target_control This is the fully qualified name (<layer.control>) of the control
--@param font_name This is the resource path of the font, ie fonts/xyz.ttf
--@param font_size This is the point size of the font, ie 14
--@param wrap_text This is a boolean indicating if text wrapping should be calculated or not
--@param text_var This is the name of the variable containing the text, if not present <target_control>.text
--@param text_x This is the name of the variable text x offset, if not present <target_control>.textx
--@param text_y This is the name of the variable text y offset, if not present <target_control>.texty
--@param text_height This is the name of the variable text render extension height, if not present <target_control>.text_height
--@param text_padding This variable represents a value to use for "padding" to offset the text for aesthetic purposes
--@return A ScrollInfo object
function ScrollInfo.create(target_control, font_name, font_size, wrap_text, text_var, text_x, text_y, text_height, text_padding)
	local l = {}
	setmetatable(l, ScrollInfo)

	l.target = target_control
	l.target_height = nil
	l.font_name = font_name
	l.font_size = font_size
	l.wrap_text = wrap_text
	l.text_var = text_var or (l.target .. ".text")
	l.text_x = text_x or (l.target .. ".textx")
	l.text_y = text_y or (l.target .. ".texty")
	l.text_height = text_height or (l.target .. ".text_height")
	l.padding = text_padding or 0
	l.cur_x = l.padding
	l.cur_y = l.padding
	return l
end

function ScrollInfo.split(str, pat)
	local t = {}
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while (s) do
		if (s ~= 1 or cap ~= "") then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if (last_end <= #str) then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

--Initialize the values for the ScrollInfo object based on new text content
--@param reset_to_orgin A boolean indicating if the x/y offset should be reset (true)
function ScrollInfo:init(reset_to_origin)
	local k, line, ret

	--Reference variable for line height, use x height
	--'line_height' was introduced in a later version of sbengine so fallback to 'X'
	ret = gre.get_string_size(self.font_name, self.font_size, "X")
	--print("Line Height " .. tostring(ret.line_height) .. " X Height " .. tostring(ret.height))
	self.line_height = ret.line_height or ret.height
	self.max_y = self.line_height
	self.max_x = ret.width

	--Control width/height, used to limit scrolling and handle wrapping
	local wkey = self.target .. ".grd_width"
	local hkey = self.target .. ".grd_height"
	ret = gre.get_data(wkey, hkey)
	local ctrl_width = ret[wkey]
	local ctrl_height = ret[hkey]
	self.target_height = ctrl_height

	local d = gre.get_data(self.text_var)
	local txt = d[self.text_var]

	-- Calculate the number of lines, the max width and adjust the max line height
	self.line_count = 0

	local lines = ScrollInfo.split(txt, "\n")
	for k,line in ipairs(lines) do
		--print("Line: " .. tostring(self.line_count) .. " [" .. line .. "]")

		local substring = line
		local substring_length = #substring

		-- Determine if there is content on the line, if so then split it
		-- Otherwise if it is just an empty line (\n) then just increment the count
		if(substring_length > 0) then
			while(substring_length > 0) do
				--Determine the size of the string, clipped to the rect

				ret = gre.get_string_size(self.font_name, self.font_size, substring, 0, ctrl_width)
				if(ret.nchars == nil) then
					ret.nchars = ret.num_bytes
				end
				if(self.wrap_text and ret.nchars < substring_length) then
					--Back up and find the last space if we can and measure to that, else clip string
					local clip_string = string.sub(substring, 1, ret.nchars)
					local ms,me = string.find(clip_string, ".*%s")
					local clipped_nchars = me or ret.nchars
					--print("Clip@ " .. tostring(ret.nchars) .. " Break@ " .. tostring(clipped_nchars) .. " Line: " .. substring)
					ret = gre.get_string_size(self.font_name, self.font_size, substring, clipped_nchars, ctrl_width)
					if(ret.nchars == nil) then
						ret.nchars = ret.num_bytes
					end
				end

				if(ret.width > self.max_x) then
					self.max_x = ret.width
				end
				if(ret.height > self.max_y) then
					self.max_y = ret.height
				end

				self.line_count = self.line_count + 1

				--If there is any kind of encoding glitch, then nchars will be 0 so bail
				if(ret.nchars == nil or ret.nchars == 0) then
					substring = ""
					substring_length = 0
				else
					substring = string.sub(substring, ret.nchars+1)
					substring_length = #substring
				end
			end
		else
			self.line_count = self.line_count + 1
		end
	end

	--Adjust the max_y to encompass all of the text, max_y is either line_height or max character height
	self.max_y = self.line_count * self.max_y

	--Now determine the control size and the 'scroll' limits in pixels .. this allows
	--us to use arbitrary scroll amounts as desired by a particular implementation
	self.scroll_x = self.max_x - ctrl_width
	if(self.scroll_x < 0) then
		self.scroll_x = 0
	end

	self.scroll_y = self.max_y - ctrl_height
	if(self.scroll_y < 0) then
		self.scroll_y = 0
	end

	--Diagnostics
	--print("Line Height: " .. tostring(self.line_height))
	--print("Line Count: " .. tostring(self.line_count))
	--print("Text Max X/Y: " .. tostring(self.max_x) .. "/" .. tostring(self.max_y))
	--print("Control W/H: " .. tostring(ctrl_width) .. "/" .. tostring(ctrl_height))
	--print("Scroll Max X/Y: " .. tostring(self.scroll_x) .. "/" .. tostring(self.scroll_y))

	-- We normally wouldn't have to maintain these values
	-- but a Storyboard buglet means that we do in order to
	-- be backward compatible.
	self.cur_x = self.padding
	self.cur_y = 0

	d = {}
	d[self.text_x] = self.cur_x
	d[self.text_y] = self.cur_y + self.padding
	d[self.text_height] = self.max_y
--	d["Textfield.height"..".grd_height"] = self.max_y
	gre.set_data(d)
end

--Scroll the text item in a particulal direction
--@param dir The direction, one of "up", "down", "left", "right"
function ScrollInfo:scroll(dir)
	local offsetx = 0
	local offsety = 0
	local next_pos = 0

	if(dir == "up") then
		offsety = -1 * self.line_height
	elseif(dir == "down") then
		offsety = 1 * self.line_height
	elseif(dir == "left") then
		offsetx = 0 --TODO
	elseif(dir == "right") then
		offsetx = 0	--TODO
	else
		print("Unknown scroll direction " .. tostring(dir))
		return
	end

	--A Storyboard buglet means that we need to maintain
	--the values locally in the object rather than pull live
	--local d = gre.get_data(self.text_x, self.text_y)
	local d = {}

	d[self.text_x] = self.cur_x
	d[self.text_y] = self.cur_y

	next_pos = d[self.text_x] + offsetx
	if(next_pos <= 0 and ((-1*next_pos) < self.scroll_x)) then
		d[self.text_x] = next_pos
	end

	next_pos = d[self.text_y] + offsety
	if(next_pos <= 0 and ((-1*next_pos) < self.scroll_y)) then
		d[self.text_y] = next_pos
	elseif(next_pos > 0 and dir == "down") then
		d[self.text_y] = self.padding
	elseif(next_pos < (-1 * self.scroll_y) and dir == "up") then
		d[self.text_y] = (-1 * self.scroll_y) - self.padding
	end

	--print("Move Text x/y to " .. tostring(d[self.text_x]) .. "/" .. tostring(d[self.text_y]))
	gre.set_data(d)

	self.cur_x = d[self.text_x]
	self.cur_y = d[self.text_y]
end

--Get an internal scroll value, useful for scroll bars etc...
--@param value Any of the private members on the ScrollInfo object
--@return returns the internal member value or nil if it doesn't exist
function ScrollInfo:getValue(value)
  return self[value]
end

function ScrollInfo:scrollArea(percent)
  if (self.target_height < self.max_y) then
    local heightDelta = self.max_y - self.target_height
    local data = {}
	local drawY = (heightDelta * percent) * -1
    self.cur_y = drawY
	if (percent == 100) then
		drawY = drawY - self.padding
	elseif (percent == 0) then
		drawY = drawY + self.padding
	end
    data[self.text_y] = drawY
    gre.set_data(data)
  end
end
--[[ SCROLL CLASS END ]]

-- Maintain a global scroll map with the scroll objects we are monitoring
scroll_map = {}
