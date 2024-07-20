
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
   camera_set_view_mat(view_camera[0], 
      matBuildLookat(
         global.camera.From,
         global.camera.To, 
         global.camera.Up
      )
   );
}

