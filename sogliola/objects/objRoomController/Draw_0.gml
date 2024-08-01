for(var i=0;i<array_length(menu); i+= 1) {
   x = window_get_width()/2 + (i-selection)*200
   y = window_get_height()/2
   draw_set_halign(fa_center)
   draw_sprite_ext( menu[i][1],i,x,y,menu[i][2],menu[i][2],0,c_white,1)
   draw_text(x,y+40,menu[i][0])
   
   
   trgtScale = (selection == i) ? 1.5 : 0.3
   menu[i][2] = lerp(menu[i][2],trgtScale,0.05)
}


if keyboard_check_pressed(vk_enter) {
   switch( menu[selection][0] ) {
      case "Gioca":
         room_goto(room3DGame)
         break
      case "Esci":
         game_end(0)
         break
      case "Impostazioni":
         break;
      case "Gioca Online":
         break;
      default:
         show_message("voce meno non riconosciuta")
         break
   }
}