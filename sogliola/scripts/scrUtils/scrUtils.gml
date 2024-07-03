function ds_list() constructor {
   _list = ds_list_create()
   size = 0
   static Add = function(element) {
      ds_list_add(_list,element)
      size += 1
   }
   static Clear = function() {
      ds_list_clear(_list)
      size = 0
   }
   static Copy = function() {
      var newList = new ds_list()
      ds_list_copy(newList._list,_list)
      newList.size = ds_list_size(newList._list)
      return newList
   }
   static At = function(pos) {
      if( pos < 0 ) pos = size+pos
      return _list[|pos]
   }
   static RemoveAt = function(pos) {
      if( pos < 0 ) pos = size+pos
      ds_list_delete(_list,pos)
      size -= 1
   }
   static Remove = function(value) {
      var pos = ds_list_find_index(_list,value)
      if pos != -1
         RemoveAt(pos)
   }
   static foreach = function(func) {
      for( var i=0; i<size; i++ ) {
         func( _list[|i] )
      }
   }
   static rofeach = function(func) {
      for( var i=size-1; i>=0; i-- ) {
         func( _list[|i] )
      }
   }
   static rofeachi = function(func) {
      for( var i=size-1; i>=0; i-- ) {
         func( _list[|i], i)
      }
   }
   
   static Shuffle = function() {
      ds_list_shuffle(_list)
   }
   
   static Destroy = function() {
      ds_list_destroy(_list)
   }
}