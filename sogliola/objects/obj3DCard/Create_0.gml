zero3=[0,0,0]
uno3=[1,1,1]

meshCard = mesh3DGLoad("graphics/card.obj.3dg")
meshBack = mesh3DGLoad("graphics/back.obj.3dg")

// card struct associated with this object
// Similarly, the card has a guiCard to reference
// this object
card = undefined

// used when the card is in the deck
randomrot = random_range(-5,5);

//#region 3D Movement
// +----------------------------------------------------------------------+
// | 3D Movement variables                                                |
// +----------------------------------------------------------------------+
position = [0,0,0]
scale = [1,1,1]
mat = matrix_build_identity()
rot = [0,0,0]
targetPos = [0,0,0]
targetMat = matrix_build_identity()
targetScal = [1,1,1]
targetRot = [0,0,0]
world = matrix_build_identity()
showingOff = false
screenPos = [-1000,-1000]

// ghost is needed to fix the mousehover glitch issue
// we draw a hidden card in the original position (not hovered)
// only in the clickbuffer to extend the hover region
ghost = {
   position : [0,0,0],
   scale : [0,0,0],
   rot : [0,0,0],
   mat : matrix_build_identity(),
   targetPos : [0,0,0],
   targetScal : [1,1,1],
   targetMat : matrix_build_identity(),
   targetRot : [0,0,0]
}
//#endregion
//#region Mouse Hover / Zoom
// +----------------------------------------------------------------------+
// | Mouse Hover / Zoom                                                   |
// +----------------------------------------------------------------------+

prevMouseHover = false
mouseHover = false      // indicates that the cursor is hovering the card
cardZoom = false        // indicates that the card is being zoomed on
canHover = true
canUnhover = false

global.zooming = false // true if a card is in zoom mode
global.zoomCamTransition = false 

setZoom = function() {
   if global.disableUserInput return;
   if global.zooming return;

   cardZoom = true
   global.zooming = true

   // Compute camTo and camFrom to make a camera transition
   static camTo = [0,0,0]
   static camFrom = [0,0,0]

   v3LC3IP(
         global.Blender.HndPlZoom.Position,
         global.Blender.HndPlZoom.Transform.j,
         [1,0,0],

         1,        // (HndPl position)
         1.2,      // (move up a little along the y axis)
         0.4*offs, // (X card offset th get the right position)

         camTo
   )
   v3LC2IP(
      camTo,
      global.Blender.HndPlZoom.Transform.k,
      1,3.5,
      camFrom
   )

   // Perform the camera transition
   global.zoomCamTransition = true
   global.disableUserInput = true
   new StackMoveCamera(camFrom,camTo,global.camera.FOV,0.5,
      function () {
         global.zoomCamTransition = false
         global.disableUserInput = false
      }
   )
}
//#endregion
// when true, the card shines. This is used to indicate that this card
// can be selected as a target during the activation of a card
selected = false 
lerpSpeed = 1