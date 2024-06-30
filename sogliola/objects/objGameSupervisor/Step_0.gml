while( true ) {
   supervisor.Activate( noone, EventType.TURN_DRAW, global.supervisor)
   turnPlayer.Draw()
   
   // Tutte le mosse possibili verranno elencate in options dalle carte
   ds_list_clear(global.options)
   global.fishPlayed = false
   supervisor.Activate( noone, EventType.TURN_MAIN, global.supervisor)
   
   // End of turn, switch player
   turnPlayer = (turnPlayer == player) ? opponent : player;
}