
if  global.options.size > 0 {
   if sel_choice > global.options.size sel_choice = 0
   if keyboard_check_pressed(vk_down)
      sel_choice = (sel_choice + 1) % global.options.size
   if keyboard_check_pressed(vk_up) {
      sel_choice = sel_choice - 1
      if sel_choice == -1 sel_choice = global.options.size-1
   }
   global.options.rofeachi( function( choice,i) {
      draw_set_color( i==sel_choice ? c_fuchsia : c_white )
      draw_text(room_width-300,20+i*20, ((i==sel_choice) ? "> " : "  " )+ choice[0])
   })
   
   if keyboard_check_pressed(vk_enter) {
      var option = global.options.At(sel_choice)
      if array_length(option) > 2
         option[1](option[2])
      else
         option[1]()
      global.choiceMade = true
   }
}

val = 0
global.player.aquarium._cards.foreach( function(card,ctx) {
   ctx.val += card.Val()
},self)
draw_set_color(c_white)
draw_text( room_width-200, room_height-300, string(val))

val = 0
global.opponent.aquarium._cards.foreach( function(card,ctx) {
   ctx.val += card.Val()
},self)

draw_text( room_width-200, 300, string(val))