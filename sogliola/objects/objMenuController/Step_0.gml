if keyboard_check_pressed(vk_right) && selection < items.size-1 {
   selection += 1
}
if keyboard_check_pressed(vk_left) && selection > 0 {
   selection -= 1
}

var delta = abs(guiSelection - selection)
guiSelection -= sign(guiSelection-selection)*min(delta,0.03)



guiSelection = lerp(guiSelection,selection,0.06)


if keyboard_check_pressed(vk_enter)
   items.At(selection).Callback()
