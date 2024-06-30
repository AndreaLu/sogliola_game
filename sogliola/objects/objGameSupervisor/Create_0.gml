
function Supervisor() : Actor() constructor {
   
}

global.supervisor = Supervisor()
player_deck = Deck()
opponent_deck = Deck()
repeat(40) {
   player_deck.Add( Sogliola() )
   opponent_deck.Add( Sogliola() )
}
player_deck.Shuffle()
opponent_deck.Shuffle()


global.player = Player(player_deck)
global.opponent = Player(player_deck)

turnPlayer = choose(user,opponent)
