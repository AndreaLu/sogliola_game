// TestBench
list = new ds_list()
list.Add( 32 )
newList = list.Copy()
newList.Add(84)

output = []
for(var i=0;i<list.size;i++)
   output[@array_length(output)] = list.At(i)

list.Clear()
for(var i=0;i<list.size;i++)
   output[@array_length(output)] = list.At(i)

for(i=0;i<newList.size;i++)
   output[@array_length(output)] = newList.At(i)

if (!array_equals( output, [32,32,84] )) 
   show_message( "FAIL0" )

output = []
list = new ds_list()
j = 0
repeat(2) {
   j+=20
   nlist = new ds_list()
   list.Add(nlist)
   for(var i=0;i<5;i++) {
      nlist.Add(i+j)
   }
}

list.foreach( function(el) {
   el.foreach( function( el) {
      output[@array_length(output)] = el
   })
})

if !array_equals(output,[20,21,22,23,24,40,41,42,43,44])
   show_message( "FAIL1" )

if !is_instanceof(list,ds_list) || is_instanceof(list,Hand) {
   show_message( "Fail2")
}

count=0
list.foreach( function(el) {
   el.foreach( function( el) {
      count += el
   })
})
if count != 320
   show_message("FAIL3")


function Class(param) constructor {
   parameter = param*2
   Func = function() {
      show_message(parameter)
   }
}

ccc = new Class(12)
ccc.Func()
f = ccc.Func
f()
