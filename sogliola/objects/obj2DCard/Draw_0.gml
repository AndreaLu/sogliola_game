if is_undefined(card) exit
sprite_index = card.sprite

draw_sprite_ext(card.sprite,0,x,y,scale,scale,rotz,c_white,1)
if marked {
   draw_set_color(c_red)
   draw_circle(x,y,10,false)
}

