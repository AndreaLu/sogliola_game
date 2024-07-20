stack = new ds_list()
function Stack(callback) {
   done = false
   Update = function() {}
   Callback = callback
}
// location: new position of the camera
// target: new target position of the camera (lookAt)
// duration: length of the animation in seconds
// callback: function that will be called when the anim is over



function StackMoveCamera(location,target,duration,callback) : Stack(callback) constructor {
   static _dirA = [0,0,0]
   static _dirB = [0,0,0]
   static _dir = [0,0,0]
   t = 0
   fromA = v3Copy(global.camera.From)
   fromB = v3Copy(location)
   toA = v3Copy(global.camera.To)
   toB = v3Copy(target)
   dur = duration
   
   v3SubIP(global.camera.To,global.camera.From,_dirA)
   v3SubIP(target,location,_dirB)
   v3NormalizeIP(_dirA,_dirA)
   v3NormalizeIP(_dirB,_dirB)

   Update = function() {
      t = min(t+delta_time/(1000000*dur),1)
      done = (t == 1)
      var cc = sin(t*pi-pi/2)*0.5+0.5
      var c = sin(cc*pi-pi/2)*0.5+0.5
      
      if t >= 0.5 && !is_undefined(Callback) {
         Callback()
         Callback = undefined
      }
      v3SlerpIP(_dirA,_dirB,c,_dir)
      v3LC2IP(fromA,fromB,1-c,c,global.camera.From)
      v3LC2IP(global.camera.From,_dir,1,1,global.camera.To)
      //v3LC2IP(toA,toB,1-c,c,global.camera.To)
   }
   
   
   global.stack.Add(self)
   
}
