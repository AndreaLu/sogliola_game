gpu_set_cullmode(cull_noculling)

items.foreach( function(item) {
   item.Update(objMenuController.guiSelection)
})

gpu_set_cullmode(cull_clockwise)

