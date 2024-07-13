
if !surface_exists(sf) {
   sf = surface_create(room_width,room_height)
}


surface_set_target_ext(1,sf)
draw_clear(c_dkgrey)
shader_set(sha)


v3SubIP(global.camera.to,global.camera.position,lightDir)
lightDir = v3Normalize(lightDir)
shader_set_uniform_f_array(shader_get_uniform(sha,"lightDir"),lightDir);
