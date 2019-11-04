audio.pause( musicPlay ,{ channel=3, loops=-1})

audio.reserveChannels( 5 )
fim = audio.loadStream( "audio/fim.mp3" )
audio.play( fim,{ channel=5, loops=-1})

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------
display.setDefault("textureWrapX","mirroredRepeat")

local backcloud = display.newRect( display.contentCenterX , display.contentCenterY , 480 , 320)
backcloud.fill={type = "image" , filename = "cloud.png" }
backcloud.alpha = 0.6
local function animateCloud()

		transition.to(backcloud.fill ,{ time = 8000,x=1 ,delta = true, onComplete = animateCloud})
		
end
animateCloud()
--------------------------------------------
-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end
local function gotoScores()
	composer.gotoScene( "scores", { time=800, effect="crossFade" } )
end

function scene:create( event )
	local sceneGroup = self.view


	local background = display.newImageRect( "backg.png" , 480 , 320)
	background.x = display.contentCenterX
	background.y =  display.contentCenterY
	--background.x = 120 + display.screenOriginX 
	--background.y = 0 + display.screenOriginY
	
    scoreText = display.newText( "Try Again ", 400, 80, native.newFont( "chiller"), 25  )
    scoreText.x = display.contentCenterX
    scoreText.y = display.contentCenterY - 50
	playBtn = widget.newButton{
		label="",
		labelColor = { default={200}, over={128} },
		width=50, height=30,
		onRelease = onPlayBtnRelease	
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentCenterY - 50
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	--sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	musicTrack = audio.loadStream( "audio/start.mp3" )
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
		audio.play( musicTrack, { channel=1, loops=-1 } )
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
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