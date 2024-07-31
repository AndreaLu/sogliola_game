
function freeCamera() {

   camera_set_proj_mat(
      view_camera[0],
      matrix_build_projection_perspective_fov(
         global.camera.FOV, // FOV
         window_get_width()/window_get_height(),   // Aspect ratio
         0.1,         // Z-Near
         100          // Z-Far
      )
   )

   camera_set_view_mat(view_camera[0], 
      matBuildLookat(
         global.camera.From,
         global.camera.To, 
         global.camera.Up
      )
   );
}

