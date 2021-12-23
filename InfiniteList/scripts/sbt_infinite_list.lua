
--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

--- This is inspired by the JS version:
-- https://github.com/roeierez/infinite-list
--
-- In place of a DOM element, we pass the callbacks two integers:
-- * Item index: This is the index of the entry we are looking at directly
-- * Table index: This is the table index we are showing at
-- numItems = Number of items of virtual data
-- numCells = Number of cells in the table (numCells <= numItems)
-- numVisible = Number of table cells visible in the table (numVisible <= numCells)
--
-- firstItem = Index of the first item (Table Cell 1)
-- lastItem = Index of the last item (Table Cell numCells)
--
-- visibleUICells < settableUICells < virtualDataCells < realDataCells

---Clamp the input value to the specified min and max
-- @param #number value the value to clamp
-- @param #number min the minimum value for the clamp
-- @param #number max the maximum value for the clamp
local function clamp(value, min, max)
  value = math.max(value, min)
  value = math.min(value, max)
  return value
end

---@module sbt_infinite_list
local Constructor = {}

---@type InfiniteList
local InfiniteList = {}

---Create a new instance of an InfiniteList
-- @param #string tableName the name of the table to bind to this InfiniteList
-- @param #function renderCB the function to call when a cell's data needs to be populated
-- @param #function scrollCB the function to call 
-- @param #number numItems the number of items in the infinite list.
-- @param #numRows numRows the number of rows in the table.
-- @param #numRows numRows the number of columns in the table.
-- @return #InfiniteList
function Constructor.new(tableName, renderCB, scrollCB, numItems, numRows, numCols)
  local newList = {}
  setmetatable(newList, {__index=InfiniteList})
  
  if(numCols == nil) then
    numCols = 1
  end
  
  local numCells = numRows * numCols
  newList:dbg("new infinite table, numItems: %d numCells:%d", numItems, numCells)
  
  newList.tableName = tableName
  newList.renderCB = renderCB
  newList.scrollCB = scrollCB
  
  local tInfo = gre.get_table_attrs(newList.tableName, "width", "height")
  newList.tableHeight = tInfo.height
  newList.tableWidth = tInfo.width  
  newList.numCols = numCols
  newList.numRows = numRows
  
  local cInfo = gre.get_table_cell_attrs(newList.tableName, 1, 1, "width", "height")
  newList.cellHeight = cInfo.height
  newList.cellWidth = cInfo.width

  newList.numVisibleYCells = math.ceil(newList.tableHeight / newList.cellHeight)
  if(newList.numRows < newList.numVisibleYCells) then
    newList.numVisibleYCells = newList.numRows
  end
  
  newList.numVisibleXCells = math.ceil(newList.tableWidth / newList.cellWidth)
  if(newList.numCols < newList.numVisibleXCells) then
    newList.numVisibleXCells = newList.numCols
  end
  
  newList.numVisible = newList.numVisibleYCells * newList.numVisibleXCells
  if(numItems == nil) then
    numItems = 10000
  end
  newList.numItems = numItems
  
  if(numCells > numItems) then
    numRows = math.ceil(numItems / numCols)
  end
  
  numCells = numRows * numCols
  
  newList.numCells = numCells
  newList.numRows = numRows
 
  -- Initialize the list with content at the top
  newList.firstItem = 1   
  newList.lastItem = newList.numCells
  
  -- Seed the list with the current content
  newList:SyncCellsToData()
  
  -- Resize the table control
  gre.set_table_attrs(newList.tableName, { rows = newList.numRows })
  
  return newList
end

---Debug print function. Empty by default.
-- @param #InfiniteList self
-- @param #string fmt
-- @param ...
function InfiniteList:dbg(fmt, ...)
  -- local msg = string.format(fmt, unpack(arg))
  -- print(msg)
end

---Convert a 1 based table cell index to a 1 based data index
-- @param #InfiniteList self
-- @param #number cellIndex
-- @return #number dataIndex 
function InfiniteList:GetDataIndexFromCell(cellIndex)
  return self.firstItem + (cellIndex - 1)  
end

---Convert a 1 based data index to a 1 based table cell index
-- @param #InfiniteList self
-- @param #number dataIndex
-- @return #number cellIndex
function InfiniteList:GetCellIndexFromData(dataIndex)
  return dataIndex - (self.firstItem - 1)
end

---Refresh a single cell
-- @param #InfiniteList self
-- @param #number cellIndex
function InfiniteList:RefreshCell(cellIndex)
  self:SyncCellsToData(cellIndex, cellIndex)
end

