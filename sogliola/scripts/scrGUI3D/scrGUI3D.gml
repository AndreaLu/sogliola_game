global.disableUserInput = false
stack = new ds_list()

FORWARD = [0,1,0]
RIGHT = [1,0,0]
UP = [0,0,1]


stackEnabled = true


function Stack(callback,args) constructor {
   if global.simulating return;
   done = false
   Update = function() {
      done = true
   }
   Callback = callback
   cbArgs = args
   global.stack.Add(self)
}
// guiCard: obj3DCard reference of the card to be ANIMATED!!!!
function StackCardDrawAnim(guiCard,callback) : Stack(undefined) constructor {
   if global.simulating return;
   obj = guiCard
   time = 0
   duration = 3
   _callback = callback

   var f = [0,1,0]
   var u = [0,0,-1]
   var r = v3Cross(f,u)

   var f2 = v3Copy(global.Blender.HndPl.Transform.j)
   var u2 = v3Copy(global.Blender.HndPl.Transform.k)
   var r2 = v3Copy(global.Blender.HndPl.Transform.i)

   startMat = matBuildCBM(
      global.FORWARD,global.RIGHT,global.UP,
      f,r,u
   )
   startQuat = mat2quat(startMat)
   endMat = matBuildCBM(
      global.FORWARD,global.RIGHT,global.UP,
      f2,r2,u2
      //global.Blender.HndPl.Transform.i,global.Blender.HndPl.Transform.j,global.Blender.HndPl.Transform.k
   )
   endQuat = mat2quat(endMat)

   obj.drawing = true
   startPos = v3Copy(guiCard.position)
   endPos = v3Sum(startPos,[0,0,2])
   pos = [0,0,0]
   
   Update = function() {
      time += deltaTime()/1000000
      var p = time/duration
      done = (p >= 1)

      v3LerpIP(startPos,endPos,p,pos)

      var quat = quatSlerp(startQuat,endQuat,p)
      obj.world = matrix_multiply(
         quat2mat(quat),
         matBuild(pos,[0,0,0],[1,1,1])
      )
   }

}


// location: new position of the camera
// target: new target position of the camera (lookAt)
// fov: new Fov for the camera
// duration: length of the animation in seconds
// callback: function that will be called when the anim is over
function StackMoveCamera(location,target,fov,duration,callback) : Stack(callback) constructor {
   if global.simulating return;
   _dirA = [0,0,0]
   _dirB = [0,0,0]
   _dir = [0,0,0]
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

function StackMoveCameraBlack(location,target,fov,duration,callback) : Stack(callback) constructor {
   if global.simulating return;
   _dirA = [0,0,0]
   _dirB = [0,0,0]
   _dir = [0,0,0]
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
      draw_clear(c_black)
   }
}


function StackWait(time,callback,args) : Stack(callback,args) constructor {
   if global.simulating return;
   t = 0
   duration = time
   Update = function() {
      t += deltaTime()/1000000
      done = t >= duration
   }
}
function StackAnimOppCursor(destX,destY,destZ,back) : Stack(undefined) constructor {
   if global.simulating return;
   startX = obj3DGUI.opponentCursor.x
   startY = obj3DGUI.opponentCursor.y
   dstX = destX
   dstY = destY
   dstZ = destZ
   maxSpeed = 5
   dest = [0,0,0]
   goBack = is_undefined(back) ? false : back
   Update = function() {
      worldToScreenIP(dstX,dstY,dstZ, global.matView, global.matProjection, dest)
      // Lerpa il cursore verso la destinazione con una maxspeed
      var curX = obj3DGUI.opponentCursor.x
      var curY = obj3DGUI.opponentCursor.y
      obj3DGUI.opponentCursor.x = lerp(curX,dest[0],0.05)
      obj3DGUI.opponentCursor.y = lerp(curY,dest[1],0.05)

      done = point_distance(
         obj3DGUI.opponentCursor.x,
         obj3DGUI.opponentCursor.y,
         dest[0],dest[1]) <= 1 || (goBack && obj3DGUI.opponentCursor.alpha == 0)
   }
}

