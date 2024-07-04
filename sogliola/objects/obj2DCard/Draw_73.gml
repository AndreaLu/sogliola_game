/// @description Card Inspector
if( mouse_x >= x-w/2*scale && mouse_x <= x+w/2*scale &&
    mouse_y >= y-h/2*scale && mouse_y <= y+h/2*scale ) {
       
   if mouse_check_button_pressed(mb_left) {
      marked = !marked
      card.breakpoints = marked
   }
   draw_set_color(c_black)
   var vx = room_width-w*1.5-30+10
   draw_rectangle(vx-10,0,room_width,room_height,false)
   draw_set_color(c_white)
   draw_line(vx-10,0,vx-10,room_height)
   
   var dy = 10
   draw_text(vx,dy,card.name); dy += 20 + 10
   draw_sprite_stretched(sprite_index,0,vx,dy,w*1.5,h*1.5); dy += h*1.5 + 10
   
   draw_text(vx,dy,"location: "+location_str(card.location) ); dy += 20
   draw_text(vx,dy,"owner: " + (card.owner == global.player ? "Player" : "Opponent")); dy += 20
   draw_text(vx,dy,"cntrl: " + (card.controller == global.player ? "Player" : "Opponent")); dy += 20
   draw_text_ext(vx,dy,"desc: " + card.desc,20,room_width-vx-30)
   dy += string_height_ext("desc: " + card.desc,20,room_width-vx-30); dy += 20
   if( is_instanceof(card,FishCard) ) {
      draw_text(vx,dy,"value: " + string(card.val) ); dy += 20
   }
   
}