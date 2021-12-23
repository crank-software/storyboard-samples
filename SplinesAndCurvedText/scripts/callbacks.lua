
local poly_string = "0:410 64:446 128:232 192:377 256:274 320:431 384:373 448:97 512:252 576:158 640:333 704:180 768:155 832:175 896:298 960:441 1024:233 1088:94 1152:373 1216:366 1280:196 1344:398 1408:210 1472:375 1536:265 1600:128 1664:247 1728:98"
--- @param gre#context mapargs
function CBInit(mapargs)
  gre.set_value("GraphPoints", poly_string)
end

local Spacer = "                                                                "
local Days = {"FEB 28", "FEB 29", "MAR 1", "MAR 2", "MAR 3", "MAR 4", "MAR 5"}
--- @param gre#context mapargs
function CBDraw(mapargs)
  local graph_attrs = gre.get_layer_attrs("Graph", "xoffset")
  local max_width = gre.get_value("Graph.Graph.grd_width")
  local day_width = (max_width - 512) / 7
  local day = math.floor(graph_attrs.xoffset / day_width * -1) + 1
  gre.set_value("GraphTitle", Spacer.."AIR QUALITY ("..Days[day]..")")
end
