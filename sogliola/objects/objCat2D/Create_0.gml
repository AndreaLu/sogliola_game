xx = 0; // xx and yy are velocities, for x and y respectively 
yy = 0;

spd = 3; // pixels per frame; if using delta timing it will be pixels per second
impulsespd = 0.3; // play around with this

#macro plrfriction 0.85 

Input = {};

xscale = 1;

// Imposta la dimensione della finestra di gioco
//window_set_size(900, 600);

// Crea e configura la camera
camera = camera_create();

// Imposta la vista della camera per uno zoom 3x (900/3 = 300, 600/3 = 200)
camera_set_view_size(camera, 300, 200);

// Posiziona la camera inizialmente al centro del player
camera_set_view_pos(camera, x - 150, y - 100);

// Assegna la camera alla view
view_set_camera(0, camera);
view_visible[0] = true;

room_speed = 60

inputDisabled = false
enterDuel = function() {
   inputDisabled = true
   t = 0
}