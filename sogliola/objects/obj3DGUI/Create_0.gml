TargetAqPlScal = [1,1,1]
TargetAqOpScal = [1,1,1]
TargetDkPlScal = [1,1,1]
TargetDkOpScal = [1,1,1]
TargetOceanScal = [1,1,1]
TargetHndOpScal = [1,1,1]
TargetHndPlScal = [1,1,1]


lightDir = [0,0,0]
v3SubIP([0,0,20],[0,6,10],lightDir)
v3NormalizeIP(lightDir,lightDir)

bgr = color_get_red(c_dkgrey)/255
bgg = color_get_green(c_dkgrey)/255
bgb = color_get_blue(c_dkgrey)/255


// Initialize 3D
gpu_set_zwriteenable(true)
gpu_set_ztestenable(true)
view_enabled = true
view_set_visible(0,true)
var camera = camera_create()

var projMat = matrix_build_projection_perspective_fov(-60,view_get_wport(0)/view_get_hport(0), 0.1, 100);
camera_set_proj_mat(camera,projMat)
view_set_camera(0,camera)
camera_set_update_script(view_camera[0], freeCamera);
gpu_set_cullmode(cull_clockwise)

scene = mesh3DGLoad("./graphics/scene.obj.3dg")
ocean = mesh3DGLoad("./graphics/ocean.obj.3dg")
table = mesh3DGLoad("./graphics/table.obj.3dg")
cat = mesh3DGLoad("./graphics/cat.obj.3dg")
tablewater = mesh3DGLoad("./graphics/tablewater.obj.3dg")
bottle = mesh3DGLoad("./graphics/bottle.obj.3dg")



// Queste due variabili servono alla gestione del passaggio
// tra watching aquarium e playing
watching = false
watchingBack = true


initialized = false
objectHover = undefined
sf = -1

if global.debugMode {
   // Start the Blender server
   blenderServer = network_create_server_raw(network_socket_tcp, 2233, 1);
}


// array che viene costruito durante l'interazione con l'utente
// il primo elemento sarà la carta che si sta attivando/evocando
global.pickingTarget = undefined

// Rimuovo il cursore (disegno la sprite custom)
window_set_cursor(cr_none);
