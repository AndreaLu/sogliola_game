// +----------------------------------------------------------------------+
// | Step Event                                                           |
// +----------------------------------------------------------------------+
/*
   This is where the card reacts to the game
 */
 
if is_undefined(card) exit
if !locationLock {
   guiLocation = card.location
}

var pos

switch( guiLocation ) {
//            ______________________________
//#region    | 1.0 Compute Target Transform |
//#region    |    1.1 Hand                  |
//#region    |       1.1.1 Player           |
   case global.player.hand:
      // ------------------------------------------------------------------
      // Rendered Card
      // ------------------------------------------------------------------

      if !cardZoom  {// Calculate the offset (wrt. middle of the hand)
         pos = global.player.hand._cards.Index(card)
         offs = pos-global.player.hand.size/2
         if( frac(global.player.hand.size/2) == 0 ) {
            offs -= 0.5
         }
         // Target Rot/Scal/Pos/Mat
         v3Set(targetRot,0,0,0)
         v3ScaleIP(cardZoom ? 3 : 1,[1,1,1], targetScal)
         v3LC3IP(
            global.Blender.HndPl.Position,
            global.Blender.HndPl.Transform.j,
            [1,0,0],
            1,  // posizione di partenza
            (mouseHover || cardZoom) ? (cardZoom ? 1.4 : 0.6) : 0,
            0.4*offs, // offset carta in mano
            targetPos
         )
         targetMat = cardZoom ?
            global.Blender.HndPlZoom.Mat :
            global.Blender.HndPl.Mat

      } else {
         v3Set(targetRot,0,0,0)
         tmp = [0,0,0]
         v3Set(targetScal,1,1,1)
         v3SubIP(global.Blender.CamHand.To,global.Blender.CamHand.From,tmp)
         v3NormalizeIP(tmp,tmp)
         v3LC2IP(global.Blender.CamHand.From,tmp,1,3,targetPos)
         targetMat = global.Blender.HndPlZoom.Mat

      }

      // ------------------------------------------------------------------
      // Ghost Card
      // ------------------------------------------------------------------
      //targetRot = [0,0,0]
      //v3Set(targetRot,  0,0,cardZoom ? 0 : 0.3)
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
      
      ghost.targetRot = [0,0,0]
      ghost.targetMat = global.Blender.HndPl.Mat

      break
   //#endregion
//#region    |       1.1.2 Opponent         |
   case global.opponent.hand:
      pos = global.opponent.hand._cards.Index(card)
      offs = pos-global.opponent.hand.size/2
      if( frac(global.player.hand.size/2) == 0 ) {
         offs -= 0.5
      }
      if showingOff {
         v3SetIP(obj3DGUI.TargetHndOpScal,targetScal)
         v3SetIP(global.Blender.HndOpShowoff.Position,targetPos)
         v3Set(targetRot,0,0,0)
         targetMat = global.Blender.HndOpShowoff.Mat
      } else {
         v3SetIP(obj3DGUI.TargetHndOpScal,targetScal)
         v3SumIP([0.3*offs,0,0],global.Blender.HndOp.Position,targetPos)
         v3SumIP([0,3,0],zero3,targetRot)
         //targetRot = [0,3,0]
         targetMat = global.Blender.HndOp.Mat
      }
      break
   //#endregion
//#endregion |                              |
//#region    |    1.2 Aquarium              |
   /* AQUARIUM */
   case global.player.aquarium:
      pos = global.player.aquarium._cards.Index(card)
      offs = pos-global.player.aquarium.size/2+0.5
      var t = current_time/1000+0.5*offs
      var bobbing = sin(t)*0.02;
      var xbobbing = cos(t)*0.1;
      v3SetIP(obj3DGUI.TargetAqPlScal,targetScal)
      v3SumIP([offs+xbobbing,0,bobbing],global.Blender.AqPl.Position,targetPos)
      v3Set(targetRot,0,0,xbobbing*13)
      targetMat = global.Blender.AqPl.Mat
      break;
   case global.opponent.aquarium:
      pos = global.opponent.aquarium._cards.Index(card)
      offs = pos-global.opponent.aquarium.size/2+0.5
      var t = current_time/1000+0.5*offs
      var bobbing = sin(t)*0.02;
      var xbobbing = cos(t)*0.1;
      v3SetIP(obj3DGUI.TargetAqOpScal,targetScal)
      v3SumIP([offs+xbobbing,0,bobbing],global.Blender.AqOp.Position,targetPos)
      v3Set(targetRot,0,0,xbobbing*13)
      targetMat = global.Blender.AqOp.Mat
      break;
//#endregion
//#region    |    1.3 Deck                  |
   case global.opponent.deck:
      pos = global.opponent.deck.size-1-global.opponent.deck._cards.Index(card)
      v3SetIP(obj3DGUI.TargetDkOpScal,targetScal)
      v3SumIP([0,0,0.02*pos],global.Blender.DckOp.Position,targetPos)
      v3SumIP([0,0,randomrot],zero3,targetRot)
      targetMat = global.Blender.DckOp.Mat
      break;
   case global.player.deck:
      pos = global.player.deck.size-1-global.player.deck._cards.Index(card)
      v3SetIP(obj3DGUI.TargetDkPlScal,targetScal)
      v3SumIP([0,0,0.02*pos],global.Blender.DckPl.Position,targetPos)
      v3SumIP([0,0,randomrot],zero3,targetRot)
      targetMat = global.Blender.DckPl.Mat
      break;
//#endregion
//#region    |    1.4 Ocean                 |
   case global.ocean:
      pos = global.ocean.size-1-global.ocean._cards.Index(card)
      v3SetIP(obj3DGUI.TargetOceanScal,targetScal)
      v3SumIP([0,0,0.02*pos],global.Blender.Ocean.Position,targetPos)
      v3SumIP([180,0,0],zero3,targetRot)
      targetMat = global.Blender.Ocean.Mat
      break;
//#endregion
//#region    |    1.5 Other                 |
   default:
      targetPos[@0] = 0
      targetPos[@1] = 0
      targetPos[@2] = 0
      targetScal = [1,1,1]
      targetRot = [0,0,0]
      targetMat = matrix_build_identity()

   
      v3SetIP(zero3,ghost.targetPos)
      v3SetIP(uno3,ghost.targetScal)
      ghost.targetMat = matrix_build_identity()

}
//#endregion
//#region    |    1.6 Ghost                 |
// Disable ghosts when the card is not in the player hand
// TODO: can be improved just by disabling draw now that ghosts
// are rendered in a separate buffer
if card.location != global.player.hand {
   v3SetIP(position,ghost.position)
   v3SetIP(rot,ghost.rot)
   ghost.mat = matrix_build_identity()
   v3SetIP(scale,ghost.scale)
   v3SetIP(targetPos,ghost.targetPos)
   v3SetIP(targetScal,ghost.targetScal)
   v3SetIP(targetRot,ghost.targetRot)
   ghost.targetMat = matrix_build_identity()
}
//#endregion
//#endregion |                              |
//#region    | 2.0 Rendering Interpolation  |
//#region    |    2.1 Rendering             |



