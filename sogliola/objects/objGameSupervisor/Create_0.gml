disable = false 
if instance_number(objGameSupervisor) > 1 {
   instance_destroy()
   disable = true
}
if disable exit;
   
if global.multiplayer {
   global.client = network_create_socket(network_socket_tcp)
   var ip = "34.16.250.226" // server IP
   network_connect_raw_async(global.client,ip,33000)
}

show_debug_overlay( global.debugMode )
attesa = 0
global.supervisor = new Supervisor()

// Create the player and opponent (and their decks)
global.player = new Player()
global.opponent = new Player()
global.ocean = new Ocean()
global.turnPlayer = undefined

global.onePlayerFinished = false


networkMessages = new ds_list()

gameInitialized = false

networkWaiting = 1
