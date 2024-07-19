gpu_set_cullmode(cull_noculling)
var w = sprite_get_width(sprBack)
var h = sprite_get_height(sprBack)

if( idx >= 0 && idx < global.allCards.size ) {
   var scale = 2.5;
   card = global.allCards.At(idx)
   if card.location == global.player.hand || card.location == global.player.aquarium || card.location == global.opponent.aquarium{
	  draw_sprite_ext(card.sprite,0,w/2*scale,h/2*scale, scale, scale, 0, c_white, 1);
      draw_set_halign(fa_center)
      draw_text(w/2*scale, h*scale*0.04, card.name)
	  draw_text_ext(w/2*scale, h/2*scale*1.1, card.desc, 16 , w*scale);
	  if(struct_exists(card, "_val")) {draw_text(w/2*scale, h*scale*0.85, card._val);}

   }
   else
      draw_sprite_ext(sprBack,0,w/2*scale,h/2*scale, scale, scale, 0, c_white, 1);
}

var cursor = 0;
if (mouse_check_button(mb_any)){
	cursor=1
}
draw_sprite_ext(sprCursor,cursor,window_mouse_get_x(),window_mouse_get_y(), 2,2, 0, c_white, 1)

gpu_set_cullmode(cull_clockwise)

