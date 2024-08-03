// +----------------------------------------------------------------------+
// | Step Event                                                           |
// +----------------------------------------------------------------------+
/*
   - Turn initialization
      Here, the initialization of the turn happens (1.0). This is when the
      variable startTurn is set to true, which happens when a player passes
      the turn. the "pass the turn" option sets global.turnPassed to true,
      which in turns make startTurn true just for a frame.
   - Player/Opponent Move
      After the initialization, if it's the players turn, this step
      does nothing but wait for the user decision. When it finally comes,
      global.choiceMade is set to true so this event can run the required
      steps (2.3), which includes the propagation of a new TurnMain Event
      to repopulate the global.options array
      If it's the opponent's turn, this event calculate the move with the
      IA (2.1) or waits for the multiplayer partner to pick a move
   - Endgame
      This event also calculates the endgame condition (2.3)
*/


if( room != room2DGame && room != room3DGame ) exit
//            ___________________________
//#region    | 1.0 Start of the Turn     |
var playerDrawing = false // pezza per fissare il wrong gameend
if startTurn {
   // Inizializza tutto per questo turno
   global.turnPlayer.aquarium.protected = false
   global.maxFishPlayable = 1
   global.fishPlayed = 0
   global.turnPassed = false
   global.choiceMade = false
   
   global.supervisor.StartEvent( new EventTurnBegin() )


   global.options.Clear()
   if( global.turnPlayer.deck.size > 0 ) {
      playerDrawing = true
      if global.turnPlayer == global.player {
         // Player's turn
         global.disableUserInput = true
         new StackMoveCamera(
            global.Blender.CamDeck.From,
            global.Blender.CamDeck.To,
            global.Blender.CamDeck.FovY,
            0.8,
            function() {
               global.supervisor.StartEvent(
                  new EventDraw(global.supervisor, function(_evt) {
                        if global.turnPlayer.deck.size > 0 {
                           global.turnPlayer.Draw()
                           global.choiceMade = true // PEZZA PEZZISSIMA
                        }
                     }
                  )
               )
               new StackMoveCamera(
                  global.Blender.CamHand.From,
                  global.Blender.CamHand.To,
                  global.Blender.CamHand.FovY,
                  0.8, function() {
                     global.disableUserInput = false
                  }
               )
            }
         )
      } else {
         // Opponent's turn
         global.options.Add( ["Draw", function() {
            global.supervisor.StartEvent(
               new EventDraw(global.supervisor,
                  function(_evt) {
                     if global.turnPlayer.deck.size > 0
                        global.turnPlayer.Draw()
                  } 
               ) 
            )
         }, global.turnPlayer.deck.At(0)])
      }
   } else {
      global.supervisor.StartEvent( new EventTurnMain() )
      new StackMoveCamera(
         global.Blender.CamHand.From,
         global.Blender.CamHand.To,
         global.Blender.CamHand.FovY,
         0.8, function() {
            global.disableUserInput = false
         }
      )
   }
   global.options.Add( [ 
      "Pass the turn", 
      function() {global.turnPassed = true;},
      undefined 
   ] )

}
//#endregion |                       |
//#region    | 2.0 Making a Move         |
//#region    |    2.1 Opponents move     |
//#region    |       2.1.0 Draw          |
// We need to make a move for the opponent.
// If the game is multiplayer, this is not done here, but rather in the
// async event (as we receive the move from the opponent)
// If the game is singleplayer, this is where the IA performs its move


// If there are some cards with locationLock set to true, wait
// for them
global.locationLock = false
with obj3DCard {
   if locationLock
      global.locationLock = true 
}


if !global.locationLock && !global.choiceMade && (global.turnPlayer == global.opponent) && !global.waitingExecution {
   if !global.multiplayer {

      var best = undefined
      // AI turn
      attesa += 1
      if( attesa >= room_speed*0.5 ) {
      
         attesa = 0
         var choice
         canDraw = false
         global.options.foreach(function(option,ctx) {
            if option[0] == "Draw" {
               canDraw = true
               return true
            }
         },self)
         
         // Si da per scontato che draw sia sempre la scelta 0
         if canDraw
            best = { option: global.options.At(0) , value: 0 } 
         else {
//#endregion |                           |
//#region    |       2.1.1 Actual Move   |         
            // Crea una copia di global.options per non subire interferenze durante le simulazioni
            var options = []
            for(var i=0;i<global.options.size;i+=1)
               array_push(options,global.options.At(i))
            // Salva il gioco per fare delle simulazioni e tornare indietro
            var saveState = GameGetJSON()
            // Durate una simulazione, annulla i nodi Stack
            global.simulating = true
            // Blocca la location di tutte le carte (congelando il rendering)
            //with( obj3DCard ) { locationLock = true }
            best = undefined
            for( var i=0; i<array_length(options); i+=1) {
               // Simula la mossa
               SimulateOption( options[i] )
               // Calcola il punteggio della mossa
               var optionValue = getScore(global.opponent) - getScore(global.player)
               // Trova la migliore
               if( is_undefined(best) || optionValue > best.value )
                  best = {option: options[i], value: optionValue}
               // Riporta il gioco all'inizio
               GameRestoreJson(saveState)
            }
            // Sblocca la location delle carte
            //with( obj3DCard) { locationLock = false }
            global.simulating = false

            // Ricostruisco global .options
            global.options.Clear()
            for(var i=0;i<array_length(options);i+=1)
               global.options.Add(options[i])
            }
         
         ExecuteOption(best.option,false)
      }
   }
//#endregion |                           |
//#region    |       2.1.2 Multiplayer   | 
   else {
      // Online multiplayer.. 
      // the choice will come from the async event
   }
}
//#endregion |                           |
//#endregion |                           |
//#region    |    2.2 Player move        |
/* 
   The player move does not happen here. Rather, when the player clicks
   on cards or whatnot, the move is made selecting one among the 
   "global.options" array, that, at any given point, lists the possible
   moves for the turn player.
   When the player does his move, the global variable global.choiceMade
   is set to true
*/
//#endregion
//#region    |    2.3 ChoiceMade/Endgame |
if( global.options.size == 1 && startTurn && !playerDrawing) {
   if( global.onePlayerFinished ) GameOver()
   global.onePlayerFinished = true
}

startTurn = false

if global.choiceMade {
   global.choiceMade = false
   GameSave()
   if !global.turnPassed {
      // Verify game end condition
      if( global.turnPlayer.aquarium.size >= 8 || global.turnOpponent.aquarium.size >= 8 ) {
         GameOver()
      }
      
      global.options.Clear()
      global.options.Add( [ "Pass the turn", function() {
         global.turnPassed = true;
         new StackFlipBottle()         
      }, undefined] )
      // Tutte le mosse possibili verranno elencate in global.options dalle carte stesse
      global.supervisor.StartEvent( new EventTurnMain() )
   } else {
      global.turnOpponent = global.turnPlayer
      global.turnPlayer = (global.turnPlayer == global.player) ? global.opponent : global.player;
      startTurn = true
   }
}
//#endregion
//#endregion |                           |
//           |___________________________|
