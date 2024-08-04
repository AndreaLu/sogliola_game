depth = -y 


Input.right = keyboard_check(ord("D"));
Input.left = keyboard_check(ord("A"));
Input.up = keyboard_check(ord("W"));
Input.down = keyboard_check(ord("S"));
if inputDisabled {
   Input.right = false
   Input.left = false
   Input.up = false
   Input.down = false
}

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
// calcola la maxdist

_x = x
repeat(abs(xx)) {
   _x += sign(xx)
   if collision_rectangle(_x-10,y-20,_x+10,y,objColl,false,true) {
      _x -= sign(xx)
   }
}
x = _x
x = clamp(x,10,435)

// Y collision here


_y = y
repeat(abs(yy)) {
   _y += sign(yy)
   if collision_rectangle(x-10,_y-20,x+10,_y,objColl,false,true) {
      _y -= sign(yy)
   }
}
y = _y
y = clamp(y,24,298)

// Centra la view sul giocatore
view_x = clamp(x - 150,0,146); // 300 / 2
view_y = clamp(y - 100,0,100) // 200 / 2

// Imposta la posizione della camera
camera_set_view_pos(camera, view_x, view_y);

if keyboard_check_pressed(vk_enter) {
   if xx != 0 || yy != 0 {
      if collision_line(x,y-10,x+xx*5,y-10+yy*5,objCat2D2,false,true) {
         global.catSprite = sprCat3
         enterDuel()
      }
      if collision_line(x,y-10,x+xx*5,y-10+yy*5,objCat2D3,false,true) {
         global.catSprite = sprCat
         enterDuel()
      }
      
   } else {
      if collision_line(x,y-10,x*xscale*20,y-10,objCat2D2,false,true) {
         global.catSprite = sprCat3
         enterDuel()
      }
   }
}