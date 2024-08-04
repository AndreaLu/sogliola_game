// +----------------------------------------------------------------------+
// | obj3DGUI: Draw GUI Event                                             |
// +----------------------------------------------------------------------+
/*
   This is where the user interaction is taken care of
 */

inputManager.Update()

var w = sprite_get_width(sprBack)
var h = sprite_get_height(sprBack)

// 3d uses culling which prevents 2d graphics from being displayed
gpu_set_cullmode(cull_noculling)

//            _____________________________________________
//#region    | 1.0 Display debug Info                      |
if global.debugMode {
   // Current keys playback frame
   draw_text(0,200,inputManager.playbackFrame)
   // Click Buffer
   if keyboard_check(vk_escape) draw_surface(sf,0,0)
   // Protected aquarium info
   // Draw all the available moves
   //drawY = 100
   //draw_set_color(c_black)
   //global.options.foreach( function(option,ctx) {
   //   draw_text(100,ctx.drawY,option[0])
   //   ctx.drawY += 20
   //},self)
}
//#endregion
//#region    | 2.0 Interazione con il Player               |
//#region    |    2.1 Zoom della Carta                     |
if( !is_undefined(objectHover) && global.turnPlayer == global.player ) {
  
   if is_instanceof( objectHover, Card ) {
      card = objectHover
      
      if ( card.location == global.player.hand && !watching) {
         //card.guiCard.setMouseHover()
         if !global.zooming 
            menu[@array_length(menu)] = [HINT_MBR,"Dettagli"]
         if inputManager.keys.MBR {
            card.guiCard.setZoom()
         }
      }
//#endregion
//#region    |    2.2 Card Picking                         |
//#region    |       2.1.0 Secondo click in poi, su carte  | 
      var options = global.options.FilterAll(function(option,args) {
         var card = args[0]
         return (option[2] == card)
      },[card])
      
      // ------------------------------------------------------------------------------
      // Secondo click in poi, su carte 
      if !watching && !global.zooming && !is_undefined(global.pickingTarget) {
         menu[@array_length(menu)] = [HINT_MBL,"Selezione Target"]
         if inputManager.keys.MBL {
            // Trova tutte le mosse restanti che hanno come target tutti gli elementi
            // attualmente presenti in pickingTarget, oltre alla carta attuale
            options = global.options.FilterAll( function(option,args) {
               // escludi le mosse la cui carta sorgente non sia quella che si vuole 
               // attivare/evocare
               if( option[2] != args[0][0]) return false;
               // crea un array con tutti i target da ricercare nelle mosse
               var targets = []
               array_copy(targets,0,args[0],1,array_length(args[0])-1)
               targets[@array_length(targets)] = args[1]
               // crea un array con tutti i target della mossa
               var optionTargets = (!is_array(option[3])) ? [option[3]] : option[3]
               // verifica che tutti i target in targets siano anche in optionTargets
               var count = 0
               for( var i=0;i<array_length(optionTargets);i++) {
                  var target = optionTargets[i]
                  for( var j=0;j<array_length(targets);j++) {
                     if targets[j] == target {
                        count += 1
                        break
                     }
                  }
                  if count == array_length(targets) {
                     return true
                  }
               }
            },[global.pickingTarget,card])
            
            if array_length(options) == 1 {
               // Esegue la mossa
               var option = options[0]
               ExecuteOption(option,true)
               global.disableUserInput = true
               new StackMoveCamera(
                  global.Blender.CamHand.From,
                  global.Blender.CamHand.To,
                  global.Blender.CamHand.FovY,
                  0.3, function() {
                     global.pickingTarget = undefined
                     global.disableUserInput = false
                  }
               )
            }
            else if array_length(options) > 1 {
               // Se c'era più di una mossa, aggiunge la carta selezionata all'array
               // pickingTarget
               global.pickingTarget[@array_length(global.pickingTarget)] = card
            }
         }
      }
//#endregion
//#region    |       2.1.1 Primo click                     | 

      if !watching && !global.zooming && is_undefined(global.pickingTarget) 
      && array_length(options) > 0 {
         menu[@array_length(menu)] = [HINT_MBL,"Gioca"]
         if( inputManager.keys.MBL ) {
            if( array_length(options) > 1) {
               global.disableUserInput = true
               // Zoom nell'acquario, bisogna scegliere il target
               new StackMoveCamera(
                  global.Blender.CamAq.From,
                  global.Blender.CamAq.To,
                  global.Blender.CamAq.FovY,
                  0.3, function() {
                     global.disableUserInput = false
                  }
               )
               global.pickingTarget = [card]
            }

            // La mossa possibile è una sola. La eseguo, solo se non ci sono target da 
            // cliccare. Se ce ne sono, anche se uno solo, lo lascio scegliere al
            // giocatore
            if( array_length(options) == 1 ) {
               var option = options[0]
               // Se non ci sono target possibili, esegui l'unica mossa possibile
               if (array_length(option) <= 3 || is_undefined(option[3])) {
                  ExecuteOption(option,true)
               } else {
                  global.disableUserInput = true
                  new StackMoveCamera(
                     global.Blender.CamAq.From,
                     global.Blender.CamAq.To,
                     global.Blender.CamAq.FovY,
                     0.3, function() {
                        global.disableUserInput = false
                     }
                  )
                  global.pickingTarget = [card]
               }
            }
         } 
      }
   }
//#endregion
//#region    |       2.1.2 Secondo click (su acquari)      | 

   // secondo click in poi, su acquari. Per ora gli effetti che coinvolgono 
   // gli acquari hanno un solo target possibile, quindi faccio gestione 
   // semplificata. Dovessero sorgere carte con più target, di cui almeno
   // uno acquario, dovrò correggere..
   if is_instanceof( objectHover, Aquarium ) &&
      !is_undefined(global.pickingTarget) {
      
      menu[@array_length(menu)] = [HINT_MBL,"Scegli il bersaglio"]
      if inputManager.keys.MBL {
         // Valuto se, tra le opzioni, si può scegliere l'acquario su cui si sta
         // passando il mouse
         aquarium = objectHover
         var a = global.options.Filter(
            function(option,args) { 
               if array_length(option) < 4 || is_array(option[3]) return false;
               return ( option[3] == args[0] && option[2] == global.pickingTarget[0] )
            },
            [aquarium]
         )
         if !is_undefined(a) {
               // Esegue la mossa
               ExecuteOption(a,true)
               global.disableUserInput = true
               new StackMoveCamera(
                  global.Blender.CamHand.From,
                  global.Blender.CamHand.To,
                  global.Blender.CamHand.FovY,
                  0.3, function() { 
                     global.pickingTarget = undefined
                     global.disableUserInput = false
                  }
               )
         }
      }
   }
}
//#endregion
//#region    |       2.1.3 Annullare un Card Picking       |
// Annullare un cardpicking in corso
if !is_undefined(global.pickingTarget) && !global.disableUserInput 
   && global.stack.size == 0 {

   menu[@array_length(menu)] = [[HINT_MBR,HINT_S],"Annulla"]
   if (inputManager.keys.MBR || inputManager.keys.S)  {
      global.pickingTarget = undefined
      global.disableUserInput = true
      // Torno alla mano, al massimo non accade niente
      new StackMoveCamera(
         global.Blender.CamHand.From,
         global.Blender.CamHand.To,
         global.Blender.CamHand.FovY,
         0.3, function() {
            global.disableUserInput = false
         }
      )
   }
}
//#endregion
//#endregion |                                             |
//#region    |    2.3 Passare il turno                     |

