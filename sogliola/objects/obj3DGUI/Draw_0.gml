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


ds_list_clear(clickBuffer)

// durante il summon, nascondi le carte sogliola in modo da non ostruire
// l'acquario nel click buffer. 
onlyDrawAquarium = false
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
shader_set_uniform_f(uAquarium,0)

if !onlyDrawAquarium {
   with( obj3DCard ) {
      if !is_undefined(card) {
         shader_set_uniform_f_array(
            obj3DGUI.uCardCol,
            [(card.index+1)/255,0,0]
         );
         if is_instanceof(card.location,Aquarium) || card.location == global.player.hand {
            //matrix_set(matrix_world,mat)
            var a = [0,0,0]
            worldToScreenIP(position[0],position[1],position[2], matrix_get(matrix_view), matrix_get(matrix_projection), a )
            array_push(a,card)
            ds_list_add(obj3DGUI.clickBuffer,a)
            //vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(card.sprite,0));
            //vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));
         }
         // draw the ghost card
         if card.location == global.player.hand && !global.zooming {
            b = [0,0,0]
            worldToScreenIP(ghost.position[0],ghost.position[1],ghost.position[2], matrix_get(matrix_view), matrix_get(matrix_projection), b )
            array_push(b,card)
            ds_list_add(obj3DGUI.clickBuffer,b)

            //matrix_set(matrix_world,ghost.mat)
            //vertex_submit(meshCard,pr_trianglelist,sprite_get_texture(card.sprite,0))
			   //vertex_submit(meshBack,pr_trianglelist,sprite_get_texture(sprBack,0))
         }
      }
   }
}



matrix_set(matrix_world,matrix_build_identity())
shader_set_uniform_f(uAquarium,1)
vertex_submit(tablewater,pr_trianglelist,sprite_get_texture(sprWater,0));
shader_set_uniform_f(uAquarium,0)
shader_set_uniform_f_array(
   uCardCol,
   [0,255,0]
);
var a = [0,0,0]
worldToScreenIP(
   global.Blender.RadioPos.Position[0],
   global.Blender.RadioPos.Position[1],
   global.Blender.RadioPos.Position[2],
   matrix_get(matrix_view), matrix_get(matrix_projection), a )
array_push(a,global.radio)
ds_list_add(obj3DGUI.clickBuffer,a)

vertex_submit(radio,pr_trianglelist,-1);

shader_set_uniform_f_array(
   uCardCol,
   [0,0.3,0]
);

matrix_set(matrix_world,matBuild(global.Blender.BottlePos.Position,[0,0,global.bottle.rotz],[1,1,1]))
var a = [0,0,0]
worldToScreenIP(
   global.Blender.BottlePos.Position[0],
   global.Blender.BottlePos.Position[1],
   global.Blender.BottlePos.Position[2],
   matrix_get(matrix_view), matrix_get(matrix_projection), a )
array_push(a,global.bottle)
ds_list_add(obj3DGUI.clickBuffer,a)
vertex_submit(bottle,pr_trianglelist,sprite_get_texture(sprBottle,0));


shader_reset()
surface_set_target_ext(1,sfDummy)

//#endregion |                                         |
//#region    | 2.0 Regular Rendering (sha)             |
global.matView = matrix_get(matrix_view)
global.matView[0] = global.matView[0] 
global.matProjection = matrix_get(matrix_projection)
global.matProjection[0] = global.matProjection[0]
draw_clear(make_color_rgb(48,117,163))

shader_set(sha)
shader_set_uniform_f(
   uTime,
   current_time / 1000.0
);
shader_set_uniform_f_array(uLightDir,lightDir);

