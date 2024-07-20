
if !surface_exists(sf) {
   sf = surface_create(room_width,room_height)
}


surface_set_target_ext(1,sf)
draw_clear(c_dkgrey)


shader_set(sha)


v3SubIP([0,0,20],[0,6,10],lightDir)
lightDir = v3Normalize(lightDir)
shader_set_uniform_f_array(shader_get_uniform(sha,"lightDir"),lightDir);


shader_set_uniform_f_array(shader_get_uniform(sha,"cardCol"),[bgr,bgg,bgb]);
var bobbing = sin(current_time/600)*0.05;
matrix_set(matrix_world,matBuild([0,0,bobbing],[0,0,0],[1,1,1]))
vertex_submit(cat,pr_trianglelist,sprite_get_texture(sprCat,0));
matrix_set(matrix_world,matBuild([0,0,0],[0,0,0],[1,1,1]))
vertex_submit(scene,pr_trianglelist,sprite_get_texture(sprSand,0));
vertex_submit(table,pr_trianglelist,sprite_get_texture(sprTable,0));

with( obj3DCard ) {
   if !is_undefined(card) {
      shader_set_uniform_f_array(shader_get_uniform(sha,"cardCol"),[card.index/255,0,0]);
      matrix_set(matrix_world,matBuild(position,rot,scale))
      vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(card.sprite,0));
      vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));
   }
}

matrix_set(matrix_world,matBuild([0,0,0],[0,0,0],[1,1,1]))
shader_set(shaOcean);
var sMask = shader_get_sampler_index(shaOcean, "t_Mask");
texture_set_stage(sMask, sprite_get_texture(sprWaterMask, 0));
shader_set_uniform_f(shader_get_uniform(shaOcean, "u_Time"), current_time / 1000.0);
shader_set_uniform_f(shader_get_uniform(shaOcean, "v_Time"), current_time / 1000.0);
vertex_submit(ocean,pr_trianglelist,sprite_get_texture(sprWater,0));

//shader_set(shaTableWater);
//shader_set_uniform_f(shader_get_uniform(shaTableWater, "u_Time"), current_time / 1000.0);
//vertex_submit(tablewater,pr_trianglelist,sprite_get_texture(sprOcean,0));
shader_set(shaTest);
var sAlpha = shader_get_sampler_index(shaTest, "t_Alpha");
var sMask = shader_get_sampler_index(shaTest, "t_Mask");

texture_set_stage(sAlpha, sprite_get_texture(sprAlpha, 0));
texture_set_stage(sMask, sprite_get_texture(sprWaterMask, 0));
shader_set_uniform_f(shader_get_uniform(shaTest, "u_Time"), current_time / 1000.0);
vertex_submit(tablewater,pr_trianglelist,sprite_get_texture(sprWater,0));

shader_reset()
matrix_set(matrix_world,matrix_build_identity())