if is_instanceof(objectHover,Bottle) && !passingTurn && !global.zooming && global.canPass &&
global.turnPlayer == global.player && is_undefined(global.pickingTarget) && !watching  {
   global.bottle.highlight = 1
   menu[@array_length(menu)] = [HINT_MBL,"Passa il Turno"]
   if inputManager.keys.MBL {
      passingTurn = true
      new StackWait(0.1, function () {
         var test = global.options.Filter( function(option) {
            return option[0] == "Pass the turn"
         })
         if ! is_undefined(test) {
            var option = test
            ExecuteOption(option,true, function() {
               if global.turnPlayer.deck.size > 0
                  new StackMoveCamera(
                     global.Blender.CamOpponent.From,
                     global.Blender.CamOpponent.To,
                     global.Blender.CamOpponent.FovY,
                     0.3, function() {
                        global.disableUserInput = false
                        obj3DGUI.passingTurn = false
                     }
                  )
            })
            global.disableUserInput = true
            
         }
      })
   }
} else {
   global.bottle.highlight = 0
}
//#endregion |                                             |
//#region    |    2.4 W and S keys                         |

if !watching && is_undefined(global.pickingTarget)
   && global.turnPlayer == global.player && !global.zooming && !global.disableUserInput {

   menu[@array_length(menu)] = [HINT_W,"Zoom sull'Acquario"]
   if inputManager.keys.W {
      watching = true
      camTransition = true
      global.disableUserInput = true
      new StackMoveCamera(
         global.Blender.CamAq.From,
         global.Blender.CamAq.To,
         global.Blender.CamAq.FovY,
         0.3, function() {
            time_source_start(
               time_source_create(
                  time_source_game,0.1,
                  time_source_units_seconds, function() {
                  obj3DGUI.watchingBack = false
                  obj3DGUI.camTransition = false
                  global.disableUserInput = false
               })
            )
         }
      )
   }
}

