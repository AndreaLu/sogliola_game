function ds_list_create_copy(list) {
   var newList = ds_list_create()
   ds_list_copy(newList,list)
   return newList
}