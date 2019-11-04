audio.pause( musicTrack, { channel=1, loops=-1 } )
audio.reserveChannels( 3 )
musicPlay = audio.loadStream( "audio/ninjaplay.wav" )
audio.play( musicPlay ,{ channel=3, loops=-1})
-----------requisiçoes--------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local physics = require "physics"
physics.start()
physics.setGravity( 0, 0 )
--physics.setDrawMode("hybrid")

----------configuraçao dos grupos----------------------
local backGroup = display.newGroup()  
local mainGroup = display.newGroup()  
local uiGroup = display.newGroup()

-----------variaveis---------------------------------
local tt
local tt1
local morto
local morrer
local base = 280
local lives = 3
local score = 0
local died = false
local inimigosTable = {}
local gameLoopTimer
local ninja
local gameLoopTimer
local livesText
local scoreText
local soundShot =  audio.loadStream( "audio/fire.wav" )

--

    

function scene:create( event )
    local sceneGroup = self.view

    ------------background--------------------------------
    display.setDefault("textureWrapX","mirroredRepeat")

    local background = display.newRect( backGroup, display.contentCenterX , display.contentCenterY , 480 , 320)
    background.fill={type = "image" , filename = "back11.png"}

    local function animateBackground()

            transition.to(background.fill ,{ time = 5000,x=1 ,delta = true, onComplete = animateBackground})
            
    end
    animateBackground()

    -----------pontuação e vidas------------------------------

    livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.newFont( "chiller"), 25 )
    livesText.x = 45
    livesText.y = 15
    scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.newFont( "chiller"), 25  )
    scoreText.x = 130
    scoreText.y = 15
    local function updateText()
        livesText.text = "Lives: " .. lives
        scoreText.text = "Score: " .. score
    end
    -----------config ninja ----------------------------------

    local  sheetOptions = {width =93.5 , height = 84, numFrames = 6}

    local sheet = graphics.newImageSheet("ninja22.png" , sheetOptions)

    local sequences ={
        {
            name = "normalRun",
            start = 1,
            count = 6,
            time = 480,
            loopCount = 0,
            loopDirection = "forward"
        }
    }

    running = display.newSprite(mainGroup,sheet , sequences)
    physics.addBody(running,"dynamic" , {radius=25})
    running.x = display.contentWidth - 400
    running.y = 200
    running.xScale = 0.8
    running.yScale = 1.2
    running:play()
    running.myName ="running"

    -- movimentaçao do ninja touch
    local function moveNinja( event )

        local running = event.target
        local phase = event.phase

        if ( "began" == phase ) then
            display.currentStage:setFocus( running )
            
            running.touchOffsetX = event.x - running.x
            running.touchOffsetY = event.y - running.y

        elseif ( "moved" == phase ) then
            
            running.x = event.x - running.touchOffsetX
            running.y = event.y - running.touchOffsetY

        elseif ( "ended" == phase or "cancelled" == phase ) then
            
            display.currentStage:setFocus( nil )
        end

        return true 
    end
    local tt1 = display.newRect(250,500,250,500)
    tt1.x = 125
    tt1.y = 200
    backGroup:insert(tt1)
    --tt.isVisible=false
    tt1:toBack()
    running:addEventListener( "touch", moveNinja )

    --mecanica de atirar

    local function fireLaser()
        audio.play( soundShot )
        local newLaser = display.newImageRect(mainGroup, "tiro.png", 8, 4)
        physics.addBody( newLaser, "dynamic", { isSensor=true } )
        newLaser.isBullet = true
        newLaser.myName = "laser"
        newLaser.x = running.x
        newLaser.y = running.y
        newLaser:toBack()
        transition.to( newLaser, { x=1140, time=1000,
            onComplete = function() display.remove( newLaser ) end
        } )

    end
    local tt = display.newRect(250,500,250,500)
    tt.x = 360
    tt.y = 200
    backGroup:insert(tt)
    --tt.isVisible=false
    tt:toBack()
    tt:addEventListener( "tap", fireLaser )

    -- restaurar ninja 
    local function restoreNinja()
    
        running.isBodyActive = false
        running.x = display.contentCenterX-150
        running.y = display.contentHeight - 100
    

        transition.to( running, { alpha=1, time=4000,
            onComplete = function()
                running.isBodyActive = true
                died = false
            end
        } )
    end

    ------------ inimigos---------------------------------------------------------------
    


    -- criando inimigos
    local function createBoss()
        
        local  sheetOptions2 = {width =93.5 , height = 84, numFrames = 6}
        local sheet1 = graphics.newImageSheet("monster2.png" , sheetOptions2)

        local sequences1 ={
        {
            name = "normalRun",
            start = 1,
            count = 6,
            time = 800,
            loopCount = 0,
            loopDirection = "forward"
        }
    }
        local lobo = display.newSprite(mainGroup,sheet1 , sequences)
        physics.addBody(lobo,"dynamic" , {radius=30})
        lobo.speed = 1
        lobo.x = display.contentWidth
        lobo.y = math.random(120,250)
        lobo.xScale = 0.8
        lobo.yScale = 1.2
        lobo:play()
        lobo.myName ="lobo"    

        local function moveInimigos()
    --        print (lobo.x)
        
        if(lobo.x ~= nil)then
            lobo.x = lobo.x - lobo.speed
            end
        end

        lobo.enterFrame = moveInimigos
        Runtime:addEventListener("enterFrame", lobo)

        function morteLobo()
            local  sheetOptions12 = {width =95.3 , height = 84, numFrames = 6}
            
            local morrer = graphics.newImageSheet("explosion1.png" , sheetOptions12)
            
            local sequences ={
            {
                name = "explosion",
                start = 1,
                count = 6,
                time = 800,
                loopCount = 1,
                loopDirection = "forward"
            }
            }
            local mortol = display.newSprite(mainGroup, morrer , sequences)
            physics.addBody(morrer,"dynamic" , {radius=30})
            mortol.x = lobo.x 
            mortol.y = lobo.y
            mortol.xScale = 0.8
            mortol.yScale = 1.2
            --mortol:toBack()
            --morto.isVisible = false
            mortol.myName ="mortol"
        
        
            mortol.isVisible = true
            mortol:play()

            function limpaexp()
                display.remove(mortol)
            end
            timer.performWithDelay(500 , limpaexp , -1)    
            
        end

    end

    criarPumba = timer.performWithDelay(4000 , createBoss , -10)

    --------------------------
    local function createBoss()
        
        local  sheetOptions2 = {width =93.5 , height = 84, numFrames = 6}
        local sheet1 = graphics.newImageSheet("lobo.png" , sheetOptions2)

        local sequences1 ={
        {
            name = "normalRun",
            start = 1,
            count = 6,
            time = 800,
            loopCount = 0,
            loopDirection = "forward"
        }
    }
        local pumba = display.newSprite(mainGroup,sheet1 , sequences)
        physics.addBody(pumba,"dynamic" , {radius=30})
        pumba.speed = 1
        pumba.x = display.contentWidth
        pumba.y = math.random(120,250)
        pumba.xScale = 0.8
        pumba.yScale = 1.2
        pumba:play()
        pumba.myName ="pumba"    

        local function moveInimigos()
    --        print (lobo.x)
        
        if(pumba.x ~= nil)then
            pumba.x = pumba.x - pumba.speed
            end
        end

        pumba.enterFrame = moveInimigos
        Runtime:addEventListener("enterFrame", pumba)

        function morteLobo()
            local  sheetOptions12 = {width =95.3 , height = 84, numFrames = 6}
            
            local morrer = graphics.newImageSheet("explosion1.png" , sheetOptions12)
            
            local sequences ={
            {
                name = "explosion",
                start = 1,
                count = 6,
                time = 800,
                loopCount = 1,
                loopDirection = "forward"
            }
            }
            local mortol = display.newSprite(mainGroup, morrer , sequences)
            physics.addBody(morrer,"dynamic" , {radius=30})
            mortol.x = pumba.x 
            mortol.y = pumba.y
            mortol.xScale = 0.8
            mortol.yScale = 1.2
            --mortol:toBack()
            --morto.isVisible = false
            mortol.myName ="mortol"
        
        
            mortol.isVisible = true
            mortol:play()

            function limpaexp()
                display.remove(mortol)
            end
            timer.performWithDelay(500 , limpaexp , -1)    
            
        end

    end

    criarLobo = timer.performWithDelay(10000 , createBoss , -1)


    ----------- Listener setup---------------------------------------


    scene:addEventListener( "create", scene )
    scene:addEventListener( "show", scene )
    scene:addEventListener( "hide", scene )
    scene:addEventListener( "destroy", scene )
    ---------esplosoes 	------------------------------------------------------------


    function morrer()
        transition.cancel( )
        local  sheetOptions11 = {width =116 , height = 40, numFrames = 1}

        local morrer = graphics.newImageSheet("morte.png" , sheetOptions11)

        local sequences ={
        {
            name = "normalRun",
            start = 1,
            count = 1,
            time = 480,
            loopCount = 0,
            loopDirection = "forward" 
        }
    }

        local morto = display.newSprite(mainGroup, morrer , sequences)
        physics.addBody(morto ,"dynamic", {isSensor = true})
        morto.x = running.x
        morto.y = running.y
        morto.xScale = 0.8
        morto.yScale = 1.2
        morto:toBack()
    --    morto.isVisible = false
        morto.myName ="morto"

        
        morto.isVisible = true
        morto:play()

        timer.performWithDelay(3000, gameOuver )
        
        --running1.isVisible = false
        --timer.performWithDelay(3000, gameOuver, 1)

    end


    ------------------------------------------------------------------------------------
    ---------colisoes------------------------------------------------------------
    local function onCollision( event )
    
        if ( event.phase == "began" ) then
    
            local obj1 = event.object1
            local obj2 = event.object2
            
            if ( ( obj1.myName == "laser" and obj2.myName == "lobo" ) or
                ( obj1.myName == "lobo" and obj2.myName == "laser" ) )
            
            then
                --deathLobo = audio.loadStream( "audio/mlobo.wav" )
                --audio.play(deathLobo)
                morteLobo()
                display.remove( obj1 )
                display.remove( obj2 )
            elseif ( ( obj1.myName == "laser" and obj2.myName == "pumba" ) or
                ( obj1.myName == "pumba" and obj2.myName == "laser" ) )
            
            then
                --deathLobo = audio.loadStream( "audio/mlobo.wav" )
                --audio.play(deathLobo)
                morteLobo()
                display.remove( obj1 )
                display.remove( obj2 )
                


                        score = score + 10
                scoreText.text = "Score: " .. score

            elseif ( ( obj1.myName == "running" and obj2.myName == "lobo" ) or
                    ( obj1.myName == "lobo" and obj2.myName == "running" ) )
            then  
                if ( died == false ) then
                    died = true
                    lives = lives - 1
                    livesText.text = "Lives: " .. lives
                    if ( lives == 0 ) then
                        display.remove( running )
                        morrer()
                        timer.performWithDelay( 200, gameOuver )
                    else
                        running.alpha = 0
                        timer.performWithDelay( 1000, restoreNinja )
                    
                    end
                end          
            end
        end
    end
    Runtime:addEventListener( "collision", onCollision )


    -----------limites da tela de jogo------------------------
    local limite = display.newImage("lm.png")
    limite.x = 230
    limite.y = -30
    physics.addBody(limite , "static",{density=.1, bounce=0.1, friction=.2})

    local limite1 = display.newImage("lm.png")
    limite1.x = 230
    limite1.y = 320
    physics.addBody(limite1 , "static" ,{density=.1, bounce=0.1, friction=.2})

    --------------------------fim de jogo--------------------------
    local function endGame()
        composer.setVariable( "finalScore", score )
        composer.gotoScene( "scores", { time=1800, effect="crossFade" } )
    end
    function gameOuver()
        composer.gotoScene("gameover" , { time=1800, effect="crossFade" })
    end
end
------------------- remove------------------------------------------------
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
	elseif phase == "did" then
        audio.play( fim,{ channel=5, loops=-1})
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
              
        display.remove(uiGroup)
        display.remove(mainGroup)
        display.remove(backGroup)
        timer.cancel(criarLobo)
        timer.cancel(criarPumba)
    elseif phase == "did" then
        audio.stop( 3 )
		composer.removeScene( "level1" )
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