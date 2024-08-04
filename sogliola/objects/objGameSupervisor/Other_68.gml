if !global.multiplayer exit


if async_load[?"type"] == network_type_data {
   // Get the utf-8 string back from the server
   var buff = async_load[?"buffer"]
   var sz = async_load[?"size"]
   var msg = buffer_read(buff,buffer_string)
   show_debug_message("Async: "+msg)
   msg = string_split(msg,",")
   
   switch( msg[0] ) {
      case "welcome":
         networkSendPacket("ciao! mi chiamo Nino")
         break

      case "match_start":
         if( room == roomMultiplayerWaiting ) {
            global.multiplayerStarter = (msg[1] == "0")
            global.connected = true
            global.gameStart = true
            room_goto(room3DGame)
            
         } else {
            show_message("ERROR! match found received while not waiting")
            game_end(-1)
         }
         break

      case "move":
         if( room == room2DGame || room == room3DGame && global.turnPlayer == global.opponent ) {
            var choice = real(msg[1])
            var option = global.options.At(choice)
            ExecuteOption(option,false)
         } else {
            show_message("ERROR! move message received in wrong place")
            game_end(-1)
         }
         break

      default:
         show_message("ERROR! unrecognized message " + msg[0])
         game_end(-1)
   }
}