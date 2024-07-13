if !initialized {
   initialized = true
   loadBlenderCamera()
}

if keyboard_check_pressed(vk_enter)
   surface_save(sf,"asd.png")

if surface_exists(sf) {
   idx = color_get_red(surface_getpixel(sf,window_mouse_get_x(),window_mouse_get_y()))
}
