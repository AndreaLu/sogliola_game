
draw_set_color(c_white)
draw_text( room_width-260, room_height-300, string( getScore(global.player) ) )
draw_text( room_width-260, 300, string( getScore(global.opponent) ) )

if global.player.aquarium.protected {
   draw_rectangle_color(
      0,
      global.playerAquariumY + global.h/2 - global.h*global.aquariumScale/2,
      global.w*global.aquariumScale*8,
      global.playerAquariumY + global.h/2 + global.h*global.aquariumScale/2,
      c_aqua,c_aqua,c_aqua,c_aqua, false
   )
}

if global.opponent.aquarium.protected {
   draw_rectangle_color(
      0,
      global.opponentAquariumY + global.h/2 - global.h*global.aquariumScale/2,
      global.w*global.aquariumScale*8,
      global.opponentAquariumY + global.h/2 + global.h*global.aquariumScale/2,
      c_aqua,c_aqua,c_aqua,c_aqua, false
   )
}
