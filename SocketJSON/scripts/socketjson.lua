local json = require('dkjson')
local http = require('socket.http')
  
function socket_json(url)
  -- Get data from url, sink saves body content to lua table
  -- r returns 1, c returns 200
  -- h returns {connection, content-type, via, data, content-length, status, server}
  local body = {}
  local r,c,h = http.request {url = url, sink = ltn12.sink.table(body)}

  local decoded_page = json.decode(body[1])
  return decoded_page
end