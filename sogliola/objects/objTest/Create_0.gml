global.callbacks = ds_list_create()

function llol() constructor {
   
   parameter = 0
   ds_list_add(global.callbacks,self)
   static callback = function() {
      parameter = 32
      show_message("I AM HE Bass!!!!")
   }
}


function SSuper() : llol() constructor {
   
   static super_callback = callback
   static callback = function() {
      //super_callback()
      show_message(string(["I AM HE SUPER!!!!",parameter]))
   }
}


myInstance = new SSuper()
global.callbacks[|0].callback()