effectListeners = ds_list_create()
// list of listeners:
// listener( EventType, actor, effectIndex )
//   EventType: type of the effect that has been activated
//   actor: actor which activated the effect
//   effectIndex: index of the effect in the previous scan chain, in case it is affected
//                by this effect

effectChain = ds_list_create()
effectChainRing = ds_list_create()
options = ds_list_create()
fishSummoned = false                  // true if the player already put a fish in the aquarium

enum EventType {
   TURN_DRAW,    // inizia la draw phase del turno
   DRAW,          // pescata
   TURN_MAIN,     // inizia la fase principale del turno
   SUMMON,        // quando un pesce viene posizionato nell'acquario
   FREE,          // quando un pesce viene liberato nell'oceano
}

function CardCollection() constructor {
   cards = ds_list_create()
   static Add = function(_card) {
      ds_list_add(cards,_card)
   }
}

function Hand() : CardCollection() constructor {}
function Aquarium() : CardCollection() constructor {}

function Actor() constructor {
   
   static Activate = function( _effect, _EventType ) {
      
      ds_list_add( global.effectChainRing,  [_effect,_EventType,self] )
      
      while( ds_list_size( global.effectChainRing ) > 0 ) {
         ds_list_add( global.effectChain, ds_list_create_copy(global.effectChainRing))
         ds_list_clear(global.effectChainRing )
         // Se qualcuno vuole aggiungersi alla chain, mette tutto in
         // global.effectChainRing
         var chain = effectChainRing[|ds_list_size(effectChainRing)-1]
         for(var i=0; i<ds_list_size(chain); i++ ) {
            var effect = chain[|i]
            for(var j=ds_list_size(global.effectListeners)-1;j>=0;j--)
               global.effectListeners[|j].listener( effect[1], effect[2], i ) 
               // listener( EventType, actor, effectIndex )
         }
      }
      
      // Ora la effectChain è stata popolata correttamente...
      
      // Cleanup the effect chain
      for( var i=ds_list_size(global.effectChain)-1; i=0; i--) {
         ds_list_destroy( global.effectChain[|i] )
      }
      ds_list_clear( global.effectChain )
      
   }
}

function Player(_deck) : Actor() constructor {
   deck = _deck;
   hand = new Hand();
   aquarium = new Aquarium();
   static Draw = function() {
      Activate( function() { hand.Add( deck.Draw() ) } , EventType.DRAW ) 
   }
}


function Card(_name, _owner, _controller, _location) constructor {
   name = _name;
   owner = _owner
   controller = _controller
   location = _location
   ds_list_add( global.effectListeners, self )
}
function FishCard(_name, _owner, _controller, _location,_desc ) : Card(_name,_owner,_controller,_location) constructor {
   desc = _desc;
   static Summon = function() {
      Activate( function() {
         location = owner.aquarium
         fishSummoned = true
      }, EventType.SUMMON )

   }
   static listener = function() {
      if( location == global.player.hand || location == global.opponent.hand && !global.fishPlayed ) {
         ds_list_add( global.options, Summon )
      }
   }
}
function ActionCard(_name, _owner, _controller, _location,_effectText) : Card(_name,_owner,_controller,_location) constructor {
   desc = _effectText;
}
function FishEffectCard(_name, _owner, _controller, _location, _effectText, _effects)  : Card(_name,_owner,_controller,_location) constructor {
   effects = _effects
}

// -----------------------------------------------------------------------------+
// Card database                                                                |
// -----------------------------------------------------------------------------+
function Sogliola() : FishCard(
   "Sogliola",
   "Ora è piatta; leggende narrano che un tempo non lo fosse. Che pesce nobile!"
) constructor {
}


function Deck() {
   // Il mazzo è una lista, dove l'indice 0 è la carta in cima
   // ovvero quella che si pescherà
   cards = ds_list_create()
   static Add = function(_card) {
      ds_list_add(cards,_card)
   }
      
   static Shuffle = function() {
      ds_list_shuffle(cards)
   }
   static Draw = function() {
      card = cards[|0]
      ds_list_delete(cards,0)
      return card;
   }
}
