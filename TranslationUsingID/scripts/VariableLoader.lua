--[[
Copyright 2019, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

--[[
This module provides a generic interface for loading and setting variable values from external files. 
These files are organized around a unique key identifier being associated with multiple values based
on some notion of current type.  To demonstrate with a CSV file

id,english,french,spanish
1,hello,bonjour,ola 
2,goodbye,aurevoir,ola 

... or for non-translation entries:

variable,english,french,spanish
fontName,fonts/roboto.ttf,fonts/helvetica.ttf,fonts/arial.ttf
fontSize,20,20,15

This module is specifically tuned towards translation and internationalization uses, however it can be 
used in any situation where you want to load values associated with a specific key from a file and apply
those values to the user interface.  Translation scenarios will use language identifiers as keys while
theme applications might use other labels (such as 'night' and 'day')

There are two classes of values that can be loaded.  Values that require a mapping function for their
keys, typical in text translation scenarios where a numeric ID is mapped to language strings as in the
first example, and values that do not require a mapping function, typical in Storyboard property scenarios 
such as the second example.  These are called out and differentiated in the constructor.

--]]

--- CSV Mapping Implementation 
local csv = require("csv")

--- CSV Helper Function 
local function FindColumnMatch(fields, language) 
  for column,text in pairs(fields) do
    if(language == text) then
      return column
    end
  end
  return nil
end

---
-- Generically extract a named field (column in the case of CSV) into a Lua table of key/value 
-- pairs where the value comes from the specified language column and the key is generated through 
-- a user provided function that uses the first column as an id field:
--
-- For text translation files, the CSV file assumes the following layout:
-- id,language_name,language2_name, ...
-- <id number>,<utf8 text>,<utf8 text>
-- <id number>,<utf8 text>,<utf8 text>
-- ... 
-- 
-- For attribute files it assumes the layout is:
-- variable_name,language_name,language2_name, ...
-- <variable>,<utf8 text>,<utf8 text>
-- 
-- Both styles of files assume the first column is for the 'id' and that the first row contains
-- the headers with the language identifiers.
-- 
-- This function interface is generic and would be the extension point other providers would
-- use to provide their own "GetLanguageData" support based on their own file formats
-- 
--@param filename The name of the file to open (string) 
--@param language The language column header to extract (string)
--@param keyGenerator A function to generate keys for the table.  This function will be called with one 
--                    argument, the value of the first column of the row.  If this function is nil then 
--                    the first column value is used as is
local function GetLanguageData(filename, language, keyGenerator)
  local db = csv.open(filename)  
  if(db == nil) then
    return nil, string.format("Can't access database file %s", filename)
  end
  
  -- Read the database content.
  -- The first line of the database file is a header and we matches our language_name to a column of text
  -- Every line afterwards will set variables
  local column = nil
  local data = {}
  
  for fields in db:lines() do
   if(column == nil) then
     column = FindColumnMatch(fields, language)
     if(column == nil) then
      db:close()
      return nil, string.format("Can't find language column for %s", language)
     end
   else
     local key = fields[1]
     if(keyGenerator ~= nil) then
      key = keyGenerator(key)
     end
     data[key] = fields[column] 
   end
  end
  db:close()

  return data  
end
-- 

--- Variable Loader Interface Definition
local VariableLoader = {}
VariableLoader.__index = VariableLoader

--- 
-- Create a new variable loader object initialized from a table with the following attributes:
-- 
-- * language       The language that should be configured for the default translation
-- * loadOnInit     Flag indicating if the language should be fully loaded on init (default false)
--
-- * textDB         Filename (optional, string) to use for translations or array of files to use for translations
-- * textBasename   The namespace that should be used for creating variables (optional, defaut: translations)   
-- * textFormat     The format string used to convert an id to a variable (optional, default: "id_%s")
--
-- * attributeDB    Filename (optional, string) to used for straight variable -> value attribute lists
-- 
-- @param attrs A table of attributes to configure the loader
-- @return A variable loader object
local function CreateLoader(attrs)
  local loader = {}
  setmetatable(loader, VariableLoader)
  
  if(type(attrs.textDB) == "string") then
    loader.textDB = { attrs.textDB }
  else 
    loader.textDB = attrs.textDB  -- May be a table, may be nil
  end
    
      
  loader.textBasename = attrs.textBasename
  if(loader.textBasename == nil) then
    loader.textBasename = "translations" 
  end

  loader.textFormat = attrs.textBasename
  if(loader.textFormat == nil) then
    loader.textFormat = "id_%s" 
  end
  
  if(type(attrs.attributeDB) == "string") then
    loader.attributeDB = { attrs.attributeDB }
  else 
    loader.attributeDB = attrs.attributeDB  -- May be a table, may be nil
  end


  if(attrs.loadOnInit == true) then
    loader:setLanguage(attrs.language)
  else
    loader.language = attrs.language
  end
  
  return loader
end

--- 
-- This returns the current language the loader is configured to use
-- 
-- @return The current language or nil if no language configured
function VariableLoader:getLanguage()
  return self.language
end

--- 
-- This sets the loader's current language (or type/header in non translation 
-- scenarios) to a new setting and sources the text and attribute databases
-- to set all of the values associated with that new language.
-- 
-- @return True if loading occured or false otherwise.  The language is always 'set'
function VariableLoader:setLanguage(language)
  self.language = language
  
  local loaded = self:loadText(language)
  loaded = self:loadAttributes(language) or loaded
  
  return loaded
end

--- 
-- Internal function that maps a text id to a Storyboard variable string.  
-- This function by default uses the textFormat and textBasename attributes 
-- to create a variable value for the text data base entries
-- 
-- @return True if loading occured or false otherwise.  The language is always 'set'
function VariableLoader:textKeyGenerator(id)
  local varName = string.format(self.textFormat, id);
  return string.format("%s.%s", self.textBasename, varName)
end

--- 
-- Return the text value from the database for the given id in the current language
-- 
-- @return The text associated with the id for the current language or nil if no text associated
function VariableLoader:getTextForID(id) 
  if(self.textData == nil) then
    return nil
  end
  
  local key = self:textKeyGenerator(id)
  return self.textData[key]
end

--- 
-- Internal function used to load the text based on the current language
-- setting.  This method can be overriden to provide specific loading behaviour.
-- 
-- @return True if loading occurred, false otherwise
function VariableLoader:loadText()
  local language = self:getLanguage()
  if(language == nil) then
    return false
  end
  
  local dbNames = self.textDB
  if(dbNames == nil) then     -- No names, so nothing to do
    return true
  end
  
  local keyGenerator = function(key) return self:textKeyGenerator(key) end
    
  local loadError = nil;
  for i=1,#dbNames do
    local data, loadError = GetLanguageData(dbNames[i], language, keyGenerator)
    if(data ~= nil) then
      gre.set_data(data)
      self.textData = data
      return true, nil
    end
  end
  
  return false, loadError    
end

--- 
-- Internal function used to load the attributes based on the current language
-- setting.  This method can be overriden to provide specific loading behaviour.
-- 
-- @return True if loading occurred, false otherwise
function VariableLoader:loadAttributes()
  local language = self:getLanguage()
  if(language == nil) then
    return false
  end
  
  local dbNames = self.attributeDB
  if(dbNames == nil) then     -- No names, so nothing to do
    return true
  end
  
  local loadError = nil;
  for i=1,#dbNames do
    local data, loadError = GetLanguageData(dbNames[i], language, nil)
    if(data ~= nil) then
      gre.set_data(data)
      return true, nil
    end
  end
  
  return false, loadError    
end

return { CreateLoader = CreateLoader }
