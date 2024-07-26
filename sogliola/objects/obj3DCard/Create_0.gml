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

// +----------------------------------------------------------------------+
// | 3D Movement variables                                                |
// +----------------------------------------------------------------------+
position = [0,0,0]
scale = [1,1,1]
mat = matrix_build_identity()
targetPos = [0,0,0]
targetMat = matrix_build_identity()
targetScal = [1,1,1]

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
   targetMat : matrix_build_identity()
}
global.drawing = false



// +----------------------------------------------------------------------+
// | Card Zoom                                                            |
// +----------------------------------------------------------------------+
prevMouseHover = false
mouseHover = false
cardZoom = false
canHover = true
canUnhover = false

global.zooming = false // true if a card is in zoom mode
global.zoomCamTransition = false 

setZoom = function() {
   if global.disableUserInput return;
   if global.zooming return;

   static camTo = [0,0,0]
   static camFrom = [0,0,0]
   global.zoomCamTransition = true
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
   global.disableUserInput = true
   new StackMoveCamera(camFrom,camTo,global.camera.FOV,0.5,function () {
      global.zoomCamTransition = false
      global.disableUserInput = false
   })

   cardZoom = true
   global.zooming = true
   
}


world = matrix_build_identity()