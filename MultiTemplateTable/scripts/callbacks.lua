---------------------------------------------------------------------------------
--
--                 Multi Template Table Callbacks

local dkjson = require('utilities.dkjson')
local colors = require('utilities.colors')

-- Enum: which column displays the color name, and color
local columns = {
    name = 1,
    color = 2
}
-- Track if the table was scrolled
local was_scrolled = false

-- ### Local functions

--- Since the table we defined in Designer only has 1 row with 2 columns initially, resize the dimensions to accomodate the length of our color list data
-- @function set_table_dimensions
-- @param #number rows The number of rows to set
-- @param #number columns The number of columns to set
local function set_table_dimensions(rows, columns)
    local table_data = {}
    table_data['rows'] = rows
    table_data['cols'] = columns
    gre.set_table_attrs('table_layer.table_control', table_data)
end

--- Assign all the color list data to the table variables in the UI, and count how many rows will be required for the table
-- @function set_ui_data
-- @param #table color_list The list of json decoded key value pairs containing color names and values
-- @return #number row, #table data The number of total rows required to add into the table, and the corresponding color name and value data
local function set_ui_data(color_list)
    local data = {}
    -- Since we are looping the color list by key/value pairs: manually count row indices
    local row = 0
    for color_name, color_value in pairs(color_list) do
        -- Add each time you require a row
        row = row + 1
        -- Table variable keys to be set
        local name_key = string.format('table_layer.table_control.color_name.%d.%d', row, columns.name)
        local color_key = string.format('table_layer.table_control.color_value.%d.%d', row, columns.color)
        -- Assign row data to variable keys
        data[name_key] = color_name
        data[color_key] = color_value
    end

    -- Return the total rows, and table data
    return row, data
end

--- Update the UI when a table selection has been made
-- @function set_selection
-- @param #string control The selected control from mapargs.context_control
-- @param #number row The selected row from mapargs.context_row
local function set_selection(control, row)
    local data = {}
    -- Variable keys to retreive the selected color information
    local color_name_key = string.format('%s.color_name.%d.%d', control, row, columns.name)
    local color_value_key = string.format('%s.color_value.%d.%d', control, row, columns.color)
    -- Get the selected color data
    local color_data = gre.get_data(color_name_key, color_value_key)

    -- Selected result related variable keys
    local selected_title_key = 'selected_layer.title.text'
    local selected_hidden_key = 'selected_layer.selected_group.grd_hidden'
    local selected_text_key = 'selected_layer.selected_group.label.text'
    local selected_color_key = 'selected_layer.selected_group.color.color'

    -- Ensure the control that displays results is not hidden, and change the title
    data[selected_hidden_key] = 0
    data[selected_title_key] = 'Selection'
    -- Assign the color data
    data[selected_text_key] = color_data[color_name_key]
    data[selected_color_key] = color_data[color_value_key]

    gre.set_data(data)
end

-- ### Global functions

--- Initialize the table data from the colors utility module
-- @function cb_initialize
-- @param gre#context mapargs
function cb_initialize(mapargs)
    -- Get and decode the json data from the color utility module
    local colors_json = colors:get_data()
    local color_list = dkjson.decode(colors_json)
    -- Setup table related data
    local total_rows, data = set_ui_data(color_list)
    -- Set the table dimensions
    set_table_dimensions(total_rows, 2)
    -- Set the data, after resizing the table
    gre.set_data(data)
end

--- Called if the table is dragged/scrolled
-- @function cb_drag_start
-- @param gre#context mapargs
function cb_drag_start(mapargs)
    was_scrolled = true
end

--- Drag stop event is fired when the release event happens as a result of the gre.touch
-- @function cb_drag_start
-- @param gre#context mapargs
function cb_drag_stop(mapargs)
    was_scrolled = false
end

--- If the table was scrolled, then do nothing otherwise go ahead and set the selection
-- @function cb_table_touch
-- @param gre#context mapargs
function cb_table_touch(mapargs)
    if (was_scrolled) then
        return
    end
    -- Set the selection
    local control = mapargs.context_control
    local row = mapargs.context_row
    set_selection(control, row)
end
