


global.supervisor = new Supervisor()

// Create the playher and opponent (and their decks)
global.player = new Player()
global.opponent = new Player()
global.ocean = new Ocean()

var newCard
repeat(floor(40/7)) {
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
}

random_set_seed(20)

global.player.deck.Shuffle()
global.opponent.deck.Shuffle()

// Draw 6 cards
repeat(6) {
   global.player.Draw()
   global.opponent.Draw()
}

// Fixed hands (for debug purposes) 
if( false ) {
   global.player.hand.Add( new CardReSogliola(global.player) )
   global.player.hand.Add( new CardReSogliola(global.player) )
   global.player.hand.Add( new CardPioggia(global.player) )
   global.opponent.hand.Add( new CardSogliolaPietra(global.opponent) )
}


// Determine whose turn it is, randomly
global.turnPlayer = global.player //choose(global.player,global.opponent)
global.turnOpponent = global.opponent

startTurn = true
