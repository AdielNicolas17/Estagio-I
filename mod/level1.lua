
-----------requisiçoes--------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

local physics = require "physics"
physics.start()
physics.setGravity( 0, 0 )


----------configuraçao dos grupos----------------------
local backGroup = display.newGroup()  
local mainGroup = display.newGroup()  
local uiGroup = display.newGroup()

-----------variaveis---------------------------------

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




    

------------background--------------------------------
display.setDefault("textureWrapX","mirroredRepeat")

local background = display.newRect( backGroup, display.contentCenterX , display.contentCenterY , 480 , 320)
background.fill={type = "image" , filename = "back11.png"}
local function animateBackground()
	transition.to(background.fill ,{ time = 5000,x=1 ,delta = true,onComplete = animateBackground})
end

animateBackground()


-----------pontuação e vidas------------------------------

livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 20 )
livesText.x = 50
livesText.y = 10
scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 20 )
scoreText.x = 150
scoreText.y = 10
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

local running = display.newSprite(mainGroup,sheet , sequences)
physics.addBody(running,"dynamic" , {radius=50})
running.x = display.contentWidth / 4 + 40
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
		
		--running.touchOffsetX = event.x - running.x
		running.touchOffsetY = event.y - running.y

	elseif ( "moved" == phase ) then
		
		--running.x = event.x - running.touchOffsetX
		running.y = event.y - running.touchOffsetY

	elseif ( "ended" == phase or "cancelled" == phase ) then
		
		display.currentStage:setFocus( nil )
	end

	return true 
end

running:addEventListener( "touch", moveNinja )

--mecanica de atirar

local function fireLaser()
 
    local newLaser = display.newImageRect(mainGroup, "tiro.png", 14, 14)
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
running:addEventListener( "tap", fireLaser )

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
    local lobo = display.newSprite(mainGroup,sheet1 , sequences)
    physics.addBody(lobo,"dynamic" , {radius=30})
    lobo.x = display.contentWidth
    lobo.y = math.random(120,250)
    lobo.xScale = 0.8
    lobo.yScale = 1.2
    lobo:play()
    lobo.myName ="lobo"
     
end


createBoss()



----------- Listener setup---------------------------------------


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
---------esplosoes 	------------------------------------------------------------


function explode()
    local  sheetOptions11 = {width =24 , height = 23, numFrames = 7}

    local explode = graphics.newImageSheet("explosion.png" , sheetOptions11)

    local sequences ={
    {
        name = "normalRun",
        start = 1,
        count = 7,
        time = 480,
        loopCount = 0,
        loopDirection = "forward" 
    }
}

    local explosao = display.newSprite(mainGroup, explode , sequences)
    physics.addBody(explosao ,"dynamic", {isSensor = true})
    explosao.x = running.x
    explosao.y = running.y
    explosao.xScale = 0.8
    explosao.yScale = 1.2
    explosao:toBack()
--    explosao.isVisible = false
    explosao.myName ="explosao"

	
	explosao.isVisible = true
	explosao:play()
	timer.performWithDelay(3000, gameOver, 1)
	
	--running1.isVisible = false
	--timer.performWithDelay(3000, gameOver, 1)

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
        	
            display.remove( obj1 )
            display.remove( obj2 )


                    score = score + 100
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
                    explode()
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


------------------------------------------------------------------------------------
function gameOver()
   storyboard.gotoScene("menu", "fade", 400)
end

--running1.enterFrame = moveInimigos
--Runtime:addEventListener("enterFrame", running1)
return scene