function StackDisplayCardActivation(doLock,_card,callback,cbargs) : Stack(callback,cbargs) constructor {
   if global.simulating return;

   card = _card
   if !is_array(card)
      card = [card]
   if doLock
      for(var i=0;i<array_length(card);i++)
         card[i].guiCard.locationLock = true
   t = 0
   phase = 0
   dur0 = 0.4
   dur1 = 0.4
   dur2 = 0.4
   y0=getH()/2
   w = getW()
   h = getH()
   hh = 20
   sw = sprite_get_width(card[0].sprite)
   sh = sprite_get_height(card[0].sprite)
   N=8
   
   sf = surface_create(w,h)
   
   Update = function() {
      if !surface_exists(sf)
          sf = surface_create(w,h)
      surface_set_target(sf)
      draw_clear_alpha(c_white,0)
      t += deltaTime()/1000000
      var al = array_length(card)
      switch(phase) {
         case( 0 ):
            draw_set_color(c_black)
            for( var i=0;i<N;i++) {
               draw_rectangle(w - t/dur0*w +40*i ,y0-hh*(N/2-i),w,y0-hh*(N/2-i-1),false)
            }
            if t >= dur0*1.2 {
               phase = 1
               t = 0
            }
            gpu_set_blendmode(bm_add) // TODO: usa blendmode ext per togliere dove non ci sono ancora i rect
            for( var i=0;i<al;i+=1){
               draw_sprite_ext(card[i].sprite,0, w/2 - (sw+10)*((al-1)/2)+(sw+10)*i,   h/2,1.2,1.2,0,c_white,  1)//smoothstep(0,dur1*0.4,t) )
            }
            
            gpu_set_blendmode(bm_normal)
            break
         case( 1 ): // Card appearance
            draw_rectangle(0,y0-hh*N/2,w,y0-hh*(N/2-N),false)
            gpu_set_blendmode(bm_add)
            for( var i=0;i<al;i+=1){
               draw_sprite_ext(card[i].sprite,0,  w/2-(sw+10)*((al-1)/2)+(sw+10)*i,     h/2,1.2,1.2,0,c_white, 1)//smoothstep(0,dur1*0.4,t) )
            }
            gpu_set_blendmode(bm_normal)
            if t >= dur1 {
               phase = 2
               t = 0
            }
            break
         case( 2 ):
            
            for( var i=0;i<N;i++) {
               draw_rectangle(0,y0-hh*(N/2-i), w - t/dur2*w +40*i ,y0-hh*(N/2-i-1),false)
            }
            for( var i=0;i<al;i+=1){
               draw_sprite_ext(card[i].sprite,0, w/2-(sw+10)*((al-1)/2)+(sw+10)*i,h/2,1.2,1.2,0,c_white,1)
            }
            var bm = gpu_get_blendmode_ext();
            bm[0] = bm_one;
            bm[1] = bm_zero;
            gpu_set_blendmode_ext(bm);
            for( var i=0;i<N;i++) {
               draw_set_alpha(0)
               draw_rectangle( w - t/dur2*w +40*i,y0-hh*(N/2-i),w ,y0-hh*(N/2-i-1),false)
               draw_set_alpha(1)
            }
            bm[0] = bm_src_alpha
            bm[1] = bm_inv_src_alpha
            gpu_set_blendmode_ext(bm); 
            done = (t >= dur1)
            break
      }
      surface_reset_target()
      draw_surface(sf,0,0)
   }

   _callback = Callback
   Callback = function() {
      // Sblocca i cambiamenti grafici di location
      new StackWait(0.4, function(args) {
         card = args[0]
         cb = args[1]
         cbargs = args[2]
         for(var i=0;i<array_length(card);i++)
            card[i].guiCard.locationLock = false
         if !is_undefined(cb)
            cb(cbargs)
         },
      [card,_callback,cbArgs])
   }
}
// es: StackBlenderAnimLerpPos(global.Blender.AnimCardDraw.Action,1,...)
function StackBlenderAnimLerpPos(animation,duration,guicard,callback) : Stack(undefined) constructor {
   if global.simulating return;
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


function StackFlipBottle(targetRotz) : Stack() constructor {
   if global.simulating return;
   // Se non si passa l'angolo, lo si ricava automaticamente
   // Solo una votla all'inizio si passa l'angolo
   if is_undefined(targetRotz) {
      var finalAngle = global.turnPlayer == global.player ? 
         random_range(180-10,180+10) : random_range(-10,10)
      if abs(finalAngle-global.bottle.rotz) < 90 || finalAngle < global.bottle.rotz
         finalAngle += 360
      endRotz = finalAngle
   }
   else {
      endRotz = targetRotz
   }

   t = 0
   startRotz = global.bottle.rotz
   delta = endRotz - startRotz
   // durata dell'animazione proporzionale all'angolo da ruotare
   // normalizzato su 2.3 secondi
   duration = delta/180 * 0.9
   Update = function() {
      t += deltaTime()/1000000

      var p = clamp(t/duration,0,1)
      global.bottle.rotz = startRotz + 
         animcurve_channel_evaluate(animcurve_get_channel(acBottle, 0), p)*delta
      done = t/duration >= 1

   }

   Callback = function() {

      while global.bottle.rotz > 360
         global.bottle.rotz -= 360
   }
}


function StackClosingAnimation(_x,_y,_dur,callback) : Stack(callback) constructor {
   x = _x
   y = _y
   sf = -1
   t = 0
   duration = _dur
   duration2 = 2
   phase = 0
   global.drawHints = false
   Update = function() {
      if ! surface_exists(sf) {
         sf = surface_create(getW(),getH())
      }

      t += deltaTime()/1000000

      if phase == 0 {
         
         var p = t/duration
         
         var _val = animcurve_channel_evaluate(animcurve_get_channel(acEye, 0), p)
         var radius = lerp(getW()/2,0,_val)

         surface_set_target(sf)
         draw_clear(c_white)
         draw_circle_color(x,y,radius,c_black,c_black,false)
         surface_reset_target()

         gpu_set_blendmode(bm_subtract)
         draw_surface(sf,0,0)
         gpu_set_blendmode(bm_normal)
         if( p >= 1 ) {
            done = true
         }
      } else {
         p = t/duration2
         done = p >= 1
         surface_set_target(sf)
         draw_clear(c_white)
         surface_reset_target()
         gpu_set_blendmode(bm_subtract)
         draw_surface(sf,0,0)
         gpu_set_blendmode(bm_normal)
      }

   }
}