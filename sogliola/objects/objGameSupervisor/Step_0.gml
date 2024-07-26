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


   global.options.Clear()
   if( global.turnPlayer.deck.size > 0 ) {
      // Rendi la pesca automatica
      // global.turnPlayer.deck.At(0)
      
      

      if global.turnPlayer == global.player {
         new StackCardDrawAnim(
            global.turnPlayer.deck.At(0).guiCard,
            undefined
         )
         new StackMoveCamera(
            global.Blender.CamDeck.From,
            global.Blender.CamDeck.To,
            global.Blender.CamDeck.FovY,
            0.8
         )
         global.options.Add( ["Draw", function() {
            new StackMoveCamera(
               global.Blender.CamHand.From,
               global.Blender.CamHand.To,
               global.Blender.CamHand.FovY,
               0.8, function() {
                  new StackBlenderAnimLerpPos(
                     global.Blender.AnimCardDraw.Action,
                     3, global.turnPlayer.deck.At(0).guiCard,
                     function() {
                        global.supervisor.StartEvent( new EventDraw(global.supervisor, function(_evt) {
                        if global.turnPlayer.deck.size > 0
                           global.turnPlayer.Draw()
                           global.choiceMade = true // PEZZA PEZZISSIMA
                        }
                        
                         ) )
                     }
                  )
               }
            )
         }, global.turnPlayer.deck.At(0)])
      } else {
         global.options.Add( ["Draw", function() {
            global.supervisor.StartEvent( new EventDraw(global.supervisor, function(_evt) {
               if global.turnPlayer.deck.size > 0
                  global.turnPlayer.Draw()
            } ) )
         }, global.turnPlayer.deck.At(0)])
      }
   }
   global.options.Add( [ "Pass the turn", function() {global.turnPassed = true;}, undefined ] )

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

