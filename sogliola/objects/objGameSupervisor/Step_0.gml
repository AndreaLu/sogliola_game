
if startTurn {
   startTurn = false
   // Inizializza tutto per questo turno
   global.fishPlayed = false
   global.turnPassed = false
   global.choiceMade = false
   
   global.supervisor.Event( undefined, EventType.TURN_BEGIN )
   global.supervisor.Event( function() { global.turnPlayer.Draw() } , EventType.TURN_DRAW ) 
   
   global.options.Clear()
   global.options.Add( [ "Pass the turn", function() {global.turnPassed = true;} ] )
   // Tutte le mosse possibili verranno elencate in global.options dalle carte stesse
   global.supervisor.Event( undefined, EventType.TURN_MAIN )
}

// Wait for a user action to be made (either from the AI or the human)
if global.choiceMade {
   global.choiceMade = false
   if ! global.turnPassed {
      global.options.Clear()
      global.options.Add( [ "Pass the turn", function() {global.turnPassed = true;} ] )
      // Tutte le mosse possibili verranno elencate in global.options dalle carte stesse
      global.supervisor.Event( undefined, EventType.TURN_MAIN )
   } else {
      global.turnPlayer = (global.turnPlayer == global.player) ? global.opponent : global.player;
      startTurn = true
   }
}

// End of turn, switch player

