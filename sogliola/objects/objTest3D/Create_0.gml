
// Initialize 3D
gpu_set_zwriteenable(true)
gpu_set_ztestenable(true)
view_enabled = true
view_set_visible(0,true)
var camera = camera_create()

var projMat = matrix_build_projection_perspective_fov(
   -60,view_get_wport(0)/view_get_hport(0), 0.1, 100
);
camera_set_proj_mat(camera,projMat)
view_set_camera(0,camera)
camera_set_update_script(view_camera[0], freeCamera);
gpu_set_cullmode(cull_clockwise)

global.camera.From = [0,-4,6]
global.camera.To = [0,0,0]


meshCard = mesh3DGLoad("graphics/card.obj.3dg")
meshBack = mesh3DGLoad("graphics/back.obj.3dg")