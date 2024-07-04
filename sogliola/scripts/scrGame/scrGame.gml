effectListeners = new ds_list()
// list of listeners:
// that is instances that implement the following callback:
// listener( EventType, actor, effectIndex )
//   EventType: type of the effect that has been activated
//   actor: actor which activated the effect
//   effectIndex: index of the effect in the previous scan chain, in case it is affected
//                by this effect

effectChain = new ds_list()
effectChainRing = new ds_list()
options = new ds_list()
fishPlayed = 0                  // number of fish the player summoned this turn
maxFishPlayable = 1               // max number of fish that can be played this turn

enum EventType {
   TURN_BEGIN,    // inizia il turno
   TURN_DRAW,     // pescata di inizio turno
   TURN_MAIN,     // inizia la fase principale del turno
   SUMMON,        // quando un pesce viene posizionato nell'acquario
   POSTSUMMON,    // dopo che il pesce è stato posizionato
   FREE,          // quando un pesce viene liberato nell'oceano
   ACTION,        // si attiva una Action Card
   PASSIVE,       // sono effetti continui automatici tipo quello del re sogliola
}

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
   static At = function(pos) {
      return _cards.At(pos)
   }
   static Remove = function(card) {
      _cards.Remove(card)
      size = _cards.size
   }
}

function Hand(owner) : CardCollection(owner) constructor {}
function Aquarium(owner) : CardCollection(owner) constructor {}
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


function location_str( location ) {
   if location == global.player.deck        return "Player deck"
   if location == global.opponent.deck      return "Opponent deck"
   if location == global.player.hand        return "Player hand"
   if location == global.opponent.hand      return "Opponent hand"
   if location == global.player.aquarium    return "Player aquarium"
   if location == global.opponent.aquarium  return "Opponent aquarium"
   if location == global.ocean              return "The ocean"
   return "undefined"
}

