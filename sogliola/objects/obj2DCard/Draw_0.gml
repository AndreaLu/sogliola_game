if is_undefined(card) exit
sprite_index = card.sprite
draw_sprite_ext(card.sprite,0,x,y,image_xscale,image_yscale,0,c_white,1)

if( mouse_x >= x && mouse_x <= x+sprite_get_width(sprite_index)*image_xscale &&
    mouse_y >= y && mouse_y <= y+sprite_get_height(sprite_index)*image_yscale ) {
   draw_set_color(c_white)
   draw_text(10,10,card.name)
   draw_text(10,30,"location: "+location_str(card.location) )
   draw_text(10,50,"owner: " + (card.owner == global.player ? "Player" : "Opponent"))
   draw_text(10,70,"cntrl: " + (card.controller == global.player ? "Player" : "Opponent"))
   draw_text(10,90,"desc: " + card.desc )
}