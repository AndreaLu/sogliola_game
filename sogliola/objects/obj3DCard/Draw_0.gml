if is_undefined(card) exit
shader_set_uniform_f_array(shader_get_uniform(sha,"cardCol"),[card.index/255,0,0]);
matrix_set(matrix_world,matBuild(position,rot,scale))
vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(card.sprite,0));
vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));
//vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));



