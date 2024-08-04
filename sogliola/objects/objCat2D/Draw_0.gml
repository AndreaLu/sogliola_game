/// @description Inserisci qui la descrizione
//Puoi scrivere il tuo codice in questo editor
var dx = x-xprevious
var dy = y-yprevious

if dx < 0 {xscale=-1}
if dx > 0 {xscale=1}

if (dx==0 && dy==0) sprite_index= sprCatIdle
else sprite_index = sprCatWalk

draw_sprite_ext(sprite_index, image_index, x,y,xscale,1,0,c_white,1);