if disable exit;
if room == roomMultiplayerWaiting {
   draw_set_color(c_white)
   draw_set_halign(fa_left)
   draw_set_valign(fa_middle)
   draw_text(100,300,"Matchmaking.. waiting for opponent")
}