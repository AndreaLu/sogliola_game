// +----------------------------------------------------------------------+
// | Step Event                                                           |
// +----------------------------------------------------------------------+
// This is where the game is managed


if( room != room2DGame && room != room3DGame ) exit
//            __________________________
//#region    | 1.0 Start of the Turn    |
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
   }
   global.options.Add( [ 
      "Pass the turn", 
      function() {global.turnPassed = true;},
      undefined 
   ] )

}
//#endregion |                       |
//#region    | 2.0 Making a Move        |
//#region    |    2.1 Opponents move    |
// We need to make a move for the opponent.
// If the game is multiplayer, this is not done here, but rather in the
// async event (as we receive the move from the opponent)
// If the game is singleplayer, this is where the IA performs its move
if !global.choiceMade && (global.turnPlayer == global.opponent) {

   if !global.multiplayer {
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
         
         if canDraw choice = 0
         else choice = irandom(global.options.size-1)//global.srandom.IRandom(global.options.size-1)
         var option = global.options.At(choice)
         if (array_length(option) > 3) && (!is_undefined(option[3]))
            option[1](option[3])
         else
            option[1]()
         global.choiceMade = true
      }
   } else {
      // Online multiplayer.. 
      // the choice will come from the async event
   }
}
//#endregion
//#region    |    2.2 Player move       |
/* 
   The player move does not happen here. Rather, when the player clicks
   on cards or whatnot, the move is made selecting one among the 
   "global.options" array, that, at any given point, lists the possible
   moves for the turn player.
   When the player does his move, the global variable global.choiceMade
   is set to true
*/
//#endregion
//#region    |    2.3 Endgame Condition |
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
      global.options.Add( [ "Pass the turn", function() {global.turnPassed = true;}, undefined] )
      // Tutte le mosse possibili verranno elencate in global.options dalle carte stesse
      global.supervisor.StartEvent( new EventTurnMain() )
   } else {
      global.turnOpponent = global.turnPlayer
      global.turnPlayer = (global.turnPlayer == global.player) ? global.opponent : global.player;
      startTurn = true
   }
}
//#endregion
//#endregion |__________________________|
