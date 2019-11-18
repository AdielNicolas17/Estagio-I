local composer = require( "composer" )
composer.recycleOnSceneChange = true
local scene = composer.newScene()

local widget = require "widget"

local gameOverSound

local playBtn
local menuButton
local boss
local contadorChangeBoss = 0

local backGroup = display.newGroup()  
local mainGroup = display.newGroup()  
local uiGroup = display.newGroup()
--------------------------------------------
local json = require( "json" )

local scoresTable = {}

local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )


local function loadScores()

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end
local function saveScores()

	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
	end

	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end
--------------------------------------------

local function onPlayBtnRelease()
	audio.stop( 2 )
	
	display.remove(backGroup)
	composer.gotoScene( "level1", "fade", 500 )
	return true	
end


function scene:create( event )
	
	audio.reserveChannels( 2 )
	gameOverSound = audio.loadSound( "audio/fim.mp3" )
	audio.play( gameOverSound, { channel=2, loops=-1 })


	table.insert( scoresTable, composer.getVariable( "finalScore" ) )
	composer.setVariable( "finalScore", 0 ) 
	
	local function compare( a, b )
        return a > b
	end
	
    table.sort( scoresTable, compare )

	saveScores()
	
    for i = 1, 10 do
        if ( scoresTable[i] ) then
            local yPos = 130 + ( i * 56 )

            local rankNum = display.newText( uiGroup, i .. ")", display.contentCenterX, yPos, native.newFont( "chiller"), 25 )
            rankNum:setFillColor( 0.8 )
            rankNum.anchorX = 1

            local thisScore = display.newText( uiGroup, scoresTable[i], display.contentCenterX, yPos, native.newFont( "chiller"), 25 )
            thisScore.anchorX = 0
        end
	end

	display.setDefault("textureWrapX","mirroredRepeat")
	local backcloud = display.newRect( backGroup ,display.contentCenterX , display.contentCenterY , 480 , 320)
	backcloud.fill={type = "image" , filename = "cloud.png" }
	backcloud.alpha = 0.6
	local function animateCloud()

			transition.to(backcloud.fill ,{ time = 8000,x=1 ,delta = true, onComplete = animateCloud})
			
	end
	backGroup:insert(mainGroup)
	animateCloud()
	local sceneGroup = self.view


	local background = display.newImageRect( backGroup,"backg.png" , 480 , 320)
	background.x = display.contentCenterX
	background.y =  display.contentCenterY
	background:toBack()
	--background.x = 120 + display.screenOriginX 
	--background.y = 0 + display.screenOriginY

	--------------try------------------------------------------------------------------------------------------------------	
    scoreText = display.newText( backGroup,"Try Again ", 400, 80, native.newFont( "chiller"), 25  )
    scoreText.x = display.contentCenterX - 150
    scoreText.y = display.contentCenterY - 140
	playBtn = widget.newButton{
		label="",
		labelColor = { default={200}, over={0} },
		width=50, height=30,
		onRelease = onPlayBtnRelease	
	}
	playBtn.alpha = 0.008
	playBtn.x = display.contentCenterX - 150
	playBtn.y = display.contentCenterY - 150
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	--sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
--------------try------------------------------------------------------------------------------------------------------	-----	

end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		--audio.play( musicTrack, { channel=1, loops=-1 } )
	
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if (event.phase == "will") then
		display.remove(uiGroup)
        display.remove(mainGroup)
		
	elseif (phase == "did") then
		composer.removeScene( "highscores" )
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------


-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene