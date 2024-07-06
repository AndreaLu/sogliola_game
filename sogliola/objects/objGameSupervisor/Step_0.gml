
if startTurn {
   startTurn = false
   // Inizializza tutto per questo turno
   global.turnPlayer.aquarium.protected = false
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
if ! global.choiceMade && global.turnPlayer == global.opponent {
   var choice = irandom(global.options.size-1)
   var option = global.options.At(choice)
   if array_length(option) > 2
      option[1](option[2])
   else
      option[1]()
   global.choiceMade = true
}
if global.choiceMade {
   global.choiceMade = false
   if ! global.turnPassed {
      // Verify game end condition
      if global.turnPlayer.aquarium.size >= 8 || global.turnOpponent.aquarium.size >= 8 {
         var pv = getValue(global.player)
         var ov = getValue(global.opponent)
         if pv > ov {
            show_message("game over: you win!")
         }
         if pv == ov {
            show_message("game over: draw!")
         }
         if pv < ov {
            show_message("game over: you lose!")
         }
         game_end(0)
      }
      
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

