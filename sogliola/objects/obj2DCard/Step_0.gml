if is_undefined(card) exit

var pos
switch( card.location ) {
   case global.player.hand:
      pos = global.player.hand._cards.Index(card)
      target_scale = hand_scale
      target_x = w*target_scale*pos
      target_y = room_height-h*hand_scale-20
      target_rotz = 0
      target_rotx = 0
      break
   case global.player.aquarium:
      pos = global.player.aquarium._cards.Index(card)
      target_scale = aquarium_scale
      target_x = w*target_scale*pos
      target_y = room_height-h*hand_scale-20-aquarium_scale*h-30
      target_rotz = 0
      target_rotx = 0
      break
   case global.opponent.aquarium:
      pos = global.opponent.aquarium._cards.Index(card)
      target_scale = aquarium_scale
      target_x = w*target_scale*pos
      target_y = room_height-h*hand_scale-20-aquarium_scale*h*2-120
      target_rotz = 180
      target_rotx = 0
      break
   case global.opponent.hand:
      pos = global.opponent.hand._cards.Index(card)
      target_scale = hand_scale
      target_x = w*target_scale*pos
      target_y = room_height-h*hand_scale-20-aquarium_scale*h*2-120-h*hand_scale-10
      target_rotz = 180
      target_rotx = 180
      break
   default:
      target_x = -w
      target_y = -h
}
target_x += w/2
target_y += h/2


x = lerp(x,target_x,0.1)
y = lerp(y,target_y,0.1)
scale = lerp(scale,target_scale,0.1)
rotz = lerp(rotz,target_rotz,0.1)
rotx = lerp(rotx,target_rotx,0.1)