---Synchronize a set of table cells to the backing store data
-- @param #InfiniteList self
-- @param #number cellStartIndex
-- @param #number cellEndIndex
function InfiniteList:SyncCellsToData(cellStartIndex, cellEndIndex)
  if(cellStartIndex == nil) then
    cellStartIndex = 1
    cellEndIndex = self.numCells
  end
  local di = self:GetDataIndexFromCell(cellStartIndex)
  
  local row = cellStartIndex - 1
  local data = {}
  for ci=cellStartIndex,cellEndIndex,self.numCols do
    local columnData = self:ItemRenderer(di, ci)
    row = row + 1
    for c=1,#columnData do
      local entry = columnData[c]
      for k,v in pairs(entry) do
        local nk = string.format("%s.%s.%d.%d", self.tableName, k, row, c)
        self:dbg("Setting %s, %s", nk, v)
        data[nk] = v
      end
    end
    di = di + self.numCols
  end
  
  gre.set_data(data)
end

---Return a table with a set of local table variables for each column
-- @param #InfiniteList self 
-- @param #number dataIndex
-- @param #number cellIndex
-- @return data from the renderCB callback
function InfiniteList:ItemRenderer(dataIndex, cellIndex)
    self:dbg("itemRenderer, %d dataIndex %d cellIndex", dataIndex, cellIndex)
    return self:renderCB(dataIndex, cellIndex)
end

---When we hit a scroll threshold where we are 80% through the data going in a 
-- direction then we need to kick off a cycle to shift the variables around.  
-- This gives us a range:  
-- [0 - 20%] (20% - 80%) [80% - 100%]  
-- When we drift into the outer ranges, then we shift the content by 20% to
-- the 40%/60% window in either direction.
-- @param #InfiniteList self
function InfiniteList:AutoSync()
  local tInfo = gre.get_table_attrs(self.tableName, "yoffset")
  if(tInfo.yoffset >= 0) then
    return
  end
  
  -- Add N (1) to represent the percent we are interested in
  local offscreenCount = (math.floor((-1 * tInfo.yoffset) / self.cellHeight)) * self.numCols;
  local thresholdCount = math.ceil(self.numRows * .20) * self.numCols
  local topThreshold = thresholdCount
  local bottomThreshold = self.numCells - self.numVisible - thresholdCount
  
  -- Here we use math.min because when bouncing, the current offscreenCount can change due to
  -- the way we calculate the offscreenCount.
  local currentItem = math.min(self.firstItem + offscreenCount - 1, self.numItems - self.numVisible)
  self.scrollPercent = currentItem / (self.numItems - self.numVisible)
  
  self:dbg("Content Check %d offscreen %d top %d bottom", offscreenCount, topThreshold, bottomThreshold)

  ---@field #number newFirstItem
  local newFirstItem = self.firstItem
  if(offscreenCount <= topThreshold) then
    newFirstItem = self.firstItem - thresholdCount
  elseif(offscreenCount > bottomThreshold) then
    newFirstItem = self.firstItem + thresholdCount
  end
  
  newFirstItem = clamp(newFirstItem, 1, self.numItems - self.numCells + 1)
  
  if(newFirstItem == self.firstItem) then
    if(self.scrollCB ~= nil) then
      self:scrollCB()
    end
    return
  end

  self:dbg("Change top virtual index from %d to %d, %d", self.firstItem, newFirstItem, thresholdCount)
  -- ie Old = 1, New = 9 -> Add to the yoffset value by cellHeight * difference 
  local rowDiff =  math.floor(newFirstItem/self.numCols) - math.floor(self.firstItem/self.numCols)   -- 9 - 1 = 8 
  local yPixDiff = rowDiff * self.cellHeight  -- 8 * height 
  
  self.firstItem = newFirstItem
  self.lastItem = self.numCells + self.firstItem
  
  self:SyncCellsToData()
  
  local newYOffset = tInfo.yoffset + yPixDiff
  gre.set_table_attrs(self.tableName, { ["yoffset"] = newYOffset })
  
  if(self.scrollCB ~= nil) then
    self:scrollCB()
  end
end

---
-- Set the scroll percentage in the infinite list
-- @param #InfiniteList self
-- @param #number percent
function InfiniteList:SetScrollPercent(percent)
  self.scrollPercent = percent
  
  local currentItem = self.scrollPercent * (self.numItems - self.numVisible) + 1
  
  local thresholdCount = math.ceil(self.numRows * .20) * self.numCols
  local newFirstItem = currentItem - thresholdCount + 1
  newFirstItem = clamp(newFirstItem, 1, self.numItems - self.numCells + 1)
  
  self.firstItem = math.floor(newFirstItem)
  self.lastItem = self.numCells + self.firstItem

  self:SyncCellsToData()

  local diff = currentItem - self.firstItem
  local newYOffset = -diff * self.cellHeight
  gre.set_table_attrs(self.tableName, { ["yoffset"] = newYOffset })
end

---Get the current scroll percentage
-- @param #InfiniteList self
-- @return #number scroll percent
function InfiniteList:GetScrollPercent()
  return self.scrollPercent
end

return Constructor