var bobbing = sin(current_time/600)*0.05;
if (global.radioOn) {
	bobbing = sin(current_time/60)*0.1;
}
matrix_set(matrix_world,matBuild([0,0,bobbing],[0,0,0],[1,1,1]))
vertex_submit(cat,pr_trianglelist,catTexture);
matrix_set(matrix_world,matBuild([0,0,0],[0,0,0],[1,1,1]))
vertex_submit(scene,pr_trianglelist,sprite_get_texture(sprSand,0));
vertex_submit(table,pr_trianglelist,sprite_get_texture(sprTable,0));
vertex_submit(radio,pr_trianglelist,sprite_get_texture(sprRadio,0));

shader_set_uniform_f(uSel,global.bottle.highlight)
matrix_set(matrix_world,matBuild(global.Blender.BottlePos.Position,[0,0,global.bottle.rotz],[1,1,1]))
vertex_submit(bottle,pr_trianglelist,sprite_get_texture(sprBottle,0));
shader_set_uniform_f(uSel,0)

matrix_set(matrix_world,matrix_build_identity())
vertex_submit(paper,pr_trianglelist,sprite_get_texture(sprDrawing,0));

// xCard
if global.xCardVisible {
   if global.turnPlayer == global.player {
      matrix_set(matrix_world, matBuild(global.Blender.DckPl.Position, [0,0,0], [1,1,1] ))
      vertex_submit(obj3DGUI.meshCard, pr_trianglelist, sprite_get_texture(sprCardX,0))
      vertex_submit(obj3DGUI.meshBack, pr_trianglelist, sprite_get_texture(sprCardX,0))
   } else {
      matrix_set(matrix_world, matBuild(global.Blender.DckOp.Position, [0,0,0], [1,1,1] ))
      vertex_submit(obj3DGUI.meshCard, pr_trianglelist, sprite_get_texture(sprCardX,0))
      vertex_submit(obj3DGUI.meshBack, pr_trianglelist, sprite_get_texture(sprCardX,0))
   }
}

with( obj3DCard ) {
   worldToScreenIP(
      position[0],position[1],position[2],
      matrix_get(matrix_view),
      matrix_get(matrix_projection), 
      screenPos
   )
   if !is_undefined(card) {
      shader_set_uniform_f(
         obj3DGUI.uSel,
         selected || superSelected ? 1.0 : 0.0
      );
      matrix_set(matrix_world,mat)
      if surface_exists(surfSprite)
         vertex_submit(obj3DGUI.meshCard,pr_trianglelist,surface_get_texture(surfSprite));
      vertex_submit(obj3DGUI.meshBack,pr_trianglelist,sprite_get_texture(sprBack,0));
   }
}
shader_set_uniform_f(uSel,0.0)

matrix_set(matrix_world,matrix_build_identity())
shader_reset()


//#region    | 2.0 Cage (shaCage)                      |
shader_set(shaCage)
shader_set_uniform_f_array(uCageLightDir,lightDir);


gridManager.Update()
gridManagerOpp.Update()
matrix_set(matrix_world,matrix_build_identity())
shader_reset()
//#endregion |                                         |
//#endregion |                                         |
//#region    | 3.0 Ocean             (shaOcean)        |

matrix_set(matrix_world,matBuild([0,0,0],[0,0,0],[1,1,1]))
shader_set(shaOcean);

texture_set_stage(sMask, sprite_get_texture(sprWaterMask, 0));
shader_set_uniform_f(uOceanTime, current_time / 1000.0);
shader_set_uniform_f(vOceanTime, current_time / 1000.0);
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


shader_set_uniform_f(uPlAqSel, plAqSel);
shader_set_uniform_f(uOpAqSel, opAqSel);
texture_set_stage(sAlpha, sprite_get_texture(sprAlpha, 0));
texture_set_stage(sTableMask, sprite_get_texture(sprWaterMask, 0));
shader_set_uniform_f(uTableTime, current_time / 1000.0);
vertex_submit(tablewater,pr_trianglelist,sprite_get_texture(sprWater,0));



matrix_set(matrix_world,matrix_build_identity())

shader_reset()
//#endregion |                                         |
//#endregion |                                         |
//           |_________________________________________|

