


// 3d uses culling which prevents 2d graphics from being displayed, remove it
gpu_set_cullmode(cull_noculling)


/* debug: show the cards buffer */
if keyboard_check(vk_escape) && global.debugMode
   draw_surface(sf,0,0)

//draw_sprite(sprCat,0,window_mouse_get_x(),window_mouse_get_y())

var w = sprite_get_width(sprBack)
var h = sprite_get_height(sprBack)


// +==================================================================================+
// | Interazione con il player                                                        |
// +==================================================================================+
global.hoverTarget = undefined
if( !is_undefined(objectHover) ) {
   
   if is_instanceof( objectHover, Card ) {
      card = objectHover
      global.hoverTarget = card
      
      // +----------------------------------------------------------------------------+
      // | Zoom della carta in mano                                                   |
      // +----------------------------------------------------------------------------+
      if ( card.location == global.player.hand ) {
         card.guiCard.setMouseHover()
         if mouse_check_button_pressed(mb_right) {
            card.guiCard.setZoom()
         }
      }
      // +----------------------------------------------------------------------------+
      // | Cardpicking                                                                |
      // +----------------------------------------------------------------------------+
      var options = global.options.FilterAll(function(option,args) {
         var card = args[0]
         return (option[2] == card)
      },[card])
      porcodio = options
      
      // ------------------------------------------------------------------------------
      // Primo click 
      if !watching && !global.zooming && mouse_check_button_pressed(mb_left)
         && is_undefined(global.pickingTarget) {

         if( array_length(options) > 1) {

            // Zoom nell'acquario, bisogna scegliere il target
            new StackMoveCamera(
               global.Blender.CamAq.From,
               global.Blender.CamAq.To,
               0.3, undefined
            )
            global.pickingTarget = [card]
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
      // ------------------------------------------------------------------------------
      // Secondo click in poi, su carte 
      if !watching && !global.zooming && mouse_check_button_pressed(mb_left) && 
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
         else if array_length(options) > 1 {
            // Se c'era più di una mossa, aggiunge la carta selezionata all'array
            // pickingTarget
            global.pickingTarget[@array_length(global.pickingTarget)] = card
         }
      }
   }
   // ---------------------------------------------------------------------------------
   // secondo click in poi, su acquari. Per ora gli effetti che coinvolgono gli acquari
   // hanno un solo target possibile, quindi faccio gestione semplificata. Dovessero
   // sorgere carte con più target, di cui almeno uno acquario, dovrò correggere..
   if is_instanceof( objectHover, Aquarium ) &&
      !is_undefined(global.pickingTarget) &&
      mouse_check_button_pressed(mb_left) {
      // Valuto se, tra le opzioni, si può scegliere l'acquario su cui si sta
      // passando il mouse
      aquarium = objectHover
      var a = global.options.Filter(
         function(option,args) { 
            if array_length(option) < 4 || is_array(option[3]) return false;
            return option[3] == args[0] 
         },
         [aquarium]
      )
      if !is_undefined(a) {
            // Esegue la mossa
            var option = a
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
               0.3, function() { global.pickingTarget = undefined }
            )
      }
   }

   
}

// Annullare un cardpicking in corso
if !is_undefined(global.pickingTarget) && mouse_check_button_pressed(mb_right) {
   global.pickingTarget = undefined
   // Torno alla mano, al massimo non accade niente
   new StackMoveCamera(
      global.Blender.CamHand.From,
      global.Blender.CamHand.To,
      0.3, undefined
   )
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


drawY = 100
draw_set_color(c_black)
global.options.foreach( function(option,ctx) {
   draw_text(100,ctx.drawY,option[0])
   ctx.drawY += 20
},self)


if keyboard_check_pressed( ord("W")) && !watching && global.turnPlayer == global.player {
   watching = true
   new StackMoveCamera(
      global.Blender.CamAq.From,
      global.Blender.CamAq.To,
      0.3, function() {
         time_source_start(
            time_source_create(
               time_source_game,0.1,
               time_source_units_seconds, function() {
               obj3DGUI.watchingBack = false
            })
         )
      }
   )
}

if watching && keyboard_check_pressed(ord("S")) && !watchingBack {
   watchingBack = true
   new StackMoveCamera(
      global.Blender.CamHand.From,
      global.Blender.CamHand.To,
      0.3, function() {
         obj3DGUI.watchingBack = true
         time_source_start(
            time_source_create(
               time_source_game,0.1,
               time_source_units_seconds, function() {
               obj3DGUI.watching = false
            })
         )
         
      }
   )
}

var cursor = 0;
if (mouse_check_button(mb_any)){
	cursor=1
}
draw_sprite_ext(sprCursor,cursor,window_mouse_get_x(),window_mouse_get_y(), 2,2, 0, c_white, 1)

// restore culling for next 3d rendering
gpu_set_cullmode(cull_clockwise)
