var file = file_text_open_read("cards.json")
var _x,_y,_z;
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetAqPlPos = [_x,_y,_z]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetAqPlRot = [-_x*180/pi,-_y*180/pi,-_z*180/pi]
TargetAqPlScal = [1,1,1]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetAqOpPos = [_x,_y,_z]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetAqOpRot = [-_x*180/pi,-_y*180/pi,-_z*180/pi]
TargetAqOpScal = [1,1,1]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetDkPlPos = [_x,_y,_z]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetDkPlRot = [-_x*180/pi,-_y*180/pi,-_z*180/pi]
TargetDkPlScal = [1,1,1]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetDkOpPos = [_x,_y,_z]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetDkOpRot = [-_x*180/pi,-_y*180/pi,-_z*180/pi]
TargetDkOpScal = [1,1,1]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetOceanPos = [_x,_y,_z]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetOceanRot = [-_x*180/pi,-_y*180/pi,-_z*180/pi]
TargetOceanScal = [1,1,1]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetHndOpPos = [_x,_y,_z]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetHndOpRot = [-_x*180/pi,-_y*180/pi,-_z*180/pi]
TargetHndOpScal = [1,1,1]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetHndPlPos = [_x,_y,_z]
_x = file_text_read_real(file); _y = file_text_read_real(file); _z = file_text_read_real(file)
TargetHndPlRot = [-_x*180/pi,-_y*180/pi,-_z*180/pi]
TargetHndPlScal = [1,1,1]
file_text_close(file)

lightDir = [0,0,0]

bgr = color_get_red(c_dkgrey)/255
bgg = color_get_green(c_dkgrey)/255
bgb = color_get_blue(c_dkgrey)/255


// Initialize 3D
gpu_set_zwriteenable(true)
gpu_set_ztestenable(true)
view_enabled = true
view_set_visible(0,true)
var camera = camera_create()
var projMat = matrix_build_projection_perspective_fov(-60,view_get_wport(0)/view_get_hport(0), 0.001, 1000);
camera_set_proj_mat(camera,projMat)
view_set_camera(0,camera)
camera_set_update_script(view_camera[0], freeCamera);
gpu_set_cullmode(cull_clockwise)

scene = mesh3DGLoad("./graphics/scene.obj.3dg")
initialized = false
idx = 1000
sf = -1