function Actor() constructor {
   
   static Event = function( _effect, _EventType ) {

      global.effectChainRing.Add(  [_effect,_EventType,self,undefined] )

      // Se qualcuno vuole aggiungersi alla chain, mette tutto in
      // global.effectChainRing
      while( global.effectChainRing.size  > 0 ) {
         global.effectChain.Add( global.effectChainRing.Copy() )
         global.effectChainRing.Clear()
         // foreach effect stored in the last chain ring
         var ring = global.effectChain.At(-1)
         for( var j=0; j< ring.size; j++) {
            var effect = ring.At(j)
            for( var k=global.effectListeners.size-1; k>=0; k--) {
               global.effectListeners.At(k).listener( effect[1], effect[2], k )
            }
         }
      }
      
      // Ora la effectChain è stata popolata correttamente...
      // La eseguo a ritroso
      for(var i=global.effectChain.size-1;i>=0;i--) {
         var ring = global.effectChain.At(i)
         for( var j=0;j<ring.size; j++) {
            effect = ring.At(j)
            if !is_undefined( effect[0] ) 
               effect[0](effect[3])
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
      hand.Add( deck.Draw() );
   }
}
function Supervisor() : Actor() constructor {}

function Card(_name,_owner,_controller, _location, _sprite) : Actor()  constructor {
   name = _name
   owner = _owner
   controller = _controller
   location = _location
   sprite = _sprite
   global.effectListeners.Add(self)
   
   guiCard = instance_create_layer(-1000,-1000,"Instances",obj2DCard)
   guiCard.card = self
   
   listener = function( eventType, actor, effectIndex ) {}
   
   breakpoints = false
}
function FishCard(_name,_owner, _controller, _location, _sprite, _value, _desc) : Card(_name,_owner,_controller,_location, _sprite) constructor {
   desc = _desc
   val = _value
   Summon = function() {
      Event( function() {
         owner.aquarium.Add(self)
         global.fishPlayed +=1
      }, EventType.SUMMON, undefined )
      Event( undefined, EventType.POSTSUMMON, undefined)
   }
   SummonToOpponent = function() {
      Event( function() {
         var opponent = owner == global.player ? global.opponent : global.player
         opponent.aquarium.Add(self)
         global.fishPlayed +=1
      }, EventType.SUMMON )
      Event( undefined, EventType.POSTSUMMON, undefined)
   }
   listener = function( eventType, actor, effectIndex ) {
      if( eventType == EventType.TURN_MAIN ) {
         if( location ==  global.turnPlayer.hand &&
             global.fishPlayed < global.maxFishPlayable && 
             global.turnPlayer.aquarium.size < 8 ) {
            global.options.Add( ["Summon "+name,Summon] ) 
         }
      }
   } 
}
function ActionCard(_name,_owner, _controller, _location, _sprite, _effectText) : Card(_name,_owner,_controller,_location,_sprite) constructor {
   desc = _effectText;
   /* Cards that inherit from ActionCard must implement the Effect function */
   
   
   listener = function( eventType, actor, effectIndex ) {
      if( eventType == EventType.TURN_MAIN ) {
         if( location == global.turnPlayer.hand ) {
            global.options.Add( ["Activate "+name,Activate] ) 
         }
      }
   }
   static Effect = function() {
   }
   Activate = function() {
      Event( Effect, EventType.ACTION )
      global.ocean.Add(self)
   }
}
function FishEffectCard(_name,_owner, _controller, _location, _sprite, _value, _effectText)  : FishCard(_name,_owner,_controller,_location,_sprite, _value, _effectText) constructor {
   
}

// -----------------------------------------------------------------------------+
// Card database                                                                |
// -----------------------------------------------------------------------------+
function CardSogliola(owner) : FishCard(
   "Sogliola", owner, undefined, undefined, sprSogliola, 5,
   "Ora è piatta; leggende narrano che un tempo non lo fosse. Che pesce nobile!"
) constructor {
}
function CardPesca(owner) : ActionCard(
   "Pesca", owner, undefined, undefined, sprPesca, "Pesca 2 carte"
) constructor {
   Effect = function() {
      controller.Draw()
      controller.Draw()
   }
}
function CardPioggia(owner) : ActionCard(
   "Pioggia di Pesci", owner, undefined, undefined, sprPioggia, 
   "Per questo turno, puoi giocare due carte Sogliola"
) constructor {
   Effect = function() {
      global.maxFishPlayable = 2
   }
}
function CardSogliolaBlob(owner) : FishEffectCard(
   "Sogliola Blob", owner, undefined, undefined, sprSogliolaBlob, -10,
   "Può essere giocato in ogni acquario"
) constructor {
   // Override the listener
   listener = function( eventType, actor, effectIndex ) {
      if( eventType == EventType.TURN_MAIN ) {
         if( location ==  global.turnPlayer.hand 
         && global.fishPlayed < global.maxFishPlayable) {
            if global.turnPlayer.aquarium.size < 8
               global.options.Add( ["Summon "+name,Summon] )
            if global.turnOpponent.aquarium.size < 8
               global.options.Add( ["Summon "+name+" to opponent",SummonToOpponent ])
         }
      }
   }
}

function CardReSogliola(owner) : FishEffectCard(
   "Re Sogliola",owner,undefined, undefined, sprReSogliola, 0,
   "+3 al valore per ogni altra sogliola nell'acquario"
) constructor {
   _listener = listener
   listener = function( eventType, actor, effectIndex ) {
      _listener( eventType, actor, effectIndex )
      if( eventType == EventType.POSTSUMMON || eventType == EventType.FREE ) {
         //if( is_instanceof(location,Aquarium) || actor == self ) { // la carta che sto evocando è questa
         global.effectChainRing.Add( [ReEvaluate,EventType.PASSIVE,self,[eventType,actor,effectIndex]] )
         //}
      }
   }
   ReEvaluate = function(srcEvent) {
      var eventType = srcEvent[0]
      var srcActor = srcEvent[1]
      val = 0
      if breakpoints
         show_debug_message("cosaimas")
      controller.aquarium._cards.foreach(function(card,ctx) {
         if card == ctx return;
         ctx.val += 3;
      },self)
      //if( eventType == EventType.SUMMON && srcActor != self ) val += 3
      //if( eventType == EventType.FREE ) val -= 3
   }
}