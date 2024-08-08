if disable exit;
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
if !gameInitialized exit
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
   global.choiceCount = 0 // numero di mosse fatte in questo turno
   global.canPass = false
   
   if( global.turnPlayer.deck.size == 0 ) {
      GameOverSequence(0)
   } 

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

                           if global.multiplayer && global.turnPlayer == global.player {
                              networkSendPacket("move,0")
                           }
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
                     global.canPass = true
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
   } 
   /*else {
      global.supervisor.StartEvent( new EventTurnMain() )
      new StackMoveCamera(
         global.Blender.CamHand.From,
         global.Blender.CamHand.To,
         global.Blender.CamHand.FovY,
         0.8, function() {
            global.disableUserInput = false
         }
      )
   }*/
   if !global.gameOvering
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
            best = undefined
            for( var i=0; i<array_length(options); i+=1) {
               if options[i][0] == "Pass the turn" {
                  optionPass = options[i]
                  continue;
               } 
               // Simula la mossa e ne calcola il punteggio
               SimulateOption( options[i] )
               var optionValue = getScore(global.opponent) - getScore(global.player)
               // Trova la migliore
               if( is_undefined(best) || optionValue > best.value )
                  best = {option: options[i], value: optionValue}
               // Riporta il gioco all'inizio
               GameRestoreJson(saveState)
            }
            global.simulating = false
            
            // Ricostruisco global.options
            global.options.Clear()
            for(var i=0;i<array_length(options);i+=1)
               global.options.Add(options[i])

            // Aggiungi una certa probabilità di passare la mano
            // all'aumentare del numero di mosse fatte in questo turno.
            // Dopo 2 mosse la prob è del 80%. Riduci questa probabilità
            // man mano che la partita sta per finire per l'avversario
            // per forze esterne, ovvero il mazzo che è vicino a finire o 
            // il giocatore che ha un alto numero di sogliole
            //var passProb = global.choiceCount/2*0.8 * (7-global.player.aquarium.size)/7 * clamp(global.opponent.deck.size/3*0.2,0,1)
            //passProb = clamp(passProb,0,1)
            passProb = global.choiceCount > 1 ? 0.5 : 0
            var doPass = (PRNG.randomRange(1,100) <= 100*passProb)
            if doPass || is_undefined(best) || best.value < 0 {
               best = {option: optionPass, value: 0}
            }
         }
         
         ExecuteOption(best.option,false)
      }
   }
//#endregion |                           |
//#region    |       2.1.2 Multiplayer   | 
   else {
      // Online multiplayer.. 
      // the choice will come from the async event
      if( networkWaiting <= 0 ) {
         networkWaiting = 1
         if( networkMessages.size > 0 ) {
            var message = networkMessages.At(0)
            var executed = false
            if array_length(message) == 2 {
               var choice = real(msg[1])
               var option = global.options.At(choice)
               ExecuteOption(option,false)
               executed = true
               show_debug_message("async executed 0")
            } else {
               var text = message[2]
               for( var jj=0;jj<global.options.size;jj+=1) {
                  if global.options.At(jj)[0] == text {
                     ExecuteOption(global.options.At(jj),false)
                     executed = true
                     show_debug_message("async executed 1")
                     break
                  }
                  
               }
            }
            if( executed ) {
               networkMessages.removeAt(0)
            }

         }
      } else {
         networkWaitingb -= deltaTime()/1000000
      }
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
