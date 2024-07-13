var r = color_get_red(c_dkgrey)/255
var g = color_get_green(c_dkgrey)/255
var b = color_get_blue(c_dkgrey)/255
shader_set_uniform_f_array(shader_get_uniform(sha,"cardCol"),[r,g,b]);
matrix_set(matrix_world,matBuild([0,0,0],[0,0,0],[1,1,1]))
vertex_submit(scene,pr_trianglelist,-1);
