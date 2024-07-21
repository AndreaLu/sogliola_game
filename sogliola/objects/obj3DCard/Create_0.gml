meshCard = mesh3DGLoad("graphics/card.obj.3dg")
meshBack = mesh3DGLoad("graphics/back.obj.3dg")
scale =[0.2,0.2,0.2]
card = undefined
position = [0,0,0]
scale = [1,1,1]
rot = [0,0,0]
targetPos = [0,0,0]
targetRot= [0,0,0]
targetScal = [1,1,1]
zero3=[0,0,0]

randomrot = random_range(-5,5);

mouseHover = false
mouseHoverTimer = 0
alreadyHover = false
global.hovering = false
global.hoverTarget = undefined
cardZoom = false
// this function is called by obj3DGUI whenever the cursor is over a card
// in the player hand
setMouseHover = function() {
   if mouseHover || global.hovering || global.zooming return;
   global.hovering = true
   mouseHover = true
   time_source_start(
      time_source_create(
         time_source_game,
         0.03, time_source_units_seconds,
         function(obj) {
            with( obj3DCard ) {
               mouseHover = false
            }
            global.hovering = false
            obj.mouseHover = global.hoverTarget == obj.card
         },[self]
      )
   )
}


// +----------------------------------------------------------------------------+
// | Zoom della carta in mano                                                   |
// +----------------------------------------------------------------------------+
global.zooming = false // true if a card is in zoom mode

setZoom = function() {
   if global.zooming return;

   static camTo = [0,0,0]
   static camFrom = [0,0,0]
   
   v3LC3IP(
         global.Blender.HndPl.Position,
         global.Blender.HndPl.Transform.j,
         [1,0,0],
         1, // position
         1.2, // j
         0.4*offs, // x
         camTo
   )
   v3LC2IP(
      camTo,
      global.Blender.HndPl.Transform.k,
      1,3.5,
      camFrom
   )
   
   new StackMoveCamera(camFrom,camTo,0.5,undefined)

   cardZoom = true
   global.zooming = true
   
}