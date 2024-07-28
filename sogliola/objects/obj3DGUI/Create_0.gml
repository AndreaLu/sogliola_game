                                                                                
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


opponentCursor = {
   x : window_get_width()/2,
   y : 0,
   subimg : 0
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
