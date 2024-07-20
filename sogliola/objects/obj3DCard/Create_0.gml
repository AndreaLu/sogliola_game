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
// this function is called by obj3DGUI whenever the cursor is over a card
// in the player hand
setMouseHover = function() {
   if global.hovering return;
   global.hovering = true
   mouseHover = true
   mouseHoverTimer = 1
}