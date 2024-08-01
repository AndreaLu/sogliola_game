if obj3DGUI.objectHover == global.radio {
	obj3DGUI.menu[@array_length(obj3DGUI.menu)] = [HINT_MBL,"Accendi RADIO!"]
	if obj3DGUI.inputManager.keys.MBL
		global.radioOn = !global.radioOn;
}

if (global.radioOn) {
	audio_resume_sound(radioSound);
}
else {
	audio_pause_sound(radioSound);
}