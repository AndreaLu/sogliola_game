effectListeners = ds_list_create()
// list of listeners:
// listener( effectType, actor, effectIndex )
//   effectType: type of the effect that has been activated
//   actor: actor which activated the effect
//   effectIndex: index of the effect in the previous scan chain, in case it is affected
//                by this effect

effectChain = ds_list_create()
effectChainRing = ds_list_create()


enum EffectType {
   DRAW = 0x01,
}

function Hand() constructor {
   cards = ds_list_create()
   static Add = function(_card) {
      ds_list_add(cards,_card)
   }
}

function Actor() constructor {
   
   static Activate = function( _effect, _effectType ) {
      
      ds_list_add( global.effectChainRing,  [_effect,_effectType,self] )
      
      while( ds_list_size( global.effectChainRing ) > 0 ) {
         ds_list_add( global.effectChain, ds_list_create_copy(global.effectChainRing))
         ds_list_clear(global.effectChainRing ) 
         
         // Se qualcuno vuole aggiungersi alla chain, mette tutto in
         // global.effectChainRing
         var chain = effectChainRing[|ds_list_size(effectChainRing)-1]
         for(var i=0; i<ds_list_size(chain); i++ ) {
            var effect = chain[|i]
            for(var j=ds_list_size(global.effectListeners)-1;j>=0;j--)
               global.effectListeners[|j]( effect[1], effect[2], i ) 
               // listener( effectType, actor, effectIndex )
         }
      }
      
      // Cleanup the effect chain
      for( var i=ds_list_size(global.effectChain)-1; i=0; i--) {
         ds_list_destroy( global.effectChain[|i] )
      }
      ds_list_clear( global.effectChain )
      
   }
}

function Player(_deck) : Actor() constructor {
   deck = _deck;
   hand = Hand();
   static Draw = function() {
      Activate( function() { hand.Add( deck.Draw() ) } , EffectType.DRAW ) 
   }
}


function Card(_name) constructor {
   name = _name;
}
function FishCard(_name,_desc) : Card(_name) constructor {
   desc = _desc;
}
function ActionCard(_name,_effectText) : Card(_name) constructor {
   desc = _effectText;
}
function FishEffectCard(_name,_effectText,_effects) constructor {
   
}

// -----------------------------------------------------------------------------+
// Card database                                                                |
// -----------------------------------------------------------------------------+
function Sogliola() : FishCard(
   "Sogliola",
   "Ora è piatta; leggende narrano che un tepo non lo fosse. Che pesce nobile!"
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
