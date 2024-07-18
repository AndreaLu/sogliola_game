multiplayer = false
allCards = new ds_list() // tutte le carte esistenti si inseriscono automaticamente in questa lista

effectListeners = new ds_list()
// list of listeners:
// that is instances that implement thel listener(event) callback

effectChain = new ds_list()      //
effectChainRing = new ds_list()  // list of effects that triggered simultaneously (will need to sort them out into the effectChain)
options = new ds_list()
fishPlayed = 0                  // number of fish the player summoned this turn
maxFishPlayable = 1             // max number of fish that can be played this turn


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
   
   static Random = function() {
      if size == 0 return undefined;
      return _cards.At(irandom(size-1))
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

function location_str_location( _str ) {
   if( _str == "Player deck" ) return global.player.deck
   if( _str == "Opponent deck" ) return global.opponent.deck
   if( _str == "Player hand" ) return global.player.hand
   if( _str == "Opponent hand" ) return global.opponent.hand
   if( _str == "Player aquarium" ) return global.player.aquarium
   if( _str == "Opponent aquarium" ) return global.opponent.aquarium
   if( _str == "The ocean" ) return global.ocean
   return undefined
}

function Actor() constructor {
   
   static StartEvent = function( event ) {

      global.effectChainRing.Add( event )

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
               global.effectListeners.At(k).listener( _event )
            }
         }
      }
      
      // Ora la effectChain è stata popolata correttamente...
      // La eseguo a ritroso
      for(var i=global.effectChain.size-1;i>=0;i--) {
         var ring = global.effectChain.At(i)
         for( var j=0;j<ring.size; j++) {
            _event = ring.At(j)
            if !is_undefined( _event.callback ) 
               _event.callback(_event)
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
      if( deck.size > 0 )
         hand.Add( deck.Draw() );
   }
}
function Supervisor() : Actor() constructor {}

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
      var data = [
         type,
         owner == global.player ? 0 : 1,
         controller == global.player ? 0 : 1,
         location_str( location ),
      ]
      return json_stringify( data) 
   }
   
   FromJSON = function(json) {
      var data = json_parse( json )
      owner =  (data[1] == 0 ) ? global.player : global.opponent
      controller = (data[2] == 0 ) ? global.player : global.opponent
      location = location_str_location( data[3] )
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
             global.turnPlayer.aquarium.size < 8 ) {
            global.options.Add( ["Summon "+name,Summon] ) 
         }
      }
   } 
}
function ActionCard(_name,_owner, _controller, _location, _sprite, _effectText, _type) : Card(_name,_owner,_controller,_location,_sprite, _type) constructor {
   desc = _effectText;
   
   
   listener = function( event ) {
      if( is_instanceof(event, EventTurnMain) ) {
         if( location == global.turnPlayer.hand ) {
            global.options.Add( ["Activate "+name,Activate] ) 
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
// -----------------------------------------------------------------------------+
// Card database                                                                |
// -----------------------------------------------------------------------------+
function CardSogliola(owner) : FishCard(
   "Sogliola", owner, undefined, undefined, sprSogliola, 5,
   "Ora è piatta; leggende narrano che un tempo non lo fosse. Che pesce nobile!",
   CardType.SOGLIOLA
) constructor {
}
function CardPesca(owner) : ActionCard(
   "Pesca", owner, undefined, undefined, sprPesca, "Pesca 2 carte",
   CardType.PESCA
) constructor {
   Effect = function() {
         controller.Draw()
         controller.Draw()
   }
}
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
function CardPioggia(owner) : ActionCard(
   "Pioggia di Pesci", owner, undefined, undefined, sprPioggiaDiPesci, 
   "Per questo turno, puoi giocare due carte Sogliola",
   CardType.PIOGGIA
) constructor {
   Effect = function() {
      global.maxFishPlayable = 2
   }
}
function CardSogliolaBlob(owner) : FishEffectCard(
   "Sogliola Blob", owner, undefined, undefined, sprSogliolaBlob, -10,
   "Può essere giocato in ogni acquario",
   CardType.SOGLIOLA_BLOB
) constructor {
   // Override the listener
   listener = function( event ) {
      if( is_instanceof(event,EventTurnMain) ) {
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
function CardSogliolaDiavoloNero(owner) : FishEffectCard(
   "Sogliola Diavolo Nero", owner, undefined, undefined, sprSogliolaDiavoloNero,3,
   "Quando questa carta entra in un acquario, ruba una soglila casuale dall'acquario avversario",
   CardType.SOGLIOLA_DIAVOLO_NERO
) constructor {
   _listener = listener
   listener = function( event ) {
      _listener( event )
      if( is_instanceof(event,EventSummon) && event.src == self ) {
         var opponent = Opponent(controller)
         if( opponent.aquarium.size > 0 && !opponent.aquarium.protected ) {
            var target = opponent.aquarium.Random()
            global.effectChainRing.Add( new EventSteal(self,Steal,target) )
         }
      }
      Steal = function(event) {
         controller.hand.Add(event.target)
      }
   }
}
function CardSogliolaPietra(owner) : FishEffectCard(
   "Sogliola Pietra", owner, undefined, undefined, sprSogliolaPietra, 2,
   "Può essere giocata in ogni Acquario. Quando entra in un Acquario, Libera una sogliola casuale da quell'Acquario",
   CardType.SOGLIOLA_PIETRA
) constructor {
   listener = function( event ) {
      if( is_instanceof(event,EventTurnMain) ) {
         if( location ==  global.turnPlayer.hand 
         && global.fishPlayed < global.maxFishPlayable) {
            if global.turnPlayer.aquarium.size < 8
               global.options.Add( ["Summon "+name,Summon] )
            if global.turnOpponent.aquarium.size < 8 && !global.turnOpponent.aquarium.protected
               global.options.Add( ["Summon "+name+" to opponent",SummonToOpponent ])
         }
      }
      
      
      if( is_instanceof(event,EventSummon) && event.src == self) {
         var aquarium = event.opponent ? Opponent(controller).aquarium : controller.aquarium
         if( aquarium.size > 0 ) {
            do var target = aquarium.Random()
            until( target != self )
            global.effectChainRing.Add( new EventFree(self,Free,target) )
         }
      }
   }
   

   Free = function(event) {
      global.ocean.Add(event.target)
   }
}
function CardSogliolaVolante(owner) : FishEffectCard(
   "Sogliola Volante", owner, undefined, undefined, sprSogliolaVolante, 5,
   "Quando questa sogliola passa dall'Acquario all'oceano, il proprietario dell'acquario pesca 2 carte",
   CardType.SOGLIOLA_VOLANTE
) constructor {
   _listener = listener
   listener = function( event ) {
      _listener( event )
      if breakpoints breakpoint()
      if( is_instanceof(location,Aquarium) && is_instanceof(event,EventFree) && event.target == self ) {
         global.effectChainRing.Add( new EventDraw(self,Draw) ) 
      }
   }
   Draw = function(_evt) {
      controller.Draw()
      controller.Draw()
   }
}
function CardSogliolaSalmone(owner) : FishEffectCard(
   "SogliolaSalmone", owner, undefined, undefined, sprSogliolaSalmone, 5,
   "Quando questa sogliola passa da un acquario alla mano, il proprietario dell'acquario pesca 2 carte",
   CardType.SOGLIOLA_SALMONE
) constructor {
   _listener = listener
   listener = function( event ) {
      _listener( event )
      if( is_instanceof(location,Aquarium) && is_instanceof(event,EventSteal) && event.target == self ) {
         var evt = new EventDraw(self,Draw)
         evt.target = ( location == global.player.aquarium ) ? global.player : global.opponent
         global.effectChainRing.Add( evt ) 
      }
   }
   
   Draw = function(event) {
      event.target.Draw()
      event.target.Draw()
   }
}
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
         global.options.Add(["Free '"+target.name+"' own", Activate, target] )
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
            global.options.Add(["Free '"+target.name+"' opponent", Activate, target] )
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
         global.options.Add(["Activate Steal on '"+target.name+"' own", Activate, target] )
      }
      
      var opponent = Opponent(controller)
      if( ! opponent.aquarium.protected ) {
         giullare = opponent.aquarium._cards.Filter(
            function(c) { return is_instanceof(c,CardSogliolaGiullare) }
         ) != undefined
         for( var i=0;i<opponent.aquarium.size;i++;) {
            var target = opponent.aquarium.At(i)
            if( giullare and is_instanceof(target,CardReSogliola) ) continue;
            global.options.Add(["Activate Steal on '"+target.name+"' opponent", Activate, target] )
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
function CardSogliolaGiullare(owner) : FishEffectCard(
   "Sogliola Giullare", owner, undefined, undefined, sprSogliolaGiullare, 3,
   "Se si trova in un Acquario col Re Sogliola, quest'ultimo non può essere rubato né liberato",
   CardType.SOGLIOLA_GIULLARE
) constructor {
   
}
function CardAcquarioProtetto(owner) : ActionCard(
   "Acquario Protetto", owner, undefined, undefined, sprAcquarioProtetto,
   "I pesci nel tuo Acquario sono protetti fino al tuo prossimo turno",
   CardType.ACQUARIO_PROTETTO
) constructor {
   Effect = function() {
      controller.aquarium.protected = true
   }
}

function CardScambioEquivalente(owner) : ActionCard(
   "Scambio Equivalente", owner, undefined, undefined, sprScambioEquivalente,
   "Scambia una sogliola del tuo Acquario con un'altra dell'acquario avversario",
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
            global.options.Add(["Activate swap '"+ctx.card1.name+"' <-> '"+card.name+"'", Activate, [ctx.card1, card]])
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