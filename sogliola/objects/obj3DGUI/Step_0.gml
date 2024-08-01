menu = []
tt += 1
if surface_exists(sf) && !global.zooming && !camTransition {
   var color
   if tt >= 5 {
      color = surface_getpixel(sf,inputManager.mouse.X,inputManager.mouse.Y)
   } else {
      color = prevColor
   }
   prevColor = color
   // Codifica clickbuffer:
   // se il colore è un rosso, si tratta di una carta
   // se il colore è blu 1 è acquario del player, blu 0.5 acquario opponent
   var red = color_get_red(color)
   var blue = color_get_blue(color)
   var green = color_get_green(color)
   if red > 0 { // è una carta
      var card = global.allCards.At(red-1)
      if !is_undefined(card) && !is_instanceof(card.location,Deck) {
         objectHover = card
      }
   } else if blue > 0 { // è un acquario
      objectHover = (blue == 255) ? global.player.aquarium : global.opponent.aquarium
   } else if green > 200 { 
      objectHover = global.radio
   } else {// niente...
      objectHover = undefined
   }
}

