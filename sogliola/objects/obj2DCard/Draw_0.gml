if is_undefined(card) exit
sprite_index = card.sprite
draw_sprite_ext(card.sprite,0,x,y,scale,scale,0,c_white,1)

if( mouse_x >= x && mouse_x <= x+sprite_get_width(sprite_index)*scale &&
    mouse_y >= y && mouse_y <= y+sprite_get_height(sprite_index)*scale ) {
   draw_set_color(c_black)
   var vx = room_width-w*1.5-30+10
   draw_rectangle(vx-10,0,room_width,room_height,false)
   draw_set_color(c_white)
   draw_line(vx-10,0,vx-10,room_height)
   
   draw_text(vx,10,card.name)
   draw_text(vx,30,"location: "+location_str(card.location) )
   draw_text(vx,50,"owner: " + (card.owner == global.player ? "Player" : "Opponent"))
   draw_text(vx,70,"cntrl: " + (card.controller == global.player ? "Player" : "Opponent"))
   draw_text(vx,90,"desc: " + card.desc )
   draw_sprite_stretched(sprite_index,0,vx,180,w*1.5,h*1.5)
}