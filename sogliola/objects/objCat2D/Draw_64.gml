if inputDisabled {
   t += deltaTime()/1000000
   if phase == 1 {
      show_debug_message(t)
      p = t/1
      draw_set_alpha(p)
      draw_rectangle_color(0,0,getW(),getH(),c_black,c_black,c_black,c_black,false)
      draw_set_alpha(1)
      if p >= 1 {
         phase = 2
         t = 0
      }
   } else {
      p = clamp(p/1,0,1)
      draw_rectangle_color(0,0,getW(),getH(),c_black,c_black,c_black,c_black,false)
      draw_set_alpha(p)
      draw_set_halign(fa_center)
      draw_set_valign(fa_middle)
      draw_set_font(fntValue)
      draw_set_color(c_white)
      var sep = 30
      var dx = getW()/2
      var dy = getH()/2 - array_length(info)/2*sep
      for(var i=0;i<array_length(info);i++) {
         if is_undefined(info[i]) {
            dy += 10
            continue
         }
         draw_text(dx,dy,info[i])
         dy += sep
      }
      draw_set_alpha(1)

      if keyboard_check_pressed(vk_enter)
         room_goto(room3DGame)
   }
   
      
}


truet += deltaTime()/1000000
var truep = clamp(truet/2,0,1)
draw_set_alpha(1-truep)
draw_rectangle_color(0,0,1440,900,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)