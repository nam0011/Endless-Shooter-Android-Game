---------------------------------------------------------------------------------------------------
--  Group Project: CS371, Instructor: Dr Chung, Program: Navigate ship through aliens,
--   Filename: scene2.lua, Purpose: Overlay before and after game.
--   Author:   Natalie Bush, nlb0017@uah.edu, Nathan Moore, Aaron Mendez. Created:  2021-11-08
---------------------------------------------------------------------------------------------------

local composer = require( "composer" )
local widget = require("widget")

local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

local function play (event)
   --set effects for scene transition
   local ops = {
     effect = "fade",
     time = 500
   }
   composer.gotoScene("game", ops)
end

--create scene
function scene:create( event )

   local sceneGroup = self.view

   -- Create the title
   --self.title = display.newText(sceneGroup, "X-GLIDER", display.contentCenterX+10, display.contentCenterY-50, font, 48)

   --create the title
   local title =
   {
       text = "X-GLIDER",
       x = display.contentCenterX+10,
       y = display.contentCenterY-50,
       --width = 250,
       font = native.systemFont,
       fontSize = 45,
       align = "center"  -- Alignment parameter
   }
   local titleLabel = display.newText( title )
   sceneGroup:insert(titleLabel);

   --background is a large semi-transparent rounded rectangle
   local background = display.newRoundedRect(display.contentCenterX,display.contentCenterY,
                        display.viewableContentWidth+100,display.actualContentHeight, 12);
   background.strokeWidth = 2
   background:setFillColor( 0.5 )
   background:setStrokeColor( 0.5, 0.5, 0.5 )
   --set transparency
   background.alpha = 0.3
   --add background to scene group so it is removed when scene is removed
   sceneGroup:insert(background);


   --button to close scene and go back to previous scene
   local buttonPlay = widget.newButton(
     {
        left = display.contentCenterX-70,
        top = display.contentCenterY,
        label = "PLAY",
        labelColor = { default={ 0.8, 0.8, 0.8 }, over={ 0, 0, 0, 0.5 } },
        onRelease = buttonPlay,
        emboss = true,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = display.contentWidth / 3,
        height = display.contentHeight / 8,
        cornerRadius = 4,
        fillColor = { default={0.4,0.4,0.4,1}, over={ 0.8, 0.8, 0.8 ,0.4} },
        strokeColor = { default={0.4,0.4,0.47,1}, over={ 0.8, 0.8, 0.8 ,0.4} },
        strokeWidth = 2,
        emboss = true
     }
   )
   --add button to scene group
   sceneGroup:insert(buttonPlay);

   --listen for button click
   buttonPlay:addEventListener("tap", play);

end

--local function closeText()

--  gameoverGroup.text.isVisible = false

--end
-- show scene
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).

   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
      --timer2 = timer.performWithDelay(delay,update,0)
      --Game Over Text
      --if (gameoverGroup.text) then
      --  timer.performWithDelay(2000,closeText,1)
      --end
    end
end

--hide scene
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase
   --gameoverDisplay.text.isVisible = false
   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
      --timer.cancel(timer2)
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.

      transition.cancelAll()
   end
end

--destroy scene
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

--listen for these events
scene:addEventListener("create", scene )
scene:addEventListener("show", scene )
scene:addEventListener("hide", scene )
scene:addEventListener("destroy", scene )



return scene
