


global.supervisor = new Supervisor()

// Create the playher and opponent (and their decks)
global.player = new Player()
global.opponent = new Player()
global.ocean = new Ocean()

var newCard
repeat(20) {
   newCard = new CardSogliola(global.player)
   global.player.deck.Add( newCard )
   
   newCard = new CardSogliola(global.opponent)
   global.opponent.deck.Add( newCard )
   
   newCard = new CardPesca(global.player)
   global.player.deck.Add( newCard )
   
   newCard = new CardPesca(global.opponent)
   global.opponent.deck.Add( newCard )
}

global.player.deck.Shuffle()
global.opponent.deck.Shuffle()

// Draw 6 cards
repeat(6) {
   global.player.Draw()
   global.opponent.Draw()
}

// Determine whose turn it is, randomly
global.turnPlayer = global.player //choose(global.player,global.opponent)

startTurn = true