if watching  && !watchingBack && !global.zooming 
&& global.stack.size == 0 {

   menu[@array_length(menu)] = [HINT_S,"Indietro"]
   if inputManager.keys.S {
      watchingBack = true
      camTransition = true
      global.disableUserInput = true
      new StackMoveCamera(
         global.Blender.CamHand.From,
         global.Blender.CamHand.To,
         global.Blender.CamHand.FovY,
         0.3, function() {
            obj3DGUI.watchingBack = true
            time_source_start(
               time_source_create(
                  time_source_game,0.1,
                  time_source_units_seconds, function() {
                  obj3DGUI.watching = false
                  obj3DGUI.camTransition = false
                  global.disableUserInput = false
               })
            )
            
         }
      )
   }
}
//#endregion |                                             |
//#region    | 3.0 Draw the Cursor                         |
draw_sprite_ext(
   sprCursor,
   mouse_check_button(mb_any) ? 1 : 0,        // subimg
   inputManager.mouse.X,inputManager.mouse.Y, // x,y
   2,2,0, c_white,1                           // scale,rot,col,alpha
)
opponentCursor.Draw()

//#endregion |                                             |
//#endregion |                                             |
//#region    | 4.0 Stack                                   |


//#endregion |                                             |
//#region    | 5.0 Generating text surface                 |
with(obj3DCard) {
   if !is_undefined(card) {
      if !is_instanceof(card.location,Deck) {
         if (!surface_exists(surfSprite)) {
            var w = 192;
            var h = 256;
            surfSprite = surface_create(w, h);
            surface_set_target(surfSprite);
            draw_clear_alpha(#30172c, 0);
            draw_sprite_ext(card.sprite, 0, w/2, h/2, 2, 2, 0, c_white, 1);
            draw_set_color(#30172c);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_font(fntCards);
            draw_text(w/2,h*0.06,card.name);
            draw_text_ext(w/2,h/2+h*0.16,card.desc,12, w*0.94);
            if is_instanceof(card,FishCard) {
               draw_set_font(fntValue);
               draw_text(w/2,h*0.88,string(card.Val()));
            }
            surface_reset_target();
         }
      }
   }
}
//#endregion |                                             |
//#region    | 5.1 HUD                                     |
//#region    |    5.1.0 Control hints                      |

if( global.drawHints ) {
   var k = array_length(menu);
   var a = 0.8;
   if k > 0 {
      var padding = 6;
      var w = 230;
      var h = k * 32 + (k-1)*padding;
      var menuX = getW()-w;
      var menuY = getH()-h;
      draw_set_color(c_black);
      draw_set_alpha(0.7*a);
      draw_roundrect(menuX-16-padding, menuY-16-padding, menuX+w-16+padding, menuY+h-16+padding, 0);
      draw_set_color(c_white);
      draw_set_alpha(1*a);
      for (var i=0; i<k; i++){
         if is_array(menu[i][0]) {
            for( var j=0;j<array_length(menu[i][0]);j+=1) {
               var icon = menu[i][0][j]
               draw_sprite_ext(sprHints,icon,menuX+32*j,menuY+i*(32+padding),1,1,0,c_white,1*a)
            }
         } else {
            draw_sprite_ext(sprHints,menu[i][0],menuX,menuY+i*(32+padding),1,1,0,c_white,1*a)
         }
         draw_set_font(fntBasic)
         draw_set_valign(fa_middle)
         draw_set_halign(fa_left)
         var l = is_array(menu[i][0]) ? array_length(menu[i][0]) : 1
         draw_text(menuX+16+padding+(l-1)*32,menuY+i*(32+padding),menu[i][1])
      }
      draw_set_color(c_black);
      draw_set_alpha(1);
   }
}
//#endregion |                                             |
//#region    |    5.1.2 Punteggio                          |


//draw_set_color(c_black);
//draw_set_alpha(0.7*a);
//draw_roundrect(0,100, 120, 300, 0);
//draw_set_color(c_white);
//draw_set_alpha(1*a);

var w = sprite_get_width(sprScore)
draw_sprite_ext(sprScore,0, 
   w*3/2 + 10, w*3/2 + 10 ,
3,3,0,c_white,1)
draw_sprite_ext(sprScore,0, 
   getW() - w*3/2 + 10, w*3/2 + 10 ,
3,3,0,c_white,1)






prev = round(targetScoreOp)
targetScoreOp = lerp(targetScoreOp,getScore(global.opponent),0.03)
if round(targetScoreOp) != prev {
   opScoreScal = 1.5
   opScoreRot = random_range(-5,5)
}
opScoreScal = lerp(opScoreScal,1,0.1)
opScoreRot = lerp(opScoreRot,0,0.1)

if !surface_exists(sfScore)
   sfScore = surface_create(100,100)


surface_set_target(sfScore)
draw_clear_alpha(c_black,0)

draw_set_color(c_black)
draw_set_font(fntScore)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text(50,50,string(round(targetScoreOp)))
surface_reset_target()

draw_surface_ext(sfScore,
   getW() - w*3/2 + 10 -50*opScoreScal, w*3/2 + 10 - 50*opScoreScal,
   opScoreScal,opScoreScal,opScoreRot,c_white, 1)




prev = round(targetScore)
targetScore = lerp(targetScore,getScore(global.player),0.03)
if round(targetScore) != prev {
   ScoreScal = 1.5
   ScoreRot = random_range(-5,5)
}
ScoreScal = lerp(ScoreScal,1,0.1)
ScoreRot = lerp(ScoreRot,0,0.1)

surface_set_target(sfScore)
draw_clear_alpha(c_black,0)

draw_set_color(c_black)
draw_set_font(fntScore)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text(50,50,string(round(targetScore)))
surface_reset_target()

draw_surface_ext(sfScore,
   w*3/2 + 10 -50*ScoreScal, w*3/2 + 10 - 50*ScoreScal,
   ScoreScal,ScoreScal,ScoreRot,c_white, 1)






//#endregion |                                             |
//#endregion |                                             |
//#endregion |                                             |
//#endregion |                                             |
//           |_____________________________________________|
if global.stack.size > 0 {
   var stackChain = global.stack.At(0)
   stackChain.Update()
   if stackChain.done {
      if !is_undefined(stackChain.Callback) {
         stackChain.Callback(stackChain.cbArgs)
      }
      global.stack.RemoveAt(0)
   }
}

// restore culling for next 3d rendering
gpu_set_cullmode(cull_clockwise)




