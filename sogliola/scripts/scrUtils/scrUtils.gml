debugMode = true // TODO: setta false in produzione

// Load Blender File
var json = ""
var file = file_text_open_read("blender.json")
while( !file_text_eof(file) )
   json += " "+file_text_readln(file)
file_text_close(file)
Blender = json_parse(json)


global.camera = {
   From:[1,0,0],
   To:[0,1,0],
   Up:[0,0,1]
}
v3SetIP(global.Blender.CamHand.From,global.camera.From)
v3SetIP(global.Blender.CamHand.To,global.camera.To)



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
      for( var i=0;i<size;i++) {
         newList.Add(_list[|i])
      }
      return newList
   }
   static At = function(pos) {
      if( pos < 0 ) pos = size+pos
      return _list[|pos]
   }
   static RemoveAt = function(pos) {
      if( pos < 0 ) pos = size+pos
      if( pos >= size ) {
         return
      }
      ds_list_delete(_list,pos)
      size -= 1
   }
   static Remove = function(value) {
      var pos = ds_list_find_index(_list,value)
      if pos != -1
         RemoveAt(pos)
   }
   static foreach = function(func,ctx=undefined) {
      for( var i=0; i<size; i++ ) {
         if func( _list[|i], ctx) == true
            break
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
   
   // Finds the first index of a value or returns -1
   static Index = function(value) {
      return ds_list_find_index(_list,value)
   }
   
   static Filter = function( check ) {
      for( var i=0;i<size;i++) {
         var c = _list[|i]
         if check(c) return c;
      }
      return undefined;
   }
}


function Opponent(player) {
   return player == global.player ? global.opponent : global.player
}

log = ds_list()

function breakpoint() {
   return
}

function getScore(player) {
   var _score = 0
   for(var i=0;i<player.aquarium.size;i++ ) {
      _score += player.aquarium.At(i).Val()
   }
   return _score
}


function GameSave() {
   var cards = []
   for(var i=0; i<global.allCards.size; i++ ) {
      array_push(cards,global.allCards.At(i).GetJSON())
   }
   var globals = [
      global.turnPlayer == global.player ? 0 : 1,
      global.player.aquarium.protected,
      global.opponent.aquarium.protected,
      global.maxFishPlayable,
      global.fishPlayed,
      global.onePlayerFinished,
      global.srandom.value
   ]

   if( file_exists("savedata.json") ) file_delete("savedata.json")
   var file = file_text_open_write("savedata.json")
   file_text_write_string(file,json_stringify([cards,globals]))
   file_text_close(file)
}

function Random() constructor {
   value = 2
   repetitions = 0
   static GetNext = function() {
      var newBit = (((value >> 19) ^ (value >> 18) ^ (value >> 17)  ^ (value >> 14) ) & 1)
      value = ((value << 1) | newBit)
      return value
   }
   
   static SetSeed = function(_seed) {
      value = _seed
      repeat(1000) {
         GetNext()
      }
   }
   static IRandom = function(_max) {
      var mask = power( 2, ceil(log2(_max+1)+1) ) - 1
      var v 
      do {
         v = GetNext() & mask
      }
      until( v <= _max+1 && v > 0 )
      return v-1
   }
}
global.srandom = new Random()
/*
r = new Random()
repeat(10) {
   arr = array_create(10,0)
   repeat(10000) {
      var v = r.IRandom(9)
      arr[v] += 1
   }
   show_message( arr )
}*/
function GameLoad() {
   random_set_seed(0) // il seed non è importante, poiché non conta ciò che sarebbe
   // successo dopo nel game da cui proviene il salvataggio, ma conta 
   // solamente avere una continuazione sempre riproducibile dai savedata
   var file = file_text_open_read("savedata.json")
   var data = json_parse(file_text_read_string(file)) 
   file_text_close(file)
   var cards = data[0]
   var globals = data[1]
   for(var i=0;i<array_length(cards);i++) {
      var cardJSON = cards[i]
      var card = json_parse(cardJSON)
      var c;
      switch( card[0] ) {
         case CardType.ACQUARIO_PROTETTO:
            c = new CardAcquarioProtetto(undefined) 
            break;
         case CardType.FREE_SOGLIOLA:
            c = new CardFreeSogliola(undefined)
            break;
         case CardType.FURTO:
            c = new CardFurto(undefined)
            break;
         case CardType.PESCA:
            c = new CardPesca(undefined)
            break;
         case CardType.PESCA_ABBONDANTE:
            c = new CardPescaAbbondante(undefined)
            break;
         case CardType.PIOGGIA:
            c = new CardPioggia( undefined )
            break;
         case CardType.RE_SOGLIOLA:
            c = new CardReSogliola( undefined )
            break;
         case CardType.SCAMBIO_EQUIVALENTE:
            c = new CardScambioEquivalente(undefined)
            break;
         case CardType.SOGLIOLA:
            c = new CardSogliola( undefined )
            break
         case CardType.SOGLIOLA_BLOB:
            c = new CardSogliolaBlob(undefined)
            break;
         case CardType.SOGLIOLA_DIAVOLO_NERO:
            c = new CardSogliolaDiavoloNero(undefined)
            break;
         case CardType.SOGLIOLA_GIULLARE:
            c = new CardSogliolaGiullare(undefined)
            break;
         case CardType.SOGLIOLA_PIETRA:
            c = new CardSogliolaPietra(undefined)
            break;
         case CardType.SOGLIOLA_SALMONE:
            c = new CardSogliolaSalmone(undefined)
            break;
         case CardType.SOGLIOLA_VOLANTE:
            c = new CardSogliolaVolante(undefined)
            break;
         default:
            show_message("tipo non trovato!")
      }
      c.FromJSON(cardJSON) // popola i campi
      c.location.Add( c )
   }
   global.turnPlayer = globals[0] == 0 ? global.player : global.opponent
   global.turnOpponent = Opponent(global.turnPlayer)
   global.player.aquarium.protected = globals[1]
   global.opponent.aquarium.protected = globals[2]
   global.turnPassed = false
   global.choiceMade = true
   global.maxFishPlayable = globals[3]
   global.fishPlayed = globals[4]
   global.onePlayerFinished = globals[5]
   global.srandom.value = globals[6]
}

function GameOver() {
   var delta = getScore(global.player) - getScore(global.opponent)
   if( delta > 0 )
      show_message("game over: you win!")
   else if( delta == 0 )
      show_message("game over: draw!")
   else
      show_message("game over: you lose!")
   game_end(0)
}

function networkTypeString( _type ) {
   switch(_type) {
      case network_type_connect:
         return "connect"
      case network_type_disconnect:
         return "disconnect"
      case network_type_data:
         return "data"
      case network_type_non_blocking_connect:
         return "nonblocking connect"
      default:
         return "unknown type"
   }
}


function networkSendPacket( _msg ) {
   static buffer = buffer_create(128,buffer_fixed,1)
   buffer_seek(buffer,0,buffer_seek_start)
   buffer_write(buffer,buffer_string,_msg)
   network_send_raw(global.client,buffer,string_length(_msg)+1)
}