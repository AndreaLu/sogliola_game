if inputDisabled {
   show_debug_message(t)
   t += deltaTime()/1000000
   p = t/1
   draw_set_alpha(p)
   draw_rectangle_color(0,0,getW(),getH(),c_black,c_black,c_black,c_black,false)
   draw_set_alpha(1)
   if p >= 1
      room_goto(room3DGame)
}


truet += deltaTime()/1000000
var truep = clamp(truet/2,0,1)
draw_set_alpha(1-truep)
draw_rectangle_color(0,0,1440,900,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)