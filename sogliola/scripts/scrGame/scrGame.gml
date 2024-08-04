multiplayer = false
allCards = new ds_list() // tutte le carte esistenti si inseriscono automaticamente in questa lista

effectListeners = new ds_list()
// list of listeners:
// that is instances that implement thel listener(event) callback
chainCallback = undefined
effectChain = new ds_list()      //
effectChainRing = new ds_list()  // list of effects that triggered simultaneously (will need to sort them out into the effectChain)
// options will contain all of the moves that the player can make
// It is a list of arrays, each has this structure
// [ desc, callback, src, arguments ]
// desc: string description of the move
// callback: function that will be called if and when the move is actually
// performed by the user
// src: card struct that added this move. can be undefiend
// args: arguments (can be an array) that will be given to the callback
// can be absent or even undefined. in both cases it will not be passed to the
// callback. Generally (always?) this is used for the targets of an effect
// the card effect is put in the callback and the targets of the effect
// are passed as the array
options = new ds_list()
fishPlayed = 0                  // number of fish the player summoned this turn
maxFishPlayable = 1             // max number of fish that can be played this turn
simulating = false              // Used in opponent AI to notify that the game is in a simulation state
gameOvering = false
xCardVisible = false
function Radio() constructor {}
function Bottle() constructor {
   rotz = 0
   highlight = 0
}
radio = new Radio()
bottle = new Bottle()
//            ____________________________________
//#region    | 1.0 Events                         |
function Event(_src,_callback) constructor {
   src = _src
   callback = _callback
}
function SystemEvent(_callback) : Event(undefined,_callback) constructor {src = global.supervisor}
function EventTurnBegin() : SystemEvent(undefined) constructor {} // inizia il turno
function EventTurnDraw() : SystemEvent(undefined) constructor {} // pescata di inizio turno
function EventTurnMain() : SystemEvent(undefined) constructor {} // inizia la fase principale del turno
function EventSummon(_src,_cb,_opponent) : Event(_src,_cb) constructor { opponent = _opponent } // quando un pesce viene posizionato nell'acquario                            
function EventFree(_src,_cb,_target) : Event(_src,_cb) constructor { target = _target } // quando un pesce viene liberato nell'oceano
function EventAction(_src,_cb) : Event(_src,_cb) constructor {} // si attiva una Action Card
function EventSteal(_src,_cb,_target) : Event(_src,_cb) constructor { target = _target } // effetto che muove una sogliola dall'aquario alla mano avversaria
function EventDraw(_src,_cb) : Event(_src,_cb) constructor {} // quando si pesca per un effetto
function EventSwap(_src,_cb,_mine,_theirs) : Event(_src,_cb) constructor { mine = _mine; theirs = _theirs } // scambio di due sogliole
global.waitingExecution = false
function ExecuteOption(option,send,_callback) {
   global.waitingExecution = true
   show_debug_message( "ExecuteOption: " + option[0] )
   /* 
      option = [
         desc,
         callback,
         srcCard,
         target(s) (optional, and can be an array)
      ]
    */
   var callback = option[1]
   var sourceCard = option[2]
   var hasTarget = array_length(option) > 3 && !is_undefined(option[3])
   var targets = hasTarget ? option[3] : undefined
   global.args = [hasTarget,callback,targets,option[0]]


   // If the opponent plays a card, this goes to the showoff area
   if global.turnPlayer == global.opponent && option[0] != "Draw" && option[0] != "Pass the turn" {
      sourceCard.guiCard.showingOff = true

      // Give time for the card to reach the showoff region
      new StackWait(0.5) // wait for 0.5 seconds
      // Animazione target, se disponibile, con il cursore avversario
      cursorMoved = false
      if !is_undefined(targets) {
         if !is_array(targets) targets = [targets]
         for(var i=0;i<array_length(targets);i++) {
            var target = targets[i]
            var posX,posY
            if is_instanceof(target,Card) {
               pos = target.guiCard.position
            }
            if is_instanceof(target,Aquarium) {
               if target == global.player.aquarium {
                  pos = global.Blender.TrgtPl.Position
               } else {
                  pos = global.Blender.TrgtOp.Position
               }
            }
            new StackAnimOppCursor(pos[0],pos[1],pos[2]) 
            new Stack(function() { obj3DGUI.opponentCursor.subimg = 1})
            new StackWait(0.1)
            new Stack(function() { obj3DGUI.opponentCursor.subimg = 0})
            new StackWait(0.1)
            new Stack(function() { obj3DGUI.opponentCursor.subimg = 1})
            new StackWait(0.1)
            new Stack(function() { obj3DGUI.opponentCursor.subimg = 0})
            // cursor click!
         }
         new StackAnimOppCursor(0,20,2,true)

         if( is_instanceof(sourceCard,ActionCard) ) {
            new StackDisplayCardActivation(true,sourceCard)
         } else {
            global.chainCallback = sourceCard
         }
      } else {
         if( is_instanceof(sourceCard,ActionCard) ) {
            new StackDisplayCardActivation(true,sourceCard)
         }
      }
      new StackWait(0.1,function(card) {
         card.showingOff = false
      },sourceCard.guiCard)
   }

   
   new Stack( function() {
      show_debug_message("done execute option" + global.args[3])
      
      var hasTarget = global.args[0]
      var callback = global.args[1]
      var targets = global.args[2]
      if( hasTarget ) {
         callback(targets)
      } else {
         callback()
      }
      global.choiceMade = true
      global.waitingExecution = false
      global.choiceCount += 1
      
   })
   new Stack(_callback)

   
   if global.multiplayer && send {
      // Send the message!
      networkSendPacket("move,"+string(sel_choice))
   }
   
}
function SimulateOption(option) {

   var callback = option[1]
   var sourceCard = option[2]
   var hasTarget = array_length(option) > 3 && !is_undefined(option[3])
   var targets = hasTarget ? option[3] : undefined

   if( hasTarget ) {
      callback(targets)
   } else {
      callback()
   }
   global.choiceMade = true
   global.waitingExecution = false
   
}
//#endregion |                 |
//#region    | 2.0 Collections                    |
function CardCollection(_owner) constructor {
   owner = _owner
   _cards = new ds_list()
   size = 0
   static Add = function(_card) {
      if !is_undefined(_card.location) {
         _card.location.Remove(_card)
      }
      _cards.Add( _card )
      _card.location = self
      _card.controller = owner
      size = _cards.size
   }

   static AddAt = function(value, _pos) {
      while( _pos + 1 > _cards.size ) {
         _cards.Add(undefined)
         size += 1
      }
      _cards.Set(value,_pos)
   }
   static At = function(pos) {
      return _cards.At(pos)
   }
   static Remove = function(card) {
      _cards.Remove(card)
      size = _cards.size
   }
   
   static Random = function() {
      if size == 0 return undefined;
      return _cards.At(irandom(size-1))
   }

   static Clear = function() {
      _cards.Clear()
      size = 0
   }

   static IndexCheck = function(check)  {
      for( var i=0;i<size;i+=1 ) {
         if check( _cards.At(i) ) return i;
      }
      return undefined
   }
}

