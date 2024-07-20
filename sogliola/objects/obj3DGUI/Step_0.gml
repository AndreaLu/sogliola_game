
if surface_exists(sf) {
   idx = color_get_red(surface_getpixel(sf,window_mouse_get_x(),window_mouse_get_y()))
}

if global.stack.size > 0 {
   var stackChain = global.stack.At(0)
   stackChain.Update()
   if stackChain.done {
      if !is_undefined(stackChain.Callback) {
         stackChain.Callback()
      }
      global.stack.RemoveAt(0)
   }
}

