


global.supervisor = new Supervisor()

// Create the playher and opponent (and their decks)
global.player = new Player()
global.opponent = new Player()
global.ocean = new Ocean()

global.onePlayerFinished = false




if file_exists("savedata") && show_question("savedata exists, load it?") {
   GameLoad()
   startTurn = false
} else {
   randomize()
   var newCard
   repeat(1) {
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
   
      global.player.deck.Add( new CardFreeSogliola(global.player) )
      global.opponent.deck.Add( new CardFreeSogliola(global.opponent) )
   
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

   global.player.deck.Shuffle()
   global.opponent.deck.Shuffle()

   // Draw 5 cards
   repeat(5) {
      global.player.Draw()
      global.opponent.Draw()
   }

   // Determine whose turn it is, randomly
   global.turnPlayer = global.player //choose(global.player,global.opponent)
   global.turnOpponent = global.opponent

   startTurn = true
   
}
