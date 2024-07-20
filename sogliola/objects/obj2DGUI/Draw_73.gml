
// Pick the choice

// pick it automatically during loading
if( true ) { // let the user pick it
   if global.options.size > 0  && global.turnPlayer == global.player {
      if sel_choice > global.options.size sel_choice = 0
      if keyboard_check_pressed(vk_down)
         sel_choice = (sel_choice + 1) % global.options.size
      if keyboard_check_pressed(vk_up) {
         sel_choice = sel_choice - 1
         if sel_choice == -1 sel_choice = global.options.size-1
      }
   
      var dy = 20
      var j = 0
      draw_rectangle_color(room_width-400-10,dy-10,room_width-20,dy-10+dy*8, c_black,c_dkgray,c_black,c_dkgray,false)
      for(var i = max(0,sel_choice-3); i<min(max(0,sel_choice-5)+7,global.options.size); i++ ) {
         draw_set_color( i==sel_choice ? c_fuchsia : c_white )
         draw_text(room_width-400,dy, ((i==sel_choice) ? "> " : "  " )+  global.options.At(i)[0])
         dy += 20
      }
   
      if keyboard_check_pressed(vk_enter) {
         var option = global.options.At(sel_choice)
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
