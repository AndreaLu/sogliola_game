
if !surface_exists(sf) {
   sf = surface_create(room_width,room_height)
}


surface_set_target_ext(1,sf)
draw_clear(c_dkgrey)


shader_set(sha)


v3SubIP(global.camera.to,global.camera.position,lightDir)
lightDir = v3Normalize(lightDir)
shader_set_uniform_f_array(shader_get_uniform(sha,"lightDir"),lightDir);


shader_set_uniform_f_array(shader_get_uniform(sha,"cardCol"),[bgr,bgg,bgb]);
matrix_set(matrix_world,matBuild([0,0,0],[0,0,0],[1,1,1]))
vertex_submit(scene,pr_trianglelist,-1);


with( obj3DCard ) {
   if !is_undefined(card) {
      shader_set_uniform_f_array(shader_get_uniform(sha,"cardCol"),[card.index/255,0,0]);
      matrix_set(matrix_world,matBuild(position,rot,scale))
      vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(card.sprite,0));
      vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));
   }
}

shader_reset()
matrix_set(matrix_world,matrix_build_identity())