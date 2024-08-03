items = new ds_list()
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
      draw_sprite_ext(Sprite,Index,x,y,1.5*s,1.5*s,0,make_color_rgb(color,color,color),1)
      draw_set_halign(fa_center)
      draw_text(x,y+32,Text)
   }
   
   
}

new Item("Gioca",sprHints,function() {
   room_goto(room3DGame)
})
new Item("Gioca Online", sprHints, function() {
   show_message("online non ancora sbloccato")
})
new Item("Impostazioni", sprHints, function() {

   window_set_fullscreen(!window_get_fullscreen())
})
new Item("Esci", sprHints, function() {
   game_end(0)
})

selection = 0
guiSelection = 0