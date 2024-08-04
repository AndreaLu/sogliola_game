if global.multiplayer && !global.connected {
   global.client = network_create_socket(network_socket_tcp)
   var ip = "34.16.250.226"
   network_connect_raw_async(global.client,ip,33000)
}

attesa = 0
global.supervisor = new Supervisor()

// Create the player and opponent (and their decks)
global.player = new Player()
global.opponent = new Player()
global.ocean = new Ocean()

global.onePlayerFinished = false



gameInitialized = false

