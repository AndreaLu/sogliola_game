// +----------------------------------------------------------------------+
// | Draw Event                                                           |
// +----------------------------------------------------------------------+
/*
   All game rendering happens here
*/
if !surface_exists(sf)
   sf = surface_create(room_width,room_height)

if !surface_exists(sfDummy)
   sfDummy = surface_create(room_width,room_height)

//            _________________________________________
//#region    | 1.0 Click Buffer      (shaClickBuffer)  |


// durante il summon, nascondi le carte sogliola in modo da non ostruire
// l'acquario nel click buffer. 
var onlyDrawAquarium = false
if !is_undefined(global.pickingTarget) {
   // Filtra le opzioni possibili
   onlyDrawAquarium = !is_undefined(global.options.Filter(
      function(option) { 
         if array_length(option) < 4 || is_array(option[3]) return false;
         if option[2] != global.pickingTarget[0] return false;
         return ( is_instanceof(option[3],Aquarium) )
      }
   ))
}


surface_set_target_ext(1,sf)
shader_set(shaClickBuffer)
draw_clear(c_dkgray)
shader_set_uniform_f(shader_get_uniform(shaClickBuffer,"aquarium"),0)

if !onlyDrawAquarium {
   with( obj3DCard ) {
      if !is_undefined(card) {
         shader_set_uniform_f_array(
            shader_get_uniform(shaClickBuffer,"cardCol"),
            [(card.index+1)/255,0,0]
         );
         matrix_set(matrix_world,mat)
         vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(card.sprite,0));
         vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));
         // draw the ghost card
         if card.location == global.player.hand && !global.zooming {
            matrix_set(matrix_world,ghost.mat)
            vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(card.sprite,0))
            vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0))
         }
      }
   }
}

matrix_set(matrix_world,matrix_build_identity())
shader_set_uniform_f(shader_get_uniform(shaClickBuffer,"aquarium"),1)
vertex_submit(tablewater,pr_trianglelist,sprite_get_texture(sprWater,0));


shader_reset()
surface_set_target_ext(1,sfDummy)

//#endregion |                                         |
//#region    | 2.0 Regular Rendering (sha)             |

draw_clear(c_dkgrey)

shader_set(sha)
shader_set_uniform_f(
   shader_get_uniform(sha, "u_Time"),
   current_time / 1000.0
);
shader_set_uniform_f_array(shader_get_uniform(sha,"lightDir"),lightDir);

var bobbing = sin(current_time/600)*0.05;
matrix_set(matrix_world,matBuild([0,0,bobbing],[0,0,0],[1,1,1]))
vertex_submit(cat,pr_trianglelist,sprite_get_texture(sprCat,0));
matrix_set(matrix_world,matBuild([0,0,0],[0,0,0],[1,1,1]))
vertex_submit(scene,pr_trianglelist,sprite_get_texture(sprSand,0));
vertex_submit(table,pr_trianglelist,sprite_get_texture(sprTable,0));

matrix_set(matrix_world,matBuild(global.Blender.BottlePos.Position,[0,0,0],[1,1,1]))
vertex_submit(bottle,pr_trianglelist,sprite_get_texture(sprBottle,0));

with( obj3DCard ) {
   if !is_undefined(card) {
      shader_set_uniform_f(
         shader_get_uniform(sha, "uSel"),
         selected ? 1.0 : 0.0
      );
      matrix_set(matrix_world,mat)
      vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(card.sprite,0));
      vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));
   }
}
shader_set_uniform_f(shader_get_uniform(sha, "uSel"),0.0)

matrix_set(matrix_world,matrix_build_identity())
shader_reset()

//#endregion |                                         |
//#region    | 3.0 Ocean             (shaOcean)        |

matrix_set(matrix_world,matBuild([0,0,0],[0,0,0],[1,1,1]))
shader_set(shaOcean);
var sMask = shader_get_sampler_index(shaOcean, "t_Mask");
texture_set_stage(sMask, sprite_get_texture(sprWaterMask, 0));
shader_set_uniform_f(shader_get_uniform(shaOcean, "u_Time"), current_time / 1000.0);
shader_set_uniform_f(shader_get_uniform(shaOcean, "v_Time"), current_time / 1000.0);
vertex_submit(ocean,pr_trianglelist,sprite_get_texture(sprWater,0));

matrix_set(matrix_world,matrix_build_identity())
shader_reset()
//#endregion |                                         |
//#region    | 4.0 Aquarium          (shaTable)        |
//#region    |    4.1 Highlights                       |
// Determine wether the aquariums should be highlighted
// if there is an option available with source card the
// current picking target source and with target the
// aquarium, then highlight it.
var plAqSel = 0
var opAqSel = 0
if( !is_undefined(global.pickingTarget) && 
   array_length(global.pickingTarget) == 1 ) {
   var a = global.options.Filter(
      function(option) {
         if array_length(option) < 4 || is_array(option[3])
            return false;
         return ( option[3] == global.player.aquarium 
            && option[2] == global.pickingTarget[0] )
      }, undefined
   )
   if !is_undefined(a) plAqSel = 1
   var a = global.options.Filter(
      function(option) {
         if array_length(option) < 4 || is_array(option[3])
            return false;
         return ( option[3] == global.opponent.aquarium 
            && option[2] == global.pickingTarget[0] )
      }, undefined
   )
   if !is_undefined(a) opAqSel = 1
}
//#endregion
//#region    |    4.2 Rendering                        |
shader_set(shaTable);


shader_set_uniform_f(shader_get_uniform(shaTable, "plAqSel"), plAqSel);
shader_set_uniform_f(shader_get_uniform(shaTable, "opAqSel"), opAqSel);
var sAlpha = shader_get_sampler_index(shaTable, "t_Alpha");
var sMask = shader_get_sampler_index(shaTable, "t_Mask");

texture_set_stage(sAlpha, sprite_get_texture(sprAlpha, 0));
texture_set_stage(sMask, sprite_get_texture(sprWaterMask, 0));
shader_set_uniform_f(shader_get_uniform(shaTable, "u_Time"), current_time / 1000.0);
vertex_submit(tablewater,pr_trianglelist,sprite_get_texture(sprWater,0));



matrix_set(matrix_world,matrix_build_identity())

shader_reset()
//#endregion |                                         |
//#endregion |                                         |
//           |_________________________________________|
