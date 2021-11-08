---------------------------------------------------------------------------------------------------
--  Group Project: CS371, Instructor: Dr Chung, Program: Navigate ship through aliens,
--	  Filename: scene1.lua, Purpose: Background, aliens, text, controls, & ship handles.
--	  Author:   Natalie Bush, nlb0017@uah.edu, Nathan Moore, Aaron Mendez. Created:  2021-11-08
---------------------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

--set background image
local background = display.newImageRect( "background.png",
               (display.viewableContentWidth*1.2), display.viewableContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY
background:toBack()

--initialize text for current score
local options = 
{
    text = "Score:",     
    x = display.viewableContentWidth/10,
    y = display.viewableContentHeight/10,
    width = 150,
    font = native.systemFont,   
    fontSize = 16,
    align = "left"  -- Alignment parameter
} 
scoreLabel = display.newText( options )

--initialize text for high score
options = 
{
    text = "High Score:",     
    x = display.viewableContentWidth-60,
    y = display.viewableContentHeight/10,
    width = 150,
    font = native.systemFont,   
    fontSize = 16,
    align = "right"  -- Alignment parameter
}
highscoreLabel = display.newText(options)

--globals
score = 27
best = 0
delayOrigin = 20
delay = 20

--create initial scene
function scene:create( event )
   local sceneGroup = self.view

	--create Left button
	local buttonLeft = widget.newButton(
	    {
			x = (display.viewableContentWidth/10)-30,
			y = display.viewableContentHeight-60,
         id = "options",
         --label = "<",
         labelColor = { default={ 0.8, 0.8, 0.8 }, over={ 0, 0, 0, 0.5 } },
         onEvent = handleKickEvent,
         emboss = true,
         -- Properties for a rounded rectangle button
         shape = "circle",
         radius = 40,
         fillColor = { default={0.4,0.4,0.4,1}, over={ 0.8, 0.8, 0.8 ,0.4} },
         strokeColor = { default={0,0,0,1}, over={0.8,0.8,1,1} },
         strokeWidth = 2,
	    }
	)
	--set transparency
	buttonLeft.alpha = 0.1
	--add button to sceneGroup
	sceneGroup:insert(buttonLeft);

	--create Right button
	local buttonRight = widget.newButton(
	    {
			x = display.viewableContentWidth-20,
			y = display.viewableContentHeight-60,
         id = "options",
         --label = "<",
         labelColor = { default={ 0.8, 0.8, 0.8 }, over={ 0, 0, 0, 0.5 } },
         onEvent = handleKickEvent,
         emboss = true,
         -- Properties for a rounded rectangle button
         shape = "circle",
         radius = 40,
         fillColor = { default={0.4,0.4,0.4,1}, over={ 0.8, 0.8, 0.8 ,0.4} },
         strokeColor = { default={0,0,0,1}, over={0.8,0.8,1,1} },
         strokeWidth = 2,
	    }
	)
	--set transparency
	buttonRight.alpha = 0.1
	--add button to sceneGroup
	sceneGroup:insert(buttonRight);

	
   --update fatalities with value
   scoreLabel.text = "Score: " .. score

   --update high score with value
   highscoreLabel.text = "High Score: " .. best

   --set effects for scene transition
   local options = {
      effect = "slideDown",
      time = 100
   }

   --scene2 called on button click
   local function next (event)
     composer.gotoScene("scene2", options);
   end
   --listen for button click
   buttonLeft:addEventListener("tap", next);

end  --end create scene

--update if needed
function update()

end

--show scene
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
   	
   elseif ( phase == "did" ) then
   	--start timer when scene is shown
   	timer1 = timer.performWithDelay(delay,update,0)
   end
end
 
--hide scene
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
   	--cancel timer before moving to next scene
   	timer.cancel(timer1)
   elseif ( phase == "did" ) then

   end
end
 
--destroy scene
function scene:destroy( event )
   local sceneGroup = self.view
end
 
--listen for these events
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene