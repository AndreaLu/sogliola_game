// +----------------------------------------------------------------------+
// | obj3DGUI: Draw GUI Event                                             |
// +----------------------------------------------------------------------+
/*
   This is where the user interaction is taken care of
 */

inputManager.Update()

var w = sprite_get_width(sprBack)
var h = sprite_get_height(sprBack)

// 3d uses culling which prevents 2d graphics from being displayed
gpu_set_cullmode(cull_noculling)

//            _____________________________________________
//#region    | 1.0 Display debug Info                      |
if global.debugMode {
   // Current keys playback frame
   draw_text(0,200,inputManager.playbackFrame)
   // Click Buffer
   if keyboard_check(vk_escape) draw_surface(sf,0,0)
   // Protected aquarium info
   if global.player.aquarium.protected
      draw_text(400,100,"acquario player protetto")
   if global.opponent.aquarium.protected
      draw_text(400,80,"acquario avversario protetto")
   // Draw all the available moves
   //drawY = 100
   //draw_set_color(c_black)
   //global.options.foreach( function(option,ctx) {
   //   draw_text(100,ctx.drawY,option[0])
   //   ctx.drawY += 20
   //},self)
}
//#endregion
//#region    | 2.0 Interazione con il Player               |
//#region    |    2.1 Zoom della Carta                     |
if( !is_undefined(objectHover) && global.turnPlayer == global.player ) {
  
   if is_instanceof( objectHover, Card ) {
      card = objectHover
      
      if ( card.location == global.player.hand && !watching) {
         //card.guiCard.setMouseHover()
         if inputManager.keys.MBR {
            card.guiCard.setZoom()
         }
      }
//#endregion
//#region    |    2.2 Card Picking                         |
//#region    |       2.1.0 Secondo click in poi, su carte  | 
      var options = global.options.FilterAll(function(option,args) {
         var card = args[0]
         return (option[2] == card)
      },[card])
      porcodio = options
      
      // ------------------------------------------------------------------------------
      // Secondo click in poi, su carte 
      if !watching && !global.zooming && inputManager.keys.MBL && 
         !is_undefined(global.pickingTarget) {
         // Trova tutte le mosse restanti che hanno come target tutti gli elementi
         // attualmente presenti in pickingTarget, oltre alla carta attuale
         options = global.options.FilterAll( function(option,args) {
            // escludi le mosse la cui carta sorgente non sia quella che si vuole 
            // attivare/evocare
            if( option[2] != args[0][0]) return false;
            // crea un array con tutti i target da ricercare nelle mosse
            var targets = []
            array_copy(targets,0,args[0],1,array_length(args[0])-1)
            targets[@array_length(targets)] = args[1]
            // crea un array con tutti i target della mossa
            var optionTargets = (!is_array(option[3])) ? [option[3]] : option[3]
            // verifica che tutti i target in targets siano anche in optionTargets
            var count = 0
            for( var i=0;i<array_length(optionTargets);i++) {
               var target = optionTargets[i]
               for( var j=0;j<array_length(targets);j++) {
                  if targets[j] == target {
                     count += 1
                     break
                  }
               }
               if count == array_length(targets) {
                  return true
               }
            }
         },[global.pickingTarget,card])
         
         if array_length(options) == 1 {
            // Esegue la mossa
            var option = options[0]
            ExecuteOption(option,true)
            global.disableUserInput = true
            new StackMoveCamera(
               global.Blender.CamHand.From,
               global.Blender.CamHand.To,
               global.Blender.CamHand.FovY,
               0.3, function() {
                  global.pickingTarget = undefined
                  global.disableUserInput = false
               }
            )
         }
         else if array_length(options) > 1 {
            // Se c'era più di una mossa, aggiunge la carta selezionata all'array
            // pickingTarget
            global.pickingTarget[@array_length(global.pickingTarget)] = card
         }
      }
//#endregion
//#region    |       2.1.1 Primo click                     | 

      if !watching && !global.zooming && inputManager.keys.MBL
         && is_undefined(global.pickingTarget) {
         
         
         if( array_length(options) > 1) {
            global.disableUserInput = true
            // Zoom nell'acquario, bisogna scegliere il target
            new StackMoveCamera(
               global.Blender.CamAq.From,
               global.Blender.CamAq.To,
               global.Blender.CamAq.FovY,
               0.3, function() {
                  global.disableUserInput = false
               }
            )
            global.pickingTarget = [card]
         }

         // La mossa possibile è una sola. La eseguo, solo se non ci sono target da 
         // cliccare. Se ce ne sono, anche se uno solo, lo lascio scegliere al
         // giocatore
         if( array_length(options) == 1 ) {
            var option = options[0]
            // Se non ci sono target possibili, esegui l'unica mossa possibile
            if (array_length(option) <= 3 || is_undefined(option[3])) {
               ExecuteOption(option,true)
            } else {
               global.disableUserInput = true
               new StackMoveCamera(
                  global.Blender.CamAq.From,
                  global.Blender.CamAq.To,
                  global.Blender.CamAq.FovY,
                  0.3, function() {
                     global.disableUserInput = false
                  }
               )
               global.pickingTarget = [card]
            }
         }
      } 
   }
//#endregion
//#region    |       2.1.2 Secondo click (su acquari)      | 

   // secondo click in poi, su acquari. Per ora gli effetti che coinvolgono 
   // gli acquari hanno un solo target possibile, quindi faccio gestione 
   // semplificata. Dovessero sorgere carte con più target, di cui almeno
   // uno acquario, dovrò correggere..
   if is_instanceof( objectHover, Aquarium ) &&
      !is_undefined(global.pickingTarget) &&
      inputManager.keys.MBL {
      // Valuto se, tra le opzioni, si può scegliere l'acquario su cui si sta
      // passando il mouse
      aquarium = objectHover
      var a = global.options.Filter(
         function(option,args) { 
            if array_length(option) < 4 || is_array(option[3]) return false;
            return ( option[3] == args[0] && option[2] == global.pickingTarget[0] )
         },
         [aquarium]
      )
      if !is_undefined(a) {
            // Esegue la mossa
            ExecuteOption(a,true)
            global.disableUserInput = true
            new StackMoveCamera(
               global.Blender.CamHand.From,
               global.Blender.CamHand.To,
               global.Blender.CamHand.FovY,
               0.3, function() { 
                  global.pickingTarget = undefined
                  global.disableUserInput = false
               }
            )
      }
   }
}
//#endregion
//#region    |       2.1.3 Annullare un Card Picking       |
// Annullare un cardpicking in corso
if !is_undefined(global.pickingTarget) && 
   (inputManager.keys.MBR || inputManager.keys.S) 
   && !global.disableUserInput  && global.stack.size == 0 {
   
   global.pickingTarget = undefined
   global.disableUserInput = true
   // Torno alla mano, al massimo non accade niente
   new StackMoveCamera(
      global.Blender.CamHand.From,
      global.Blender.CamHand.To,
      global.Blender.CamHand.FovY,
      0.3, function() {
         global.disableUserInput = false
      }
   )
}
//#endregion
//#endregion |                                             |
//#region    |    2.3 Passare il turno                     |
if global.turnPlayer == global.player  && keyboard_check_pressed(vk_enter) {
   var test = global.options.Filter( function(option) {
      return option[0] == "Pass the turn"
   })
   if ! is_undefined(test) {
      // Esegui la mossa, l'unica possibile
      var option = test
      ExecuteOption(option,true)
      global.disableUserInput = true
      new StackMoveCamera(
         global.Blender.CamOpponent.From,
         global.Blender.CamOpponent.To,
         global.Blender.CamOpponent.FovY,
         0.3, function() {
            global.disableUserInput = false
         }
      )
   }
}
//#endregion |                                             |
//#region    |    2.4 W and S keys                         |
if inputManager.keys.W && !watching  && is_undefined(global.pickingTarget)
   && global.turnPlayer == global.player && !global.zooming && !global.disableUserInput {
   watching = true
   camTransition = true
   global.disableUserInput = true
   new StackMoveCamera(
      global.Blender.CamAq.From,
      global.Blender.CamAq.To,
      global.Blender.CamAq.FovY,
      0.3, function() {
         time_source_start(
            time_source_create(
               time_source_game,0.1,
               time_source_units_seconds, function() {
               obj3DGUI.watchingBack = false
               obj3DGUI.camTransition = false
               global.disableUserInput = false
            })
         )
      }
   )
}

