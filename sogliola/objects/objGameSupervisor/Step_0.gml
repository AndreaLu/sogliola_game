
if startTurn {
   startTurn = false
   // Inizializza tutto per questo turno
   global.maxFishPlayable = 1
   global.fishPlayed = 0
   global.turnPassed = false
   global.choiceMade = false
   
   global.supervisor.StartEvent( new EventTurnBegin() )
   global.supervisor.StartEvent( new EventDraw(global.supervisor, function(_evt) { global.turnPlayer.Draw()} ) )// function() { global.turnPlayer.Draw() } , EventType.TURN_DRAW ) 
   
   global.options.Clear()
   global.options.Add( [ "Pass the turn", function() {global.turnPassed = true;} ] )
   // Tutte le mosse possibili verranno elencate in global.options dalle carte stesse
   global.supervisor.StartEvent( new EventTurnMain() )
}

// Wait for a user action to be made (either from the AI or the human)
if global.choiceMade {
   global.choiceMade = false
   if ! global.turnPassed {
      global.options.Clear()
      global.options.Add( [ "Pass the turn", function() {global.turnPassed = true;} ] )
      // Tutte le mosse possibili verranno elencate in global.options dalle carte stesse
      global.supervisor.StartEvent( new EventTurnMain() )
   } else {
      global.turnOpponent = global.turnPlayer
      global.turnPlayer = (global.turnPlayer == global.player) ? global.opponent : global.player;
      startTurn = true
   }
}

// End of turn, switch player

