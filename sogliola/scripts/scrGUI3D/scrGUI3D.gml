global.disableUserInput = false
stack = new ds_list()

function Stack(callback) {
   done = false
   Update = function() {}
   Callback = callback
   global.stack.Add(self)
}
// guiCard: obj3DCard reference of the card to be ANIMATED!!!!
function StackCardDrawAnim(guiCard,callback) : Stack(undefined) constructor {
   obj = guiCard
   time = 0
   duration = 3
   _callback = callback

   obj.drawing = true
   startPos = v3Copy(guiCard.position)
   endPos = v3Sum(startPos,[0,0,0.6])
   // 180,0,rand
   startrot = v3Copy(obj.rot)
   
   Update = function() {
      time += deltaTime()/1000000
      var p = time/duration
      v3LC2IP(startPos,endPos,1-p,p,obj.position)
      obj.rot[@0] = lerp(startrot[0],0,p)
      obj.rot[@1] = lerp(startrot[1],180,p)
      obj.rot[@2] = lerp(startrot[2],0,p)
      done = p >= duration
   }

   Callback = function() {
      obj.drawing = false
      if !is_undefined(_callback)
         _calback()
   }
}


// location: new position of the camera
// target: new target position of the camera (lookAt)
// fov: new Fov for the camera
// duration: length of the animation in seconds
// callback: function that will be called when the anim is over
function StackMoveCamera(location,target,fov,duration,callback) : Stack(callback) constructor {
   static _dirA = [0,0,0]
   static _dirB = [0,0,0]
   static _dir = [0,0,0]
   t = 0
   fromA = v3Copy(global.camera.From)
   fromB = v3Copy(location)
   toA = v3Copy(global.camera.To)
   toB = v3Copy(target)
   dur = duration
   startFov = global.camera.FOV
   endFov = fov
   
   v3SubIP(global.camera.To,global.camera.From,_dirA)
   v3SubIP(target,location,_dirB)
   v3NormalizeIP(_dirA,_dirA)
   v3NormalizeIP(_dirB,_dirB)

   Update = function() {
      t = min(t+deltaTime()/(1000000*dur),1)
      done = (t == 1)
      var cc = sin(t*pi-pi/2)*0.5+0.5
      var c = sin(cc*pi-pi/2)*0.5+0.5
      // c coefficient ranging between 0 and 1
      v3SlerpIP(_dirA,_dirB,c,_dir)
      v3LC2IP(fromA,fromB,1-c,c,global.camera.From)
      v3LC2IP(global.camera.From,_dir,1,1,global.camera.To)
      global.camera.FOV = lerp(startFov,endFov,c)
   }
}

// es: StackBlenderAnimLerpPos(global.Blender.AnimCardDraw.Action,1,...)
function StackBlenderAnimLerpPos(animation,duration,guicard,callback) : Stack(undefined) constructor {
   
   // Lettura argomenti
   dur = duration
   guiCard = guicard
   anim = animation
   guiCard.drawing = true
   _callback = callback
   t = 0 // da 0 a dur
   progress = 0 // da 0 a 1
   

   
   
   guicard.drawing = true
   startPos = guicard.targetPos
   
   var offs = global.player.hand.size/2
   if( frac((global.player.hand.size+1)/2) == 0 ) {
      offs -= 0.5
   }
         
   endPos = [0,0,0]
   v3LC3IP(
      global.Blender.HndPl.Position,
      global.Blender.HndPl.Transform.j,
      [1,0,0],
      1,  // posizione di partenza
      0, // mousehover
      0.4*offs, // offset carta in mano
      endPos
   )
   
   Update = function() {
      // incrementa t 
      t += deltaTime()/1000000
      progress = clamp(t/dur,0,1)
      done = (progress == 1)
      
      var channels = [
         anim.RotX,
         anim.RotY,
         anim.RotZ,
         anim.PosX,
         anim.PosY,
         anim.PosZ,
         anim.ScalX,
         anim.ScalY,
         anim.ScalZ
      ]
      var channelValue = [ // uno per ogni canale 
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0
      ]
      
      // Calcola il valore di ogni canale interpolato tra i due keyframe subito prima e dopo
      if( progress == 0 ) { // prendo il valore del primo keyframe
         for( var i=0;i<9;i++)
            channelValue[i] = channels[i][0][1]
      } else if( progress == 1) { // prendo il valore dell'ultimo keyframe
         for( var i=0;i<9;i++) {
            var channel = channels[i]
            channelValue[i] = channel[array_length(channel)-1][1]
         }
      } else { // interpolo il valore tra due keyframe o tengo buono l'ultimo se ho superato l'ultimo keyframe
         for( var c=0;c<array_length(channels); c++ ) {
            var channel = channels[c]
            var found = false
            for(var i=1;i<array_length(channel);i++) {
               var keyFrame = channel[i]
               var prevKeyFrame = channel[i-1]
               if( keyFrame[0] > progress ) {
                  found = true
                  var alpha = (progress - prevKeyFrame[0])/(keyFrame[0]-prevKeyFrame[0])
                  channelValue[c] = lerp(prevKeyFrame[1],keyFrame[1],alpha)
                  break
               }
            }
            if( !found ) // l'ultimo keyframe è prima del punto attuale... uso il suo valore comunque
               channelValue[c] = channel[array_length(channel)-1][1]
         }
      }
      
      //if( progress > 0 )  {
      //   show_message(guiCard.targetRot)
      //   show_message(channelValue)
      //}
      
      // Applico!
      guiCard.targetRot[@0] = channelValue[0]
      guiCard.targetRot[@1] = channelValue[1]
      guiCard.targetRot[@2] = channelValue[2]
      v3SetIP(guiCard.targetRot,guiCard.ghost.targetRot)
      v3LerpIP(startPos,endPos,progress,guiCard.targetPos)
      v3SetIP(guiCard.targetPos,guiCard.ghost.targetPos)
      //guiCard.targetPos[@0] = channelValue[3]*0+startPos[0]
      //guiCard.targetPos[@1] = channelValue[4]*0+startPos[1]
      //guiCard.targetPos[@2] = channelValue[5]*0+startPos[2]
   }
   
   Callback = function() {
      guiCard.drawing = false
      _callback()
   }
}
