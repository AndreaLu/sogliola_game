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
