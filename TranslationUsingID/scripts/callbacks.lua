
VarLoader = require("VariableLoader")

--- @param gre#context mapargs
function CBInit(mapargs) 
  -- English is the application's base design language so we don't have
  -- to perform any loading initially. If we start with a different language
  -- then we should use loadOnInit to set those initial values.
  local attrs = {}
  attrs.language = "english"
  --attrs.loadOnInit = true
  attrs.textDB = gre.APP_ROOT .. "/translations/translation_db.csv"
  attrs.attributeDB = gre.APP_ROOT .. "/translations/attribute_db.csv"

  Translation = VarLoader.CreateLoader(attrs)
end

--- @param gre#context mapargs
function CBLoadLanguage(mapargs)
  Translation:setLanguage(mapargs.language)
end


