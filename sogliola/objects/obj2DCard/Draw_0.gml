if is_undefined(card) exit
sprite_index = card.sprite

draw_sprite_ext(card.sprite,0,x,y,scale,scale,0,c_white,1)
if marked {
   draw_set_color(c_red)
   draw_circle(x+w*scale*0.5,y+h*scale*0.5,10,false)
}

