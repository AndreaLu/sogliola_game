if mouseHoverTimer > 0 {
   mouseHoverTimer -= delta_time/1000000
   if mouseHoverTimer <= 0 {
      mouseHover = false
      global.hovering = false
  }
}