v3LerpIP(position,targetPos,lerpSpeed,position)
v3LerpIP(scale,targetScal,lerpSpeed,scale)
v3LerpIP(rot,targetRot,lerpSpeed,rot)
targetMat2 = matrix_multiply(
   matBuild(zero3,rot,uno3),
   targetMat
)
// TODO: possible improvement: keep in memory the quat and 
// interpolate it, only compute the targetMat quat
var q0 = mat2quat(mat)
var q1 = mat2quat(targetMat2)

mat = matrix_multiply(
   quat2mat(quatSlerp(q0,q1,lerpSpeed)),
   matBuild(position,zero3,uno3)
)
zoomTime = 0
startPos = v3Copy(position)



// TODO: for some reason, applying the scale in this way
// makes the card go crazy, whereas in the test3d room it works..
// suspect some memory accumulation effect
//mat = matrix_multiply(
//   matBuild(zero3,zero3,scale),
//   mat_tmp
//)
//#endregion
//#region    |    2.2 Ghost                 |
v3LerpIP(ghost.position,ghost.targetPos,lerpSpeed,ghost.position)
v3LerpIP(ghost.scale,ghost.targetScal,lerpSpeed,ghost.scale)
v3LerpIP(ghost.rot,ghost.targetRot,lerpSpeed,ghost.rot)
q0 = mat2quat(ghost.mat)
q1 = mat2quat(ghost.targetMat)
ghost.mat = matrix_multiply(
   quat2mat(quatSlerp(q0,q1,lerpSpeed)),
   matBuild(ghost.position,zero3,ghost.scale)
)
//#endregion
//#region    |    2.3 System                |
// The first iteration of the step event has lerpSpeed to 1 to
// make all the cards immediately reach their target values, now
// put it back to a reasonable values
lerpSpeed = 0.06
//#endregion |                             |
//#endregion |                              |
//#region    | 3.0 MouseHover / Zoom        |
var objHov = obj3DGUI.objectHover
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
   if obj3DGUI.inputManager.keys.MBR && !global.zoomCamTransition  {
      obj3DGUI.objectHover = undefined
      cardZoom = false
      global.disableUserInput = true
      new StackWait(
         //global.Blender.CamHand.From,
         //global.Blender.CamHand.To,
         //global.Blender.CamHand.FovY,
         0.3,function () { 
            global.zooming = false
            global.disableUserInput = false
         }
      )
   }
}
//#endregion
//#region    | 4.0 Highlight                |
/* 
 TODO: performance improvement; selected could be setup only on mouse click..
 not in the step event of this card. Otherwise, a check could be added
 to make sure global.pickingTarget changed since last time
 selected was setup
*/
selected = false
if( !is_undefined(global.pickingTarget) ) {
   var a = global.options.Filter(
      function(option,args) {
         if array_length(option) < 4 || option[2] != global.pickingTarget[0]
            return false
         
         if( !is_array(option[3]) ) {
            return ( option[3] == args[0] )
         } else {
            // if option[3] is an array (multiple targets), make sure
            // that both args[0] is in the array but also every
            // element of global.pickingTarget[1:]
            if !array_contains(option[3], args[0]) return false;
            for( var i=1;i<array_length(global.pickingTarget);i++) {
               if !array_contains(option[3],global.pickingTarget[i])
                  return false;
            }
            return true;
         }
         
      }, [card]
   )
   selected = !is_undefined(a)
   if array_contains(global.pickingTarget,card) selected = false
}
//#endregion |                              |
//           |______________________________|

