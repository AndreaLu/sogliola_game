if is_undefined(card) exit
sprite_index = card.sprite
if rotx >= 90 sprite_index = sprBack
draw_sprite_ext(sprite_index,0,x,y,scale*abs(cos(degtorad(rotx))),scale,rotz,c_white,1)
if marked {
   draw_set_color(c_red)
   draw_circle(x,y,10,false)
}

