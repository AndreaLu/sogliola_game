Input.right = keyboard_check(ord("D"));
Input.left = keyboard_check(ord("A"));
Input.up = keyboard_check(ord("W"));
Input.down = keyboard_check(ord("S"));

/// STEP EVENT
// xxx and yyy can be thought of as acceleration 
var xxx = (Input.right - Input.left); // Input.left is just however you're getting your left movement input (same with right)
xx += xxx * impulsespd; // impulsespd is how fast the movement is added to xx
xx = clamp(xx, -spd, spd); // clamp will return a number that is "clamped" between the 2nd parameter (-spd here) and 3rd parameter
if (xxx == 0) xx *= plrfriction; // if no input slow player down with friction
if (abs(xx) <= 0.05) xx = 0; // if velocity is too small just make it 0

// all the same but with Y
yyy = (Input.down - Input.up);
yy += yyy * impulsespd;
yy = clamp(yy, -spd, spd);
if (yyy == 0) yy *= plrfriction;
if (abs(yy) <= 0.05) yy = 0;

if (xx != 0 && yy != 0) { // if the player is moving 
	var dir = point_direction(0, 0, xx, yy); // get the direction of the player
	var mag = min(sqrt(sqr(xx) + sqr(yy)), spd); // get the magnitude of the movement vector (or if it's too big, just the normal speed)
	xx = lengthdir_x(mag, dir); // set x velocity to the direction with the magnitude (thereby limiting the player speed diagonally)
	yy = lengthdir_y(mag, dir); 
}

// ideally you would do collisions here, but it depends on how you're doing it (objects vs. tiles)
// when you do collide however, set xx and yy to the minimum distance you can travel (which might be 0)
// X collision here
x += xx;

// Y collision here
y += yy;

// Centra la view sul giocatore
var view_x = x - 150; // 300 / 2
var view_y = y - 100; // 200 / 2

// Imposta la posizione della camera
camera_set_view_pos(camera, view_x, view_y);