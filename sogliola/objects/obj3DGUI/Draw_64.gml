


// 3d uses culling which prevents 2d graphics from being displayed, remove it
gpu_set_cullmode(cull_noculling)


/* debug: show the cards buffer */
if keyboard_check(vk_enter) && global.debugMode
   draw_surface(sf,0,0)

//draw_sprite(sprCat,0,window_mouse_get_x(),window_mouse_get_y())

var w = sprite_get_width(sprBack)
var h = sprite_get_height(sprBack)


// Draw the preview of the card
global.hoverTarget = undefined
if( idx >= 0 && idx < global.allCards.size ) {
   card = global.allCards.At(idx)
   
   global.hoverTarget = card
   draw_text(100,100,global.hoverTarget)
   if ( card.location == global.player.hand ) {
      card.guiCard.setMouseHover()
      if mouse_check_button_pressed(mb_right) {
         card.guiCard.setZoom()
      }
   }

   for(var i=0;i<global.options.size;i++) {
      var option = global.options.At(i)
      if ( option[2] == card ) {
         
         if( mouse_check_button_pressed(mb_left) ) {
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
   }
}
drawY = 100
/*
global.options.foreach( function(element,ctx) {
   draw_text(100,ctx.drawY,element[0])
   ctx.drawY += 20
}, self)*/





// restore culling for next 3d rendering
gpu_set_cullmode(cull_clockwise)
