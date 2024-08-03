debugMode = true // TODO: setta false in produzione

#macro HINT_MBL 0
#macro HINT_MBR 1
#macro HINT_W   2
#macro HINT_S   3

function loadBlenderFromJSON(json) {
   global.Blender = json_parse(json)

   // TODO: possibile miglioramento, aggiungi una prorpietà type
   // alle struct exportate e esegui questa operazione automaticamente
   // per ogni oggetto di tipo mesh
   // Crea le matrici di rotazione per ogni mesh
   structs = [
      global.Blender.HndPl,
      global.Blender.HndPlZoom,
      global.Blender.HndOp,
      global.Blender.HndOpShowoff,
      global.Blender.DckPl,
      global.Blender.DckOp,
      global.Blender.AqPl,
      global.Blender.AqOp,
      global.Blender.Ocean
   ]
   
   
   for(var i=0;i<array_length(structs);i++) {
      var stru = structs[i]
      stru.Mat =
         matBuildCBM(
            stru.Transform.j,
            stru.Transform.i,
            stru.Transform.k,
         )
      
   }
}

// Load Blender File
var json = ""
var file = file_text_open_read("blender.json")
while( !file_text_eof(file) )
   json += " "+file_text_readln(file)
file_text_close(file)
loadBlenderFromJSON(json)


// This struct holds the informatino the 3D camera uses
// TODO: add fov info

//v3SetIP(global.Blender.CamHand.From,global.camera.From)
//v3SetIP(global.Blender.CamHand.To,global.camera.To)
global.camera = {
   From: v3Copy(Blender.CamHand.From),
   To:   v3Copy(Blender.CamHand.To),
   Up:   [0,0,1],
   FOV:  Blender.CamHand.FovY
}




function ds_list() constructor {
   _list = ds_list_create()
   size = 0
   static Insert = function(element,pos) {
      ds_list_insert(_list,pos,element)
      size += 1
   }
   
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
   static Set = function(value,pos) {
      _list[|pos] = value
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
   
   static Filter = function( check , args ) {
      for( var i=0;i<size;i++) {
         var c = _list[|i]
         if !is_undefined(args) {
            if check(c,args) return c;
         }
         else {
            if check(c) return c;
         }
      }
      return undefined;
   }
   
   static FilterAll = function( check, args ) {
      var arr = []
      var j = 0
      for( var i=0; i<size;i++) {
         var c = _list[|i]
         if check(c,args) {
            arr[@j] = c
            j+=1
         }
      }
      return arr;
   }
}


function Opponent(player) {
   return player == global.player ? global.opponent : global.player
}


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
   var json = GameGetJSON()
   if( file_exists("savedata.json") ) file_delete("savedata.json")
   var file = file_text_open_write("savedata.json")
   file_text_write_string(file,json)
   file_text_close(file)
}
function GameGetJSON() {
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
      global.onePlayerFinished
   ]
   var json = json_stringify([cards,globals])
   return json
}


function GameRestoreJson(json) {
   var data = json_parse(json) 
   var cards = data[0]
   var globals = data[1]

   // Ripristina i vlaori di tutte le carte
   for(var i=0;i<array_length(cards);i++) {
      var cardJSON = cards[i]
      var card = json_parse(cardJSON)
      var index = card[4]
      global.allCards.At(index).FromJSON(cardJSON)
   }

   // Ripristina lo stato delle variabili globali
   global.turnPlayer = globals[0] == 0 ? global.player : global.opponent
   global.turnOpponent = Opponent(global.turnPlayer)
   global.player.aquarium.protected = globals[1]
   global.opponent.aquarium.protected = globals[2]
   global.turnPassed = false
   global.choiceMade = true
   global.maxFishPlayable = globals[3]
   global.fishPlayed = globals[4]
   global.onePlayerFinished = globals[5]
   
   // Ripulisce tutte le location e le ripopola
   global.opponent.hand.Clear()
   global.opponent.aquarium.Clear()
   global.opponent.deck.Clear()
   global.player.hand.Clear()
   global.player.aquarium.Clear()
   global.player.deck.Clear()
   global.ocean.Clear()
   global.allCards.foreach( function(card) {
      if is_undefined( card.locationIndex ) {
      } else {
         card.location.AddAt(card,card.locationIndex)
      }
   })
   
}
function GameLoadJson(json) {
   random_set_seed(0) // il seed non è importante, poiché non conta ciò che sarebbe
   // successo dopo nel game da cui proviene il salvataggio, ma conta 
   // solamente avere una continuazione sempre riproducibile dai savedata
   var data = json_parse(json) 
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
}

function GameLoad() {
   random_set_seed(0) // il seed non è importante, poiché non conta ciò che sarebbe
   // successo dopo nel game da cui proviene il salvataggio, ma conta 
   // solamente avere una continuazione sempre riproducibile dai savedata
   var file = file_text_open_read("savedata.json")
   var json = file_text_read_string(file)
   file_text_close(file)
   GameLoadJson(json)
   global.canPass = global.turnPlayer == global.player
   global.choiceCount = 0
   global.locationLock = false
}

function GameOver(msg) {
   if !is_undefined(msg) {
      show_message(msg)
      game_end(0)
   } else {
      var delta = getScore(global.player) - getScore(global.opponent)
      if( delta > 0 )
         show_message("game over: you win!")
      else if( delta == 0 )
         show_message("game over: draw!")
      else
         show_message("game over: you lose!")
      game_end(0)
   }
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

function deltaTime() {
   if global.debugMode
      return 1000000/room_speed
   return delta_time;
}

function smoothstep(edge0,edge1,x){
   var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
   return t * t * (3.0 - 2.0 * t);
}

function getW() {
   static init = false
   static w = 0
   if !init {
      w = surface_get_width(application_surface)
      init = true
   }
   return w
}

function getH() {
   static init = false
   static h = 0
   if !init {
      h = surface_get_height(application_surface)
      init = true
   }
   return h
}

