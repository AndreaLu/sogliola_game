meshCard = mesh3DGLoad("graphics/card.obj.3dg")
meshBack = mesh3DGLoad("graphics/back.obj.3dg")
targetScore = 0
targetScoreOp = 0
opScoreScal = 1
ScoreScal = 1
opScoreRot = 1
ScoreRot = 0
sfScore = -1
catSprite = sprCat
catTexture = sprite_get_texture(catSprite,0)
inputManager = {
   // when recording is true, the user plays normally, 
   // otherwise its a playback and input comes from a recording file
   recording : true,
   playbackFrame : 0,
   playback : ds_list_create(),
   playback_mouse : ds_list_create(),
   keys : {
      W : false,
      S : false,
      MBL : false,
      MBR : false
   },
   mouse : {
      X : 0,
      Y : 0
   },
   Init : function() {
      if !recording {
         LoadRecording()
      }
   },
   Update : function() {
      static playbackPos = 0
      if !recording {
         if playbackPos == array_length(playback) {
            recording = false
         } else {
            if playbackFrame == playback[playbackPos].frame {
               keys = playback[playbackPos]
               playbackPos += 1
         
            }
            mouse = playback_mouse[playbackFrame]
            playbackFrame += 1  
         }
      }
      if recording {
         if ! global.disableUserInput {
            keys.W   = keyboard_check_pressed(ord("W"))
            keys.S   = keyboard_check_pressed(ord("S"))
            keys.MBL = mouse_check_button_pressed(mb_left)
            keys.MBR = mouse_check_button_pressed(mb_right)
         } else {
            keys.W   = 0
            keys.S   = 0
            keys.MBL = 0
            keys.MBR = 0
         }
         mouse.X   = window_mouse_get_x()
         mouse.Y   = window_mouse_get_y()
         if global.debugMode {
            ds_list_add(playback,variable_clone(keys))
            ds_list_add(playback_mouse,variable_clone(mouse))
         }
      }
   },
   SaveRecording : function() {
      if !global.debugMode return;

      // Create a copy of the playback list with only the relevant info
      // (only store the frames where the keys actually change)
      var targetList = ds_list_create()
      var lastKeys = undefined
      for(var i=0; i<ds_list_size(playback); i++) {
         var keys = playback[|i]
         if is_undefined(lastKeys) || !keysEq(keys,lastKeys) {
            keys.frame = i
            ds_list_add(targetList,keys)   
            lastKeys = keys
         }
      }
      // Convert targetList to an array to store it with more ease with
      // json_stringify
      var playbackArray = array_create(ds_list_size(targetList))
      for(var i=0; i<ds_list_size(targetList); i++) {
         playbackArray[@i] = targetList[|i]
      }

      // Actually write hte file
      var file = file_text_open_write("keys_record")
      file_text_write_string(file,json_stringify(playbackArray))
      file_text_close(file)

      playbackArray = array_create(ds_list_size(playback_mouse))
      for(var i=0; i<ds_list_size(playback_mouse); i++) {
         playbackArray[@i] = playback_mouse[|i]
      }
      // Now lets save the mouse
      var file = file_text_open_write("mouse_record")
      file_text_write_string(file,json_stringify(playbackArray))
      file_text_close(file)
   },
   LoadRecording : function() {
      if !global.debugMode return;
      if ! file_exists("keys_record") return;
      var file = file_text_open_read("keys_record")
      var json = ""
      while( !file_text_eof(file) )
         json += " "+file_text_readln(file)
      file_text_close(file)
      playback = json_parse(json)

      if ! file_exists("mouse_record") return;
      file = file_text_open_read("mouse_record")
      json = ""
      while( !file_text_eof(file) )
         json += " "+file_text_readln(file)
      file_text_close(file)
      playback_mouse = json_parse(json)
   },
   keysEq : function(keysA,keysB) {
      if( keysA.W != keysB.W ||
          keysA.S != keysB.S ||
          keysA.MBL != keysB.MBL ||
          keysA.MBR != keysB.MBR )
          return false;
      return true
   }
}

