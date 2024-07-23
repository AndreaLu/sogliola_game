if is_undefined(card) exit



var pos

if !drawing {
   
   switch( card.location ) {

      /* HAND */
      case global.player.hand:
         pos = global.player.hand._cards.Index(card)
      
         offs = pos-global.player.hand.size/2
         if( frac(global.player.hand.size/2) == 0 ) {
            offs -= 0.5
         }

         v3ScaleIP(cardZoom ? 1.2 : 1, obj3DGUI.TargetHndPlScal, targetScal)
         v3LC3IP(
            global.Blender.HndPl.Position,
            global.Blender.HndPl.Transform.j,
            [1,0,0],
            1,  // posizione di partenza
            (mouseHover || cardZoom) ? (cardZoom ? 1.4 : 0.6): 0, // mousehover
            0.4*offs, // offset carta in mano
            targetPos
         )
         v3SumIP([0,cardZoom ? 0 : 3,0],global.Blender.HndPl.Rotation,targetRot)
      
         // Ghost values
         v3ScaleIP( 1, obj3DGUI.TargetHndPlScal, ghost.targetScal)
         v3LC3IP(
            global.Blender.HndPl.Position,
            global.Blender.HndPl.Transform.j,
            [1,0,0],
            1,  // posizione di partenza
            0, // mousehover
            0.4*offs, // offset carta in mano
            ghost.targetPos
         )
         v3SumIP([0,cardZoom ? 0 : 5,0],global.Blender.HndPl.Rotation,ghost.targetRot)
         break

      case global.opponent.hand:
         pos = global.opponent.hand._cards.Index(card)
         offs = pos-global.opponent.hand.size/2
         if( frac(global.player.hand.size/2) == 0 ) {
            offs -= 0.5
         }
         v3SetIP(obj3DGUI.TargetHndOpScal,targetScal)
         v3SumIP([0.3*offs,0.1*offs,0],global.Blender.HndOp.Position,targetPos)
         v3SumIP([0,offs,0],global.Blender.HndOp.Rotation,targetRot)
         break


      /* AQUARIUM */
      case global.player.aquarium:
      
         pos = global.player.aquarium._cards.Index(card)
         offs = pos-global.player.aquarium.size/2+0.5
         var t = current_time/1000+0.5*offs
         var bobbing = sin(t)*0.02;
         var xbobbing = cos(t)*0.1;
         v3SetIP(obj3DGUI.TargetAqPlScal,targetScal)
         v3SumIP([offs+xbobbing,0,bobbing],global.Blender.AqPl.Position,targetPos)
         v3SumIP([0,0,xbobbing*30],global.Blender.AqPl.Rotation,targetRot)
         break
      
      case global.opponent.aquarium:
         pos = global.opponent.aquarium._cards.Index(card)
         offs = pos-global.opponent.aquarium.size/2+0.5
         var t = current_time/1000+0.5*offs
         var bobbing = cos(t)*0.02;
         var xbobbing = sin(t)*0.1;
         v3SetIP(obj3DGUI.TargetAqOpScal,targetScal)
         v3SumIP([offs+xbobbing,0,bobbing],global.Blender.AqOp.Position,targetPos)
         v3SumIP(zero3,global.Blender.AqOp.Rotation,targetRot)
         break


      /* DECK */
      case global.opponent.deck:
         pos = global.opponent.deck.size-1-global.opponent.deck._cards.Index(card)
         v3SetIP(obj3DGUI.TargetDkOpScal,targetScal)
         v3SumIP([0,0,0.02*pos],global.Blender.DckOp.Position,targetPos)
         v3SumIP([180,0,randomrot],global.Blender.DckOp.Rotation,targetRot)
         break;
      case global.player.deck:
         pos = global.player.deck.size-1-global.player.deck._cards.Index(card)
         v3SetIP(obj3DGUI.TargetDkPlScal,targetScal)
         v3SumIP([0,0,0.02*pos],global.Blender.DckPl.Position,targetPos)
         v3SumIP([180,0,randomrot],global.Blender.DckPl.Rotation,targetRot)
         break;
      
      
      /* OCEAN */
      case global.ocean:
         pos = global.ocean.size-1-global.ocean._cards.Index(card)
         v3SetIP(obj3DGUI.TargetOceanScal,targetScal)
         v3SumIP([0,0,0.02*pos],global.Blender.Ocean.Position,targetPos)
         v3SumIP([180,0,0],global.Blender.Ocean.Rotation,targetRot)
         break;
      default:
         targetPos[@0] = 0
         targetPos[@1] = 0
         targetPos[@2] = 0
         targetScal = [1,1,1]
         targetRot = [0,0,0]
      
         v3SetIP(zero3,ghost.targetPos)
         v3SetIP(uno3,ghost.targetScal)
         v3SetIP(zero3,ghost.targetRot)
   }

   if card.location != global.player.hand {
      v3SetIP(position,ghost.position)
      v3SetIP(rot,ghost.rot)
      v3SetIP(scale,ghost.scale)
      v3SetIP(targetPos,ghost.targetPos)
      v3SetIP(targetRot,ghost.targetRot)
      v3SetIP(targetScal,ghost.targetScal)
   }
}

//pos = lerp(pos,targetPos,0.1)
v3LC2IP(position,targetPos,0.9,0.1,position)
v3LC2IP(scale,targetScal,0.9,0.1,scale)
v3LC2IP(rot,targetRot,0.9,0.1,rot)

v3LC2IP(ghost.position,ghost.targetPos,0.9,0.1,ghost.position)
v3LC2IP(ghost.scale,ghost.targetScal,0.9,0.1,ghost.scale)
v3LC2IP(ghost.rot,ghost.targetRot,0.9,0.1,ghost.rot)



// +----------------------------------------------------------------------------+
// | Zoom della carta in mano                                                   |
// +----------------------------------------------------------------------------+
var objHov = obj3DGUI.objectHover
var prevHover = mouseHover
if ( !is_undefined(objHov) && objHov == card && 
     objHov.location == global.player.hand && canHover ) {
   mouseHover = true
   canUnhover = true
   canHover = false
   time_source_start(
      time_source_create(
         time_source_game,
         0.5, time_source_units_seconds,
         function(obj) {
            obj.canHover = true
         },[self]
      )
   )
}

if is_instanceof(objHov,Card) && objHov != card  {
   mouseHover = false
}
if is_undefined(objHov) || !is_instanceof(objHov,Card) && canUnhover {
   mouseHover = false
   canUnhover = false
}


// Uscire dalla modalità card zoom
if cardZoom {
   if mouse_check_button_pressed(mb_right) {
      cardZoom = false
      new StackMoveCamera(
         global.Blender.CamHand.From,
         global.Blender.CamHand.To,
         global.Blender.CamHand.FovY,
         0.3,function () { global.zooming = false }
      )
   }
}




