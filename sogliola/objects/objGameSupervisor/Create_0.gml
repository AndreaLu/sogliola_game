if global.multiplayer {
   global.client = network_create_socket(network_socket_tcp)
   network_connect_raw_async(global.client,"127.0.0.1",33000)
   networkSendPacket("ciao! mi chiamo Pasquale")
}

attesa = 0
global.supervisor = new Supervisor()

// Create the player and opponent (and their decks)
global.player = new Player()
global.opponent = new Player()
global.ocean = new Ocean()

global.onePlayerFinished = false



gameInitialized = false
