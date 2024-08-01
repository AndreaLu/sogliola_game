if keyboard_check_pressed(vk_right) && selection < array_length(menu)-1 {
   selection += 1
}
if keyboard_check_pressed(vk_left) && selection > 0 {
   selection -= 1
}