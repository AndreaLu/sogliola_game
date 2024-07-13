gpu_set_cullmode(cull_noculling)
var w = sprite_get_width(sprBack)
var h = sprite_get_height(sprBack)

if( idx >= 0 && idx < global.allCards.size ) {
   card = global.allCards.At(idx)
   if card.location == global.player.hand || card.location == global.player.aquarium || card.location == global.opponent.aquarium
      draw_sprite(card.sprite,0,w/2,h/2)
   else
      draw_sprite(sprBack,0,w/2,h/2)
}
gpu_set_cullmode(cull_clockwise)