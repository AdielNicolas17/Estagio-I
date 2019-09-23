local composer = require( "composer" )

local scene = composer.newScene()

composer.recycleOnSceneChange = true

local gameoverGrupo = display.newGroup()
local gameOverSound
local clickSound

function scene:create( event )

   local sceneGroup = self.view
   gameOverSound = audio.loadSound( "audio/gameOver.mp3" )
   clickSound = audio.loadSound("audio/Click.wav")
   
   audio.reserveChannels( 7 )
   audio.reserveChannels( 8 )

   audio.play( gameOverSound, { channel=7, loops=-1 })

   fundo = display.newImage('image/backgroundGameOver.jpg', display.contentCenterX, display.contentCenterY)
   fundo.width = display.contentWidth
   fundo.height = display.contentHeight
   gameoverGrupo:insert(fundo)

   fimDeJogoTexto = display.newImage('image/endGame.png')
   fimDeJogoTexto.x = display.contentCenterX
   fimDeJogoTexto.y = 240
   fimDeJogoTexto.xScale = 1.0
   fimDeJogoTexto.xScale = 1.0
   gameoverGrupo:insert(fimDeJogoTexto)

   botaoVoltar = display.newImage("image/backBtn.png")
   botaoVoltar.x = display.contentCenterX
   botaoVoltar.y = display.contentCenterY+300
   botaoVoltar.xScale = 0.6
   botaoVoltar.yScale = 0.6
   gameoverGrupo:insert(botaoVoltar)

   function gotoMenu()
      audio.play(clickSound, { channel=8, loops=-1 })
      composer.gotoScene("scenes.menu")
   end
   botaoVoltar:addEventListener("tap", gotoMenu)

end

function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then

   elseif ( phase == "did" ) then

   end
end

function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      audio.stop( 7 )
      audio.stop( 8 )
      display.remove(gameoverGrupo)
   elseif ( phase == "did" ) then

   end
end


function scene:destroy( event )

   local sceneGroup = self.view

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene