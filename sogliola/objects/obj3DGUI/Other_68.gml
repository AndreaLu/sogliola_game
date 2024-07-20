// Blender Debug Server
if async_load[?"type"] != network_type_data
   exit
var buff = async_load[?"buffer"]
var sz = async_load[?"size"]
var json = buffer_read(buff,buffer_string)
show_debug_message("Async: "+json)
global.Blender = json_parse(json)

v3SetIP(global.Blender.CamHand.From,global.camera.From)
v3SetIP(global.Blender.CamHand.To,global.camera.To)