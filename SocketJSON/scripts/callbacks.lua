local myenv = gre.env({ "target_os", "target_cpu" })
print(myenv.target_os, myenv.target_cpu)

if myenv.target_os  == "android"  or myenv.target_os  == "macos"  or myenv.target_os  == "win32" then
  package.path = gre.SCRIPT_ROOT .. "/" .. myenv.target_os .. "-" .. myenv.target_cpu .."/?.lua;"..package.path
  if myenv.target_os  == "win32" then
    package.cpath = gre.SCRIPT_ROOT .. "/" .. myenv.target_os .. "-" .. myenv.target_cpu .."/?.dll;"..package.cpath
  else
    package.cpath = gre.SCRIPT_ROOT .. "/" .. myenv.target_os .. "-" .. myenv.target_cpu .."/?.so;"..package.cpath
  end
  http = require("socket.http")
end

local url = ""
local post_list = {
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {},
  [8] = {},
  [9] = {},
  [10] = {}  
}
local users = {}

--- This function will reach out to the database in order to get a list of posts available
-- and apply the information returned to the posts_table in the main_layer
-- @function CBLoadPosts
-- @param gre#context mapargs
function CBLoadPosts(mapargs)
  local data = {}
  
  -- Get posts from the database and format the scrolling table
  for i = 1, #post_list do
    -- There are 100 posts available in the database, but we will limit it to 10 posts for simplicity
    -- request data for the specified post number, in this case it is specified by the iterator
    url = string.format("https://jsonplaceholder.typicode.com/posts/%d", i*10)
    post_list[i] = socket_json(url)
    
    -- update the scrolling table data variables
    data[string.format("main_layer.posts_table.post_title.%d.1", i)] = post_list[i].title
    data[string.format("main_layer.posts_table.post_id.%d.1", i)] = post_list[i].id  
  end
  
  gre.set_data(data)
end

--- This function reaches out to the database in order to get a list of users and their data
-- @function CBLoadUsers
-- @param gre#context mapargs
function CBLoadUsers(mapargs)
  local data = {}
  
  -- set the url to point to the user base
  url = "https://jsonplaceholder.typicode.com/users"
  users = socket_json(url)
  
  -- update the posts on the scrolling table with the names of the users who wrote each respective post
  for i = 1, #post_list do
    data[string.format("main_layer.posts_table.user_name.%d.1", post_list[i].userId)] = users[post_list[i].userId].name
  end
  
  gre.set_data(data)
end

--- When a post has been selected, this function will set up the post_screen with the data of the selected post
-- @function CBSelectPost
-- @param gre#context mapargs
function CBSelectPost(mapargs)
  local selected_id = tonumber(mapargs.selected_id)
  local author = mapargs.author
  local data = {}
  
  -- search the cached list of posts in order to retrieve the data of said selected post
  for i = 1, #post_list do
    if (post_list[i].id == selected_id) then
      data["Header.Title.title"] = post_list[i].title
      data["Header.Author.author"] = author
      data["Post.message.text"] = post_list[i].body
      break
    end
  end
  
  gre.set_data(data)
  -- set up the layout of the text box
  SetupPostLayout()
end

--- This function adjusts the dimensions of post_screen's message text box in order to fit the body of the post
function SetupPostLayout()
  local post_text = gre.get_value("Post.message.text")
  local post_measure = gre.rtext_text_extent(post_text,'Post.message')
  local data = {}
  
  data["Post.message.grd_height"] = post_measure.height
  gre.set_data(data)
end