if watching && inputManager.keys.S && !watchingBack && !global.zooming 
&& global.stack.size == 0 {
   watchingBack = true
   camTransition = true
   global.disableUserInput = true
   new StackMoveCamera(
      global.Blender.CamHand.From,
      global.Blender.CamHand.To,
      global.Blender.CamHand.FovY,
      0.3, function() {
         obj3DGUI.watchingBack = true
         time_source_start(
            time_source_create(
               time_source_game,0.1,
               time_source_units_seconds, function() {
               obj3DGUI.watching = false
               obj3DGUI.camTransition = false
               global.disableUserInput = false
            })
         )
         
      }
   )
}
//#endregion |                                             |
//#region    | 3.0 Draw the Cursor                         |
draw_sprite_ext(
   sprCursor,
   mouse_check_button(mb_any) ? 1 : 0,        // subimg
   inputManager.mouse.X,inputManager.mouse.Y, // x,y
   2,2,0, c_white,1                           // scale,rot,col,alpha
)
draw_sprite_ext(
   sprCursorOp,opponentCursor.subimg,opponentCursor.x,opponentCursor.y,
   2,2,0,c_white, smoothstep(30,150,opponentCursor.y)
)
//#endregion |                                             |
//#endregion |                                             |
//           |_____________________________________________|
       

draw_text(room_width-100,30,string([inputManager.mouse.X,inputManager.mouse.Y]))
// restore culling for next 3d rendering
gpu_set_cullmode(cull_clockwise)


