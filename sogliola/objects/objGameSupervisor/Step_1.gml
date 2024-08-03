// +----------------------------------------------------------------------+
// | Begin Step Event                                                     |
// +----------------------------------------------------------------------+
// Index:
// 1.0 Game Initialization

// Exit if already initialzied 
if gameInitialized || (room != room2DGame && room != room3DGame )
   exit
gameInitialized = true
var seed = 8

//            ____________________________
//#region    | 1.0 Game Initialization    |
//#region    |    1.0.1 Load the game     |
if global.debugMode && !global.multiplayer && file_exists("savedata.json")
   && show_question("savedata exists, load it?") {
   GameLoad()
   startTurn = false
//#endregion |                            |
//#region    |    1.0.2 Random Seed       |
} else {
   
   if global.multiplayer {
      // TODO: genera un seme lato server condiviso per entrambi i giocatori
      // del match
      random_set_seed(seed)
   } else {
      //randomize()
      random_set_seed(seed)
   }
     
//#endregion |                            |
//#region    |    1.0.3 Fill up the deck  |
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
//#endregion |                            |
//#region    |    1.0.4 Determine the turn|

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
   var finalAngle = global.turnPlayer == global.opponent ? 
      random_range(180-10,180+10) : random_range(-10,10)
   if abs(finalAngle-global.bottle.rotz) < 90 || finalAngle < global.bottle.rotz
      finalAngle += 360
   new StackFlipBottle(finalAngle)
//#endregion |                            |
//#region    |    1.0.5 Move the camera   |
   if room == room3DGame && global.turnPlayer == global.opponent {
      new StackMoveCamera(
         global.Blender.CamOpponent.From,
         global.Blender.CamOpponent.To,
         global.Blender.CamOpponent.FovY,
         0.3, undefined
      )
   }
//#endregion |                            |
//#region    |    1.0.6 Shuffle & Draw    |
   // I deck devono essere mescolati nello stesso ordine
   // di giocatori in una partita multiplayer, quindi
   // uso il turnPlayer
   global.turnPlayer.deck.Shuffle()
   // TODO: vedi perché è commentato
   //global.turnOpponent.deck.Shuffle()
   
   
   // Draw 4 cards
   new StackWait(0.3)
   repeat(4) {
      new Stack( function() { global.turnPlayer.Draw() } )
      new Stack( function() { global.turnOpponent.Draw() } )
   }
//#endergion |                            |
   
   startTurn = true
}
//#endregion |                            |
//#endregion |                            |
   //           |____________________________|