function Hand(owner) : CardCollection(owner) constructor {}
function Aquarium(owner) : CardCollection(owner) constructor { protected = false }
function Ocean() : CardCollection(undefined) constructor { owner = global.supervisor }
function Deck(owner) : CardCollection(owner) constructor {
   // Il mazzo è una lista, dove l'indice 0 è la carta in cima
   // ovvero quella che si pescherà
      
   static Shuffle = function() {
      _cards.Shuffle()
   }
   static Draw = function() {
      card = _cards.At(0)
      _cards.RemoveAt(0)
      return card;
   }
}

function location_to_str( location ) {
   if location == global.player.deck        return "Player deck"
   if location == global.opponent.deck      return "Opponent deck"
   if location == global.player.hand        return "Player hand"
   if location == global.opponent.hand      return "Opponent hand"
   if location == global.player.aquarium    return "Player aquarium"
   if location == global.opponent.aquarium  return "Opponent aquarium"
   if location == global.ocean              return "The ocean"
   return "undefined"
}

function str_to_location( _str ) {
   if( _str == "Player deck" ) return global.player.deck
   if( _str == "Opponent deck" ) return global.opponent.deck
   if( _str == "Player hand" ) return global.player.hand
   if( _str == "Opponent hand" ) return global.opponent.hand
   if( _str == "Player aquarium" ) return global.player.aquarium
   if( _str == "Opponent aquarium" ) return global.opponent.aquarium
   if( _str == "The ocean" ) return global.ocean
   return undefined
}
//#endregion |                 |
//#region    | 3.0 Actors                         |
function Actor() constructor {
   
   static StartEvent = function( event ) {

      global.effectChainRing.Add( [self,event] )
      
      // Se qualcuno vuole aggiungersi alla chain, mette tutto in
      // global.effectChainRing
      while( global.effectChainRing.size  > 0 ) {
         global.effectChain.Add( global.effectChainRing.Copy() )
         global.effectChainRing.Clear()
         // foreach effect stored in the last chain ring
         var ring = global.effectChain.At(-1)
         for( var j=0; j< ring.size; j++) {
            var _event = ring.At(j)
            for( var k=global.effectListeners.size-1; k>=0; k--) {
               global.effectListeners.At(k).listener( _event[1] )
            }
         }
      }
      
      // Ora la effectChain è stata popolata correttamente...
      // La eseguo a ritroso
      for(var i=global.effectChain.size-1;i>=0;i--) {
         var ring = global.effectChain.At(i)
         var evt = ring.At(0)[1]
         if ring.size > 1 {
            var cards = []
            for( var k=0;k<ring.size;k+=1) {
               var cc =ring.At(k)[0]
               if is_instanceof(cc,Card)
                  cards[@array_length(cards)] = cc
            }
            new stackDisplayCardActivation(true,cards)
            global.chainCallback = undefined
         //} //else if !is_undefined(global.chainCallback) && !is_instanceof(evt,EventSummon) {
           // new StackDisplayCardActivation(true,global.chainCallback)
           // global.chainCallback = undefined
         } else {
            var src = ring.At(0)
            src = src[0]
            var evt = ring.At(0)[1]
            if (is_instanceof(evt,EventSteal) && is_instanceof(src,CardSogliolaDiavoloNero)) || 
               (is_instanceof(evt,EventFree) && is_instanceof(src,CardSogliolaPietra) ) {
               if !global.simulating
                  evt.target.guiCard.locationLock = true
               new StackDisplayCardActivation(false,src, function(args) {
                  new StackWait(0.25, function(args) {
                     args[0].locationLock = false
                  }, args)
               },[evt.target.guiCard])
            }
         }

         for( var j=0;j<ring.size; j++) {
            _event = ring.At(j)[1]
            var srcCard = ring.At(j)[0]
            if !is_undefined( _event.callback ) {
               //if is_instanceof(srcCard,Card)
               //   new StackDisplayCardActivation(srcCard)
               _event.callback(_event)
            }
         }
      }

      // Cleanup the effect chain
      global.effectChain.rofeach( function(ring) {
         ring.Destroy()
      })
      global.effectChain.Clear()

      
   }
}
function Player() : Actor() constructor {
   deck = new Deck(self);
   hand = new Hand(self);
   aquarium = new Aquarium(self);
   static Draw = function() {
      if( deck.size > 0 ) {
         var card = deck.Draw()
         if !global.simulating
            card.guiCard.locationLock = true
         hand.Add( card );
         if !global.simulating 
            new StackWait(0.3, function(card) {card.guiCard.locationLock = false}, card)
      }  
   }
}
function Supervisor() : Actor() constructor {}
//#endregion |                      |
//#region    | 4.0 Cards                          |
//#region    |    4.1 Base Classes                |

