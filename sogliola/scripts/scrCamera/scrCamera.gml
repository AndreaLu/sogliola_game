
// Load the camera position from the bledner file

// Camera setup. Position, to and up can be chosen arbitrarily.
// The other are autimatically computed
global.camera = {
	position: [0,0,1],
	      to: [0,0,0],
		  up: [0,0,1],
	 forward: [sqrt(0.5),sqrt(0.5),0],
	   right: [0,0,0],
}

v3NormalizeIP(camera.up,camera.up);
v3SubIP(camera.to,camera.position, camera.forward);
v3NormalizeIP(camera.forward,camera.forward);
v3CrossIP(camera.forward,camera.up,camera.right);
show_debug_message(camera.forward)
show_debug_message(camera.right)
show_debug_message(camera.up)


/* function matBuildRot(vector,angle) {
	static tmp = [0,0,0]
	gml_pragma("forceinline")
	var C = cos(angle), S = sin(angle), t = 1-C
	var md = sqrt(vector[0]*vector[0] + 
	              vector[1]*vector[1] + 
				  vector[2]*vector[2])
	tmp[@0] = vector[0]/md
	tmp[@1] = vector[1]/md
	tmp[@2] = vector[2]/md
	var ux = tmp[0], uy =tmp[1], uz = tmp[2]
	var txx = t*ux*ux, txy = t*ux*uy, txz = t*ux*uz, tyz = t*uy*uz, tyy=t*uy*uy, tzz = t*uz*uz
	return  ([    txx+C, txy-S*uz, txz+S*uy, 0,
	           txy+S*uz,    tyy+C, tyz-S*ux, 0,
	           txz-S*uy, tyz+S*ux,    tzz+C, 0,
	                  0,        0,        0, 1])
} */


// This function can be use to manipulate global.camera implementing
// a "free camera" designed for testing purposes. WASD can be used to move
// along the plane of the forward / right camerea vectors and ctrl,space can be used
// to move along the up vector. Shift can be used to move faster.
function freeCamera() {
	
	// angleHor and angleVer collect respectively the horizontal and vertical cursor movement
	// over time producing a viewing angle. The camera orientation (forward,right,up vectors)
	// is then computed always starting from a given initial basic orientation and applying
	// the two angles
	static angleHor = 0;
	static angleVer = 0;
	static initialized = false;
	static to = [0,0,0];
	static centerX = window_get_width()/2;
	static centerY = window_get_height()/2;
	static f = [0,0,0]
	static r = [0,0,0]
	static u = [0,0,0];
	static cam = global.camera;
	
	
   /*
	// Avoid initial mouse glitch by operating the mouse only after the first iteration
	if( initialized ) {
		// Collect mouse movements
		var sensitivity = 0.5/room_speed;
		angleHor += (window_mouse_get_x()-centerX)*sensitivity;
		angleVer += (window_mouse_get_y()-centerY)*sensitivity;
		angleVer = clamp(angleVer,-pi/2,pi/2);
	} else {
		initialized = true;
		v3Set(f,cam.forward[0],cam.forward[1],cam.forward[2])
		v3Set(r,cam.right[0],cam.right[1],cam.right[2])
		v3Set(u,cam.up[0],cam.up[1],cam.up[2])
	}
	//window_mouse_set(centerX,centerY);
	
	
	// Rotate the camera vectors around the Up axis and then Right axis
	var m = matBuildRot(u,angleHor);
	cam.forward = matrix_transform_vertex(m,f[0],f[1],f[2]);
	cam.right = matrix_transform_vertex(m,r[0],r[1],r[2]);
	m = matBuildRot(cam.right,angleVer);
	cam.forward = matrix_transform_vertex(m,cam.forward[0],cam.forward[1],cam.forward[2]);
	cam.up = matrix_transform_vertex(m,u[0],u[1],u[2]);
	//show_debug_message([v3Dot(cam.up,cam.forward),v3Dot(cam.up,cam.right),v3Dot(cam.forward,cam.right)])
	
	// Move the camera with the keyboard
	var camSpeed = keyboard_check(vk_shift) ? 6/room_speed : 3/room_speed;	
	v3LC4IP( 
		cam.position, cam.forward, cam.right, cam.up, 
		1,
		(keyboard_check(ord("W")) - keyboard_check(ord("S")))*camSpeed,
		(keyboard_check(ord("D")) - keyboard_check(ord("A")))*camSpeed,
		(keyboard_check(ord("Q")) - keyboard_check(ord("E")))*camSpeed,
		cam.position
	);
	v3SumIP(cam.position,cam.forward,cam.to);
	*/
	camera_set_view_mat(view_camera[0], matBuildLookat(cam.position, cam.to, cam.up));
 
}


function loadBlenderCamera() {

//var projMat = matrix_build_projection_perspective_fov(-60,view_get_wport(0)/view_get_hport(0), 0.001, 1000);
//camera_set_proj_mat(camera,projMat)


   if !file_exists("camera.json") return;
   var file = file_text_open_read("camera.json")
   global.camera.position[@0] = file_text_read_real(file)
   global.camera.position[@1] = file_text_read_real(file)
   global.camera.position[@2] = file_text_read_real(file)
   global.camera.to[@0] = file_text_read_real(file)
   global.camera.to[@1] = file_text_read_real(file)
   global.camera.to[@2] = file_text_read_real(file)
   var fov = -file_text_read_real(file)
   var vw  = file_text_read_real(file)
   var vh  = file_text_read_real(file)
   fov *= (vh/vw)
   var projMat = matrix_build_projection_perspective_fov(fov,vw/vh, 0.1, 100);
   camera_set_proj_mat(view_camera[0],projMat)
   file_text_close(file)


}