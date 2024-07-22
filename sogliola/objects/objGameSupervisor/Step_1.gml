
if gameInitialized || (room != room2DGame && room != room3DGame )
   exit


gameInitialized = true


var seed = 8
if !global.multiplayer && file_exists("savedata.json") && show_question("savedata exists, load it?") {
   GameLoad()
   startTurn = false
} else {
   
   if global.multiplayer {
      // TODO: genera un seme lato server condiviso per entrambi i giocatori
      // del match
      random_set_seed(seed)
   } else {
      //randomize()
      random_set_seed(seed)
   }
   
   //global.srandom.SetSeed(date_get_second(date_current_datetime()))
   global.srandom.SetSeed(seed)    
   
   var newCard
   repeat(1) {
      global.player.deck.Add( new CardFreeSogliola(global.player) )
      global.opponent.deck.Add( new CardFreeSogliola(global.opponent) )
      
      global.player.deck.Add( new CardSogliola(global.player) )
      global.opponent.deck.Add( new CardSogliola(global.opponent) )
   
      global.player.deck.Add( new CardPesca(global.player) )
      global.opponent.deck.Add( new CardPesca(global.opponent) )
   
      global.player.deck.Add( new CardPioggia(global.player) )
      global.opponent.deck.Add( new CardPioggia(global.opponent) )
   
      global.player.deck.Add( new CardSogliolaBlob(global.player) )
      global.opponent.deck.Add( new CardSogliolaBlob(global.opponent) )
   
      global.player.deck.Add( new CardReSogliola(global.player) )
      global.opponent.deck.Add( new CardReSogliola(global.opponent) )
   
      global.player.deck.Add( new CardSogliolaDiavoloNero(global.player) )
      global.opponent.deck.Add( new CardSogliolaDiavoloNero(global.opponent) )
   
      global.player.deck.Add( new CardSogliolaPietra(global.player) )
      global.opponent.deck.Add( new CardSogliolaPietra(global.opponent) )
   
      global.player.deck.Add( new CardSogliolaVolante(global.player) )
      global.opponent.deck.Add( new CardSogliolaVolante(global.opponent) )
   
      global.player.deck.Add( new CardSogliolaSalmone(global.player) )
      global.opponent.deck.Add( new CardSogliolaSalmone(global.opponent) )
   
      
   
      global.player.deck.Add( new CardPescaAbbondante(global.player) )
      global.opponent.deck.Add( new CardPescaAbbondante(global.opponent) )
   
      global.player.deck.Add( new CardFurto(global.player) )
      global.opponent.deck.Add( new CardFurto(global.opponent) )
   
      global.player.deck.Add( new CardSogliolaGiullare(global.player) )
      global.opponent.deck.Add( new CardSogliolaGiullare(global.opponent) )
   
      global.player.deck.Add( new CardAcquarioProtetto(global.player) )
      global.opponent.deck.Add( new CardAcquarioProtetto(global.opponent) )
   
      global.player.deck.Add( new CardScambioEquivalente(global.player) )
      global.opponent.deck.Add( new CardScambioEquivalente(global.opponent) )
      
     
   }
   //repeat(100) global.player.deck.Add( new CardScambioEquivalente(global.player) )

   

   // Determine whose turn it is, randomly
   if ! global.multiplayer  {
      global.turnPlayer = global.opponent
      global.turnOpponent = global.player
   } else {
      if( global.multiplayerStarter ) {
         global.turnPlayer = global.player
         global.turnOpponent = global.opponent
      } else {
         global.turnPlayer = global.opponent
         global.turnOpponent = global.player
      }
   }
   
   if room == room3DGame && global.turnPlayer == global.opponent {
      new StackMoveCamera(
         global.Blender.CamOpponent.From,
         global.Blender.CamOpponent.To,
         global.Blender.CamOpponent.FovY,
         0.3, undefined
      )
   }
   
   global.turnPlayer.deck.Shuffle()
   //global.turnOpponent.deck.Shuffle()
   
   
   // Draw 4 cards
   repeat(4) {
      global.turnPlayer.Draw()
      global.turnOpponent.Draw()
   }
   

   startTurn = true
}