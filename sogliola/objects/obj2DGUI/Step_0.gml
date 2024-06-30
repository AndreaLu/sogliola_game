if global.player.hand.size != hand.size {
   
   for( var i=0;i<global.player.hand.size;i++) {
      var card = global.player.hand.At(i)
      var skip = false
      for(var j=0;j<hand.size;j++) {
         var obj = hand.At(j)
         if( card == obj.card ) {
            skip = true
            break
         }
      }
      if !skip {
         var newCard = instance_create_layer(0,0,layer,obj2DCard)
         newCard.card = card
         newCard.image_xscale = scale
         newCard.image_yscale = scale
         hand.Add(newCard)
      }
   }
}

for(var i=0;i<hand.size;i++) {
   obj = hand.At(i)
   obj.target_x = room_width/hand.size*i
   obj.target_y = hand_y
}
show_debug_message(i)