function Card(_name,_owner,_controller, _location, _sprite, _type) : Actor()  constructor {
   name = _name
   owner = _owner
   controller = _controller
   location = _location
   type = _type
   sprite = _sprite
   global.effectListeners.Add(self)
   global.allCards.Add(self)
   index = global.allCards.size-1
   if( room == room2DGame ) {
      guiCard = instance_create_layer(-1000,-1000,"Instances",obj2DCard)
   }
   else {
      guiCard = instance_create_layer(0,0,"Instances",obj3DCard)
   }
   guiCard.card = self
   
   listener = function( event ) {}
   GetJSON = function() {
      // Stabilisci in che posizione del deck si trova, se si trova nel deck
      global.tmp = index
      var locIdx = location.IndexCheck( function(card) { return card.index == global.tmp; } )
      if is_undefined(locIdx) {
         show_debug_message("undef")
      }
      var data = [
         type,
         owner == global.player ? 0 : 1,
         controller == global.player ? 0 : 1,
         location_to_str( location ),
         index,
         locIdx
      ]
      return json_stringify( data) 
   }
   
   FromJSON = function(json) {
      var data = json_parse( json )
      owner =  (data[1] == 0 ) ? global.player : global.opponent
      controller = (data[2] == 0 ) ? global.player : global.opponent
      location = str_to_location( data[3] )
      locationIndex = data[5]
   }
   breakpoints = false
}
function FishCard(_name,_owner, _controller, _location, _sprite, _value, _desc, _type) : Card(_name,_owner,_controller,_location, _sprite, _type) constructor {
   desc = _desc
   _val = _value
   Val = function() {
      return _val
   }
   Summon = function() {
      StartEvent( new EventSummon(self, function(event) {
         event.src.controller.aquarium.Add(event.src)
         global.fishPlayed += 1
         if event.src.controller.aquarium.size == 7 {
            GameOverSequence(1)
         }
      }, false) )
   }
   SummonToOpponent = function() {
      StartEvent( new EventSummon(self, function(event) {
         Opponent(event.src.controller).aquarium.Add(event.src)
         global.fishPlayed += 1
      }, true) )
   }
   listener = function( event ) {
      if( is_instanceof(event,EventTurnMain) ) {
         if( location ==  global.turnPlayer.hand &&
             global.fishPlayed < global.maxFishPlayable && 
             global.turnPlayer.aquarium.size < 7 ) {
            global.options.Add( ["Summon target"+name,Summon, self, global.turnPlayer.aquarium] ) 
         }
      }
   } 
}
function ActionCard(_name,_owner, _controller, _location, _sprite, _effectText, _type) : Card(_name,_owner,_controller,_location,_sprite, _type) constructor {
   desc = _effectText;
   
   
   listener = function( event ) {
      if( is_instanceof(event, EventTurnMain) ) {
         if( location == global.turnPlayer.hand ) {
            global.options.Add( ["Activate "+name,Activate,self] ) 
         }
      }
   }
   // Cards that inherit from ActionCard must implement the Effect function
   Effect = function(_evt) { }
   Activate = function() {
      StartEvent( new EventAction(self, Effect) )
      global.ocean.Add( self )
   }
   
}
function FishEffectCard(_name,_owner, _controller, _location, _sprite, _value, _effectText, _type)  : FishCard(_name,_owner,_controller,_location,_sprite, _value, _effectText, _type) constructor {
   
}

