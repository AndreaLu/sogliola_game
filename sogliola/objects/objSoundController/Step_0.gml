if keyboard_check_pressed(vk_space) {
	global.radioOn = !global.radioOn;
}

if (global.radioOn) {
	audio_resume_sound(radioSound);
}
else {
	audio_pause_sound(radioSound);
}