enum GS {
   OUT,
   PRE_PRE_ENTERING,
   PRE_ENTERING,
   ENTERING,
   IN,
   PRE_EXITING,
   EXITING,
}
meshCage = mesh3DGLoad("graphics/cage.obj.3dg")
GridManager = function(isPlayer,_mesh) constructor {
   controller = undefined
   isPl = isPlayer
   mesh = _mesh
   offsX = 1
   position = [offsX,-1.56,0]
   state = GS.OUT
   t = 0;

   Update = function() {
      if is_undefined(controller) {
         controller = isPl ? global.player : global.opponent
         if !isPl position[@1] = -position[1]
      }
      if global.turnPlayer == controller {
         if controller.aquarium.protected && state != GS.IN {
            state = GS.PRE_PRE_ENTERING
         } else {
            if state == GS.IN {
               state = GS.PRE_EXITING
            }
         }
      } else {
         if controller.aquarium.protected && state == GS.PRE_PRE_ENTERING {
            state = GS.PRE_ENTERING
         }
      }

      switch( state ) {
         case GS.OUT:
            break
         case GS.PRE_PRE_ENTERING:
            position[@0] = lerp( position[0],0,0.1 )
            break
         case GS.PRE_ENTERING:
            t = 0;
            state = GS.ENTERING;
            break
         case GS.ENTERING:
            t += deltaTime()/1000000
            var p = t/3
            var _val = animcurve_channel_evaluate(animcurve_get_channel(ac1, 0), p)*(1/0.254)
            position[@0] = -(1-_val)*(6.64)
            if p >= 1
               state = GS.IN
            break
         case GS.PRE_EXITING:
            t = 0
            state = GS.EXITING
            break
         
         case GS.EXITING:
            t += deltaTime()/1000000
            var p = t/6
            position[@0] += 6.64*p*p
   
            if p >= 1
               state = GS.OUT
            break
         case GS.IN:
            break
      }
      matrix_set(matrix_world,matrix_build(position[0],position[1],position[2],0,0,0,1,1,1))
      vertex_submit(mesh,pr_trianglelist,sprite_get_texture(sprCage,0))
   }
}

gridManager = new GridManager(true,meshCage);
gridManagerOpp = new GridManager(false,meshCage)



opponentCursor = {
   x : getW()/2,
   y : 0,
   subimg : 0,
   alpha : 0,
   Draw : function() {
      alpha =  smoothstep(30,150,y)
      draw_sprite_ext(
         sprCursorOp,subimg,x,y, // Sprite,subimg,x,y
         2,2,0,c_white,          // XScale, yScale, rot, color1
         alpha   // Alpha
      )
   }
}

inputManager.Init()

TargetAqPlScal  = [1,1,1]
TargetAqOpScal  = [1,1,1]
TargetDkPlScal  = [1,1,1]
TargetDkOpScal  = [1,1,1]
TargetOceanScal = [1,1,1]
TargetHndOpScal = [1,1,1]
TargetHndPlScal = [1,1,1]


lightDir = [0,0,0]
v3SubIP([0,0,20],[0,6,10],lightDir)
v3NormalizeIP(lightDir,lightDir)

bgr = color_get_red(c_dkgrey)/255
bgg = color_get_green(c_dkgrey)/255
bgb = color_get_blue(c_dkgrey)/255


// Initialize 3D

gpu_set_zwriteenable(true)
gpu_set_ztestenable(true)
view_enabled = true
view_set_visible(0,true)
var camera = camera_create()

var projMat = matrix_build_projection_perspective_fov(
   -60,view_get_wport(0)/view_get_hport(0), 0.1, 100
);
camera_set_proj_mat(camera,projMat)
view_set_camera(0,camera)
camera_set_update_script(view_camera[0], freeCamera);
gpu_set_cullmode(cull_clockwise)

scene = mesh3DGLoad("./graphics/scene.obj.3dg")
ocean = mesh3DGLoad("./graphics/ocean.obj.3dg")
table = mesh3DGLoad("./graphics/table.obj.3dg")
cat = mesh3DGLoad("./graphics/cat.obj.3dg")
tablewater = mesh3DGLoad("./graphics/tablewater.obj.3dg")
bottle = mesh3DGLoad("./graphics/bottle.obj.3dg")
radio = mesh3DGLoad("./graphics/radio.obj.3dg")
paper = mesh3DGLoad("./graphics/paper.obj.3dg")



// Queste due variabili servono alla gestione del passaggio
// tra watching aquarium e playing
watching = false
watchingBack = true
camTransition = false


initialized = false
objectHover = undefined
sf = -1
sfDummy = -1

if global.debugMode {
   // Start the Blender server
   blenderServer = network_create_server_raw(
      network_socket_tcp, 2233, 1
   );
}


// array che viene costruito durante l'interazione con l'utente
// il primo elemento sarà la carta che si sta attivando/evocando
global.pickingTarget = undefined

// Rimuovo il cursore (disegno la sprite custom)
window_set_cursor(cr_none);
tt = 0


menu = [
]

prevColor = c_black
passingTurn = false