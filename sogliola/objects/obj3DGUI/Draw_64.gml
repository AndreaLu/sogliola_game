


// 3d uses culling which prevents 2d graphics from being displayed, remove it
gpu_set_cullmode(cull_noculling)


/* debug: show the cards buffer */
if keyboard_check(vk_escape) && global.debugMode
   draw_surface(sf,0,0)

//draw_sprite(sprCat,0,window_mouse_get_x(),window_mouse_get_y())

var w = sprite_get_width(sprBack)
var h = sprite_get_height(sprBack)


// Draw the preview of the card
global.hoverTarget = undefined
if( idx >= 0 && idx < global.allCards.size ) {
   card = global.allCards.At(idx)
   
   global.hoverTarget = card
   if ( card.location == global.player.hand ) {
      card.guiCard.setMouseHover()
      if mouse_check_button_pressed(mb_right) {
         card.guiCard.setZoom()
      }
   }
   
   
   // Raccogli tutte le mosse disponibili per questa carta
   var options = global.options.FilterAll(function(option,args) {
      var card = args[0]
      return (option[2] == card)
   },[card])
      

   if !global.zooming && mouse_check_button_pressed(mb_left) && is_undefined(global.pickingTarget) {

      if( array_length(options) > 1) {
         
         // Zoom nell'acquario, bisogna scegliere il target
         new StackMoveCamera(
            global.Blender.CamAq.From,
            global.Blender.CamAq.To,
            0.3, function() { global.pickingTarget = card }
         )
            
            
      } 
      if( array_length(options) == 1) {
         // Esegui la mossa, l'unica possibile
         var option = options[0]
         if( array_length(option) > 3 && (!is_undefined(option[3])) )
            option[1](option[3])
         else
            option[1]()
         global.choiceMade = true
         if global.multiplayer {
            // Send the message!
            networkSendPacket("move,"+string(sel_choice))
         }
      }
   }
   if !global.zooming && mouse_check_button_pressed(mb_left) && !is_undefined(global.pickingTarget) {
      // Verifica se card è bersagliabile da option[3]
      options = global.options.FilterAll( function(option,args) {
         return( option[2] == args[0] && option[3] == args[1] )
      },[global.pickingTarget,card])
      if array_length(options) > 1
         show_message("NON DOVREBBE MAI SUCCEDEre")
      if array_length(options) == 1 {
         // Esegue la mossa
         var option = options[0]
         if( array_length(option) > 3 && (!is_undefined(option[3])) )
            option[1](option[3])
         else
            option[1]()
         global.choiceMade = true
         if global.multiplayer {
            // Send the message!
            networkSendPacket("move,"+string(sel_choice))
         }
         new StackMoveCamera(
            global.Blender.CamHand.From,
            global.Blender.CamHand.To,
            0.3, function() {global.pickingTarget = undefined}
         )
      }
   }
}


// Passare il turno
if global.turnPlayer == global.player  && keyboard_check_pressed(vk_enter) {
   var test = global.options.Filter( function(option) {
      return option[0] == "Pass the turn"
   })
   if ! is_undefined(test) {
      // Esegui la mossa, l'unica possibile
      var option = test
      if( array_length(option) > 3 && (!is_undefined(option[3])) )
         option[1](option[3])
      else
         option[1]()
      new StackMoveCamera(
         global.Blender.CamOpponent.From,
         global.Blender.CamOpponent.To,
         0.3, undefined
      )
      global.choiceMade = true
      if global.multiplayer {
         // Send the message!
         networkSendPacket("move,"+string(sel_choice))
      }
   }
}



// restore culling for next 3d rendering
gpu_set_cullmode(cull_clockwise)