enum CardType {
   SOGLIOLA,
   PESCA,
   PESCA_ABBONDANTE,
   PIOGGIA,
   SOGLIOLA_BLOB,
   RE_SOGLIOLA,
   SOGLIOLA_PIETRA,
   SOGLIOLA_GIULLARE,
   ACQUARIO_PROTETTO,
   SCAMBIO_EQUIVALENTE,
   SOGLIOLA_DIAVOLO_NERO,
   SOGLIOLA_VOLANTE,
   SOGLIOLA_SALMONE,
   FREE_SOGLIOLA,
   FURTO
}
//#endregion
//#region    |    4.2 Card Database               |
//#region    |       4.2.01 Sogliola              |
function CardSogliola(owner) : FishCard(
   "Sogliola", owner, undefined, undefined, sprSogliola, 5,
   "",
   CardType.SOGLIOLA
) constructor {
}
//#endregion |                      |
//#region    |       4.2.02 Pesca                 |
function CardPesca(owner) : ActionCard(
   "Pesca", owner, undefined, undefined, sprPesca, "Pesca 2 carte",
   CardType.PESCA
) constructor {
   Effect = function() {
      controller.Draw()
      controller.Draw()
   }
}
//#endregion |                               |
//#region    |       4.2.03 Pesca Abbondante      |
function CardPescaAbbondante(owner) : ActionCard(
   "Pesca Abbondante", owner, undefined, undefined, sprPescaAbbondante,
   "Pesca 3 carte",
   CardType.PESCA_ABBONDANTE
) constructor {
   Effect = function() {
      controller.Draw()
      controller.Draw()
      controller.Draw()
   }
}
//#endregion |                               |
//#region    |       4.2.04 Pioggia               |
function CardPioggia(owner) : ActionCard(
   "Pioggia di Pesci", owner, undefined, undefined, sprPioggiaDiPesci, 
   "Per questo turno, puoi giocare un'altra Sogliola.",
   CardType.PIOGGIA
) constructor {
   Effect = function() {
      global.maxFishPlayable += 1
   }
}
//#endregion
//#region    |       4.2.05 Sogliola Blob         | 
function CardSogliolaBlob(owner) : FishEffectCard(
   "Sogliola Blob", owner, undefined, undefined, sprSogliolaBlob, -10,
   "Puo' essere giocato in ogni acquario",
   CardType.SOGLIOLA_BLOB
) constructor {
   // Override the listener
   listener = function( event ) {
      if( is_instanceof(event,EventTurnMain) ) {
         if( location ==  global.turnPlayer.hand 
         && global.fishPlayed < global.maxFishPlayable) {
            if global.turnPlayer.aquarium.size < 7
               global.options.Add( ["Summon "+name,Summon,self,controller.aquarium] )
            if global.turnOpponent.aquarium.size < 7 && !global.turnOpponent.aquarium.protected
               global.options.Add( ["Summon "+name+" to opponent",SummonToOpponent,self,Opponent(controller).aquarium])
         }
      }
   }
}
//#endregion
//#region    |       4.2.06 Re Sogliola           |
function CardReSogliola(owner) : FishEffectCard(
   "Re Sogliola",owner,undefined, undefined, sprReSogliola, 0,
   "+3 al valore per ogni altra sogliola nell'acquario",
   CardType.RE_SOGLIOLA
) constructor {

   Val = function() {
      if location == global.ocean
         return 0
      tmpVal = _val
      controller.aquarium._cards.foreach(function(card,ctx) {
         if card == ctx return;
         ctx.tmpVal += 3;
      },self)
      
      return tmpVal
   }
}
//#endregion
//#region    |       4.2.07 Sogliola Diavolo Nero |
function CardSogliolaDiavoloNero(owner) : FishEffectCard(
   "Sogliola Diavolo Nero", owner, undefined, undefined, sprSogliolaDiavoloNero,3,
   "Quando entra nell'acquario, ruba una sogliola casuale dall'acquario avversario e la aggiunge al tuo",
   CardType.SOGLIOLA_DIAVOLO_NERO
) constructor {
   _listener = listener
   listener = function( event ) {
      _listener( event )
      if( is_instanceof(event,EventSummon) && event.src == self ) {
         var opponent = Opponent(controller)
         if( opponent.aquarium.size > 0 && !opponent.aquarium.protected ) {
            // Check if target is valid: if the opponent has "re sogliola"
            // and "sogliola pagliaccio" cannot target the former
            var hasClown = !is_undefined(opponent.aquarium._cards.Filter( 
               function(card) { 
                  return is_instanceof(card,CardSogliolaGiullare)
               })
            )
            var target = opponent.aquarium.Random()
            while hasClown && is_instanceof(target, CardReSogliola) {
               target = opponent.aquarium.Random()
            }
            global.effectChainRing.Add( [self,new EventSteal(self,Steal,target)] )
         }
      }
      Steal = function(event) {
         controller.hand.Add(event.target)
      }
   }
}
//#endregion
//#region    |       4.2.08 Sogliola Pietra       |
function CardSogliolaPietra(owner) : FishEffectCard(
   "Sogliola Pietra", owner, undefined, undefined, sprSogliolaPietra, 2,
   "Giocabile in ogni acquario. Quando entra nell'acquario, libera un'altra sogliola casuale",
   CardType.SOGLIOLA_PIETRA
) constructor {
   listener = function( event ) {
      if( is_instanceof(event,EventTurnMain) ) {
         if( location ==  global.turnPlayer.hand 
         && global.fishPlayed < global.maxFishPlayable) {
            if global.turnPlayer.aquarium.size < 8
               global.options.Add( ["Summon "+name,Summon,self,controller.aquarium] )
            if global.turnOpponent.aquarium.size < 8 && !global.turnOpponent.aquarium.protected
               global.options.Add( ["Summon "+name+" to opponent",SummonToOpponent,self,Opponent(controller).aquarium])
         }
      }
      
      
      if( is_instanceof(event,EventSummon) && event.src == self) {
         var aquarium = event.opponent ? Opponent(controller).aquarium : controller.aquarium
         if( aquarium.size > 0 ) {

            var hasClown = !is_undefined(aquarium._cards.Filter( 
               function(card) { 
                  return is_instanceof(card,CardSogliolaGiullare)
               })
            )
            target = self
            while ( (hasClown && is_instanceof(target, CardReSogliola)) || 
               target == self ) {
               target = aquarium.Random()
            }
            
            global.effectChainRing.Add( [self,new EventFree(self,Free,target)] )
         }
      }
   }
   

   Free = function(event) {
      global.ocean.Add(event.target)
   }
}
//#endregion
//#region    |       4.2.09 Sogliola Volante      |
function CardSogliolaVolante(owner) : FishEffectCard(
   "Sogliola Volante", owner, undefined, undefined, sprSogliolaVolante, 5,
   "Quando questa sogliola viene liberata nell'oceano, pesca 2 carte.",
   CardType.SOGLIOLA_VOLANTE
) constructor {
   _listener = listener
   listener = function( event ) {
      _listener( event )
      if breakpoints breakpoint()
      if( is_instanceof(location,Aquarium) && is_instanceof(event,EventFree) && event.target == self ) {
         global.effectChainRing.Add( [self,new EventDraw(self,Draw)] ) 
      }
   }
   Draw = function(_evt) {
      controller.Draw()
      controller.Draw()
   }
}
//#endregion |                                    |
//#region    |       4.2.10 Sogliola Salmonata    |
function CardSogliolaSalmone(owner) : FishEffectCard(
   "Sogliola Salmonata", owner, undefined, undefined, sprSogliolaSalmone, 4,
   "Quando questa sogliola viene rubata, pesca 2 carte.",
   CardType.SOGLIOLA_SALMONE
) constructor {
   _listener = listener
   listener = function( event ) {
      _listener( event )
      if( is_instanceof(location,Aquarium) && is_instanceof(event,EventSteal) && event.target == self ) {
         var evt = new EventDraw(self,Draw)
         evt.target = ( location == global.player.aquarium ) ? global.player : global.opponent
         global.effectChainRing.Add( [self,evt] ) 
      }
   }
   
   Draw = function(event) {
      event.target.Draw()
      event.target.Draw()
   }
}
//#endregion |                                    |
//#region    |       4.2.11 Free Sogliola         |
function CardFreeSogliola(owner) : ActionCard(
   "Free Sogliola", owner, undefined, undefined, sprFreeSogliola,
   "Scegli una sogliola da un acquario e liberala nell'oceano",
   CardType.FREE_SOGLIOLA
) constructor {
   listener = function( event ) {
      if( location != global.turnPlayer.hand ) return;
      if( !is_instanceof(event,EventTurnMain) ) return;
      if( global.player.aquarium.size + global.opponent.aquarium.size == 0) return;
      
      // Check if Sogliola Giullare is in the Aquarium
      var giullare = controller.aquarium._cards.Filter(
         function(c) { return is_instanceof(c,CardSogliolaGiullare) }
      ) != undefined
      for( var i=0;i<controller.aquarium.size;i++;) {
         var target = controller.aquarium.At(i)
         if( giullare and is_instanceof(target,CardReSogliola) ) continue;
         global.options.Add(["Free '"+target.name+"' own", Activate, self, target] )
      }
      
      // Check if Sogliola Giullare is in the Aquarium
      var opp = Opponent(controller)
      if( !opp.aquarium.protected ) {
         var giullare = opp.aquarium._cards.Filter(
            function(c) { return is_instanceof(c,CardSogliolaGiullare) }
         ) != undefined
         for( var i=0;i<opp.aquarium.size;i++;) {
            var target = opp.aquarium.At(i)
            if( giullare and is_instanceof(target,CardReSogliola) ) continue;
            global.options.Add(["Free '"+target.name+"' opponent", Activate, self, target] )
         }
      }
   }
   
   Effect = function(event) {
      global.ocean.Add( event.target )
   }
   Activate = function( target ) {
      StartEvent( new EventFree(self,Effect,target) )
      global.ocean.Add( self )
   }
}
//#endregion
//#region    |       4.2.12 Furto                 |
function CardFurto(owner) : ActionCard(
   "Furto", owner, undefined, undefined, sprFurto,
   "Ruba una sogliola da un acquario e aggiungila alla tua mano",
   CardType.FURTO
) constructor {
   target = undefined
   /* overload operatore listener di ActionCard */
   listener = function( event ) {
      if( location != global.turnPlayer.hand ) return;
      if( !is_instanceof(event,EventTurnMain) ) return;
      
      if( global.player.aquarium.size + global.opponent.aquarium.size == 0) return;
      
      
      // Check if Sogliola Giullare is in the Aquarium
      var giullare = controller.aquarium._cards.Filter(
         function(c) { return is_instanceof(c,CardSogliolaGiullare) }
      ) != undefined
      
      for( var i=0;i<controller.aquarium.size;i++;) {
         var target = controller.aquarium.At(i)
         if( giullare and is_instanceof(target,CardReSogliola) ) continue;
         global.options.Add(["Activate Steal on '"+target.name+"' own", Activate, self, target] )
      }
      
      var opponent = Opponent(controller)
      if( ! opponent.aquarium.protected ) {
         giullare = opponent.aquarium._cards.Filter(
            function(c) { return is_instanceof(c,CardSogliolaGiullare) }
         ) != undefined
         for( var i=0;i<opponent.aquarium.size;i++;) {
            var target = opponent.aquarium.At(i)
            if( giullare and is_instanceof(target,CardReSogliola) ) continue;
            global.options.Add(["Activate Steal on '"+target.name+"' opponent", Activate, self, target] )
         }
      }
   }
   
   
   Effect = function(event) {
      controller.hand.Add( event.target )
   }
   Activate = function( _target ) {
      StartEvent( new EventSteal(self,Effect,_target) )
      global.ocean.Add( self )
   }
}
//#endregion
//#region    |       4.2.13 Sogliola Giullare     |
function CardSogliolaGiullare(owner) : FishEffectCard(
   "Sogliola Giullare", owner, undefined, undefined, sprSogliolaGiullare, 3,
   "Se si trova in un Acquario col Re Sogliola, quest'ultimo non puo' essere Rubato né Liberato",
   CardType.SOGLIOLA_GIULLARE
) constructor {
}
//#endregion
//#region    |       4.2.14 Acquario Protetto     |
function CardAcquarioProtetto(owner) : ActionCard(
   "Acquario Protetto", owner, undefined, undefined, sprAcquarioProtetto,
   "I pesci nel tuo acquario sono protetti fino al tuo prossimo turno",
   CardType.ACQUARIO_PROTETTO
) constructor {
   Effect = function() {
      controller.aquarium.protected = true
   }
}
//#endregion
//#region    |       4.2.15 Scambio Equivalente   |
function CardScambioEquivalente(owner) : ActionCard(
   "Scambio Equivalente", owner, undefined, undefined, sprScambioEquivalente,
   "Scambia una sogliola del tuo acquario con un'altra dell'acquario avversario",
   CardType.SCAMBIO_EQUIVALENTE
) constructor {
   listener = function( event ) {
      if( location != global.turnPlayer.hand ) return;
      if( !is_instanceof(event,EventTurnMain) ) return;
      var opp = Opponent(controller)
      if( opp.aquarium.size == 0 || controller.aquarium.size == 0 || opp.aquarium.protected ) return;
      controller.aquarium._cards.foreach( function(card,ctx) {
         var opp = Opponent(ctx.controller)
         ctx.card1 = card
         opp.aquarium._cards.foreach( function(card,ctx) {
            global.options.Add([
               "Activate swap '"+ctx.card1.name+"' <-> '"+card.name+"'",
               Activate,
               self,
               [ctx.card1, card]])
         },ctx)
      },self)
   }
   Effect = function(event) {
      var me = event.mine.controller
      var them = event.theirs.controller
      me.aquarium.Add(event.theirs)
      them.aquarium.Add(event.mine)
   }
   Activate = function( _args ) {
      StartEvent( new EventSwap(self,Effect,_args[0],_args[1]) )
      global.ocean.Add(self)
   }
}
//#endregion |                                    |
//#endregion |                                    |
//#endregion |                                    |
//           |____________________________________|


