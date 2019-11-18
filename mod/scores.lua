local composer = require( "composer" )
composer.recycleOnSceneChange = true
local scene = composer.newScene()


-- include Corona's "widget" library
local widget = require "widget"

local gameOverSound

local backGroup = display.newGroup()  
local mainGroup = display.newGroup()  
local uiGroup = display.newGroup()
--------------------------------------------

--------------------------------------------
-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
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
	
    scoreText = display.newText( "Try Again ", 400, 80, native.newFont( "chiller"), 25  )
    scoreText.x = display.contentCenterX - 150
    scoreText.y = display.contentCenterY - 150
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
		-- Called when the scene is now off screen
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