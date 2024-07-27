draw_clear(c_dkgrey)

shader_set(sha)

shader_set_uniform_f_array(shader_get_uniform(sha,"lightDir"),[0,0,-1]);

matrix_set(matrix_world,mat)
vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(sprSogliolaBlob,0));
vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));

matrix_set(matrix_world,mat2)
vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(sprSogliolaBlob,0));
vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));

matrix_set(matrix_world,matrix_multiply(matrix_build(0,0,0,0,0,0,2,2,2),mat3))
vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(sprSogliolaBlob,0));
vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));

matrix_set(matrix_world,matrix_build_identity())
shader_reset()