function GameOverSequence(t) {
   // t can be 0 (end of deck seqeuence) or 1 (filled aquarium sequence)
   global.gameOvering = true
   global.disableUserInput = true

   if t == 0 { // DECK OVER GAME END
      with( obj3DCard ) locationLock = true;
      new StackWait(0.3)
      if global.turnPlayer == global.opponent {
         new StackMoveCamera(global.Blender.CamDeckOp.From, global.Blender.CamDeckOp.To,global.Blender.CamDeckOp.FovY,0.5)
      } else {
         new StackMoveCamera(global.Blender.CamDeck.From, global.Blender.CamDeck.To,global.Blender.CamDeck.FovY,0.5)
      }
      repeat(3) {
         new StackWait( 0.4 )
         new Stack( function() {global.xCardVisible = true })
         new StackWait( 0.5 )
         new Stack( function() {global.xCardVisible = false})
      }
      new StackWait( 0.1, function() {
         new StackMoveCamera(
            global.Blender.CamCat.From, global.Blender.CamCat.To,global.Blender.CamCat.FovY,1,
            function() {
               new StackClosingAnimation( 790, 430, 2.2, function() {
                  new StackMoveCameraBlack(
                     global.Blender.CamHand.From, global.Blender.CamHand.To, global.Blender.CamHand.FovY,2
                     ,function() {GoBack()}
                  )
               })
            })
      })
   }
   else { // AQUARIUM COMPLETE GAME END
      new StackWait(0.5, function() {with( obj3DCard ) locationLock = true;})
      new StackMoveCamera(
         global.Blender.CamAq.From, global.Blender.CamAq.To, global.Blender.CamAq.FovY,
         0.5, function() {
            global.turnPlayer.aquarium._cards.foreach( function(card) {
               card.guiCard.superSelected = true
            })
            new StackWait(3)
            new StackMoveCamera(
               global.Blender.CamCat.From, global.Blender.CamCat.To,global.Blender.CamCat.FovY,1,
               function() {
                  new StackClosingAnimation( 790, 430, 2.2, function() {
                     new StackMoveCameraBlack(
                        global.Blender.CamHand.From, global.Blender.CamHand.To, global.Blender.CamHand.FovY,2
                        ,function() {GoBack()}
                     )
                  })
               }
            )
         }
      )

   }
   
   
   /*
   //new StackWait(1)
   if( t == 0) {
      // GAME OVER BY DECK FINISHED!
      if global.turnPlayer == global.Player {
         new StackMoveCamera(
            global.Blender.CamDeck.From,
            global.Blender.CamDeck.To,
            global.Blender.CamDeck.FovY,
            0.3,
         )
         new StackWait(2)
      }
      else
      {
         new StackMoveCamera(
            global.Blender.CamDeckOp.From,
            global.Blender.CamDeckOp.To,
            global.Blender.CamDeckOp.FovY,
            0.3,
         )
         new StackWait(2)
      } 
   } else {
      // GAME OVER BY AQUARIUM FINISHED!

      new StackMoveCamera(
         global.Blender.CamAq.From,
         global.Blender.CamAq.To,
         global.Blender.CamAq.FovY,
         0.3,
      )
      global.turnPlayer.aquarium.foreach( function(card) {card.guiCard.selected = true} )

   }*/
   //global.simulating = true // impedisce altri stack di aggiungersi
}