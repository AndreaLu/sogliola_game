if is_undefined(card) exit



var pos
switch( card.location ) {

   /* HAND */
   case global.player.hand:
      pos = global.player.hand._cards.Index(card)
      
      var offs = pos-global.player.hand.size/2
      if( frac(global.player.hand.size/2) == 0 ) {
         offs -= 0.5
      }

      //if( mouseHover ) v3ScaleIP(1.5,obj3DGUI.TargetHndPlScal,targetScal)
      v3SetIP(obj3DGUI.TargetHndPlScal,targetScal)
      v3SumIP([0.4*offs,0*offs, mouseHover ? 0.3 : 0],global.Blender.HndPl.Position,targetPos)
      v3SumIP([0,10,0],obj3DGUI.TargetHndPlRot,targetRot)
      break
   case global.opponent.hand:
      pos = global.opponent.hand._cards.Index(card)
      var offs = pos-global.opponent.hand.size/2
      v3SetIP(obj3DGUI.TargetHndOpScal,targetScal)
      v3SumIP([0.3*offs,0.1*offs,0],obj3DGUI.TargetHndOpPos,targetPos)
      v3SumIP([0,offs,0],obj3DGUI.TargetHndOpRot,targetRot)
      break
      
   
   /* AQUARIUM */
   case global.player.aquarium:
      pos = global.player.aquarium._cards.Index(card)
      var offs = pos-global.player.aquarium.size/2
      v3SetIP(obj3DGUI.TargetAqPlScal,targetScal)
      v3SumIP([offs,0,0],obj3DGUI.TargetAqPlPos,targetPos)
      v3SumIP(zero3,obj3DGUI.TargetAqPlRot,targetRot)
      break
   case global.opponent.aquarium:
      pos = global.opponent.aquarium._cards.Index(card)
      var offs = pos-global.opponent.aquarium.size/2
      v3SetIP(obj3DGUI.TargetAqOpScal,targetScal)
      v3SumIP([offs,0,0],obj3DGUI.TargetAqOpPos,targetPos)
      v3SumIP(zero3,obj3DGUI.TargetAqOpRot,targetRot)
      break


   /* DECK */
   case global.opponent.deck:
      pos = global.opponent.deck.size-1-global.opponent.deck._cards.Index(card)
      v3SetIP(obj3DGUI.TargetDkOpScal,targetScal)
      v3SumIP([0,0,0.02*pos],obj3DGUI.TargetDkOpPos,targetPos)
      v3SumIP([180,0,randomrot],obj3DGUI.TargetDkOpRot,targetRot)
      break;
   case global.player.deck:
      pos = global.player.deck.size-1-global.player.deck._cards.Index(card)
      v3SetIP(obj3DGUI.TargetDkPlScal,targetScal)
      v3SumIP([0,0,0.02*pos],obj3DGUI.TargetDkPlPos,targetPos)
      v3SumIP([180,0,randomrot],obj3DGUI.TargetDkPlRot,targetRot)
      break;
      
      
   /* OCEAN */
   case global.ocean:
      pos = global.ocean.size-1-global.ocean._cards.Index(card)
      v3SetIP(obj3DGUI.TargetOceanScal,targetScal)
      v3SumIP([0,0,0.02*pos],obj3DGUI.TargetOceanPos,targetPos)
      v3SumIP([180,0,0],obj3DGUI.TargetOceanRot,targetRot)
      break;
   default:
      targetPos[@0] = 0
      targetPos[@1] = 0
      targetPos[@2] = 0
      targetScal = [1,1,1]
      targetRot = [0,0,0]
}

//pos = lerp(pos,targetPos,0.1)
v3LC2IP(position,targetPos,0.9,0.1,position)
v3LC2IP(scale,targetScal,0.9,0.1,scale)
v3LC2IP(rot,targetRot,0.9,0.1,rot)