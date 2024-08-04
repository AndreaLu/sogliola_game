items = new ds_list()
sf = -1
function Item(text,sprite,callback) constructor {
   Text = text
   Sprite = sprite
   Callback = callback
   Index = objMenuController.items.size
   objMenuController.items.Add(self)
   
   Update = function(guiSelection) {
      y = getH()/2
      x = getW()/2 + (Index-guiSelection)*160
      
      var t = abs(Index-guiSelection)
      var s = cos(pi*(-1/(t*t*t+1)+1)/2)
      var color = lerp(80,255,s*s)
      draw_sprite_ext(Sprite,Index,x,y,s,s,0,make_color_rgb(color,color,color),1)
      draw_set_halign(fa_center)
      draw_set_valign(fa_middle)
      draw_set_font(fntBasic)
      draw_set_color(c_white)
      draw_text(x,y+42,Text)
   }
}

function SubMenuController() constructor {
   surface = -1
   Update = function() {
      if !surface_exists(surface) {
         surface = surface_create(400,200)
      }
   }
}
function SettingsSMC() : SubMenuController() constructor {
   _update = Update

   menu = [
      [  function() {

         },
      function() {window_set_fullscreen(!window_get_fullscreen())}]
   ]

   Update = function() {
      _update()
      surface_set_target(surface)
      draw_clear(c_black)

      surface_reset_target()
   }
}
new Item("Gioca",sprMenu,function() {
   room_goto(room3DGame)
})
new Item("Gioca Online", sprMenu, function() {
   show_message("online non ancora sbloccato")
})
//new Item("Impostazioni", sprMenu, function() {
//   window_set_fullscreen(!window_get_fullscreen())
//})
new Item("Esci", sprMenu, function() {
   game_end(0)
})

selection = 0
guiSelection = 0