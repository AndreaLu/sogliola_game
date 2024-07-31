if obj3DGUI.inputManager.keys.MBL && obj3DGUI.objectHover == global.radio {
	global.radioOn = !global.radioOn;
}

if (global.radioOn) {
	audio_resume_sound(radioSound);
}
else {
	audio_pause_sound(radioSound);
}