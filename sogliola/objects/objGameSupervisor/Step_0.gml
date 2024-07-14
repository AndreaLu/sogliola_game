if( room != room2DGame && room != room3DGame ) exit
if startTurn {
   startTurn = false
   // Inizializza tutto per questo turno
   global.turnPlayer.aquarium.protected = false
   global.maxFishPlayable = 1
   global.fishPlayed = 0
   global.turnPassed = false
   global.choiceMade = false
   
   global.supervisor.StartEvent( new EventTurnBegin() )

   global.supervisor.StartEvent( new EventDraw(global.supervisor, function(_evt) {
      if global.turnPlayer.deck.size > 0
         global.turnPlayer.Draw()
   } ) )// function() { global.turnPlayer.Draw() } , EventType.TURN_DRAW ) 

   
   global.options.Clear()
   global.options.Add( [ "Pass the turn", function() {global.turnPassed = true;} ] )
   // Tutte le mosse possibili verranno elencate in global.options dalle carte stesse
   global.supervisor.StartEvent( new EventTurnMain() )
   
   if( global.options.size == 1 ) {
      if( global.onePlayerFinished ) GameOver()
      global.onePlayerFinished = true
   }
}

// Opponent turn
if !global.choiceMade && (global.turnPlayer == global.opponent) {

   if !global.multiplayer {
      // AI turn
      attesa += 1
      if( attesa >= room_speed*5 ) {
         attesa = 0
         var choice
         choice = global.srandom.IRandom(global.options.size-1)
         var option = global.options.At(choice)
         if array_length(option) > 2
            option[1](option[2])
         else
            option[1]()
         global.choiceMade = true
      }
   } else {
      // Online multiplayer.. 
      // the choice will come from the async event
   }
}


if global.choiceMade {
   global.choiceMade = false
   GameSave()
   if !global.turnPassed {
      // Verify game end condition
      if( global.turnPlayer.aquarium.size >= 8 || global.turnOpponent.aquarium.size >= 8 ) {
         GameOver()
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

