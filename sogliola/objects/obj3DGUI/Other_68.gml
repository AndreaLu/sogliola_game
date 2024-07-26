
// +----------------------+
// | BLENDER DEBUG SERVER |
// +----------------------+

if( !global.debugMode ) exit;
if( async_load[?"type"] != network_type_data ) exit;

var buff = async_load[?"buffer"]
var sz = async_load[?"size"]
var json = buffer_read(buff,buffer_string)
show_debug_message("Async: "+json)
global.Blender = json_parse(json)

structs = [
    Blender.HndPl,
    Blender.HndOp,
    Blender.DckPl,
    Blender.DckOp,
    Blender.AqPl,
    Blender.AqOp,
    Blender.Ocean,
]
for(var i=0;i<array_length(structs);i++) {
    var stru = structs[i]
    stru.Mat = matBuildCBM(
        stru.Transform.j,
        stru.Transform.i,
        stru.Transform.k,
    )
}

v3SetIP(global.Blender.CamHand.From,global.camera.From)
v3SetIP(global.Blender.CamHand.To,global.camera.To)