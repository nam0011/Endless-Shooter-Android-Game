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

--define sprite frames
local opt =
{
frames = {
		--Idle pose-
		{ x = 23, y = 35, width = 209, height = 168}, --frame 1
		{ x = 282, y = 35, width = 206, height = 170}, --frame 2
		--right turn pose
		{ x = 539, y = 32, width = 207, height = 174}, --frame 3
		{ x = 797, y = 32, width = 203, height = 176} --frame 4
      --more to come
			
  }
}

-- include sprite image sheet
local sheet = graphics.newImageSheet( "SF01a_strip60.png", opt);

--set the frames for the animation of each of the 6 poses
local seqData = {
	{name = "idle", frames={1,2}, time=500},
	--{name = "right", frames={5, 6, 7, 8, 9}, time = 500, loopCount =1},
	--{name = "left", frames={10, 11, 12}, time = 500, loopCount =1}
}

-- set sprite animation and initial state
local anim = display.newSprite (sheet, seqData);
anim.anchorX = display.contentCenterX;
anim.anchorY = display.viewableContentHeight-60;
anim.x = display.contentCenterX+25;
anim.y = display.viewableContentHeight-30;
anim.xScale = 0.2;
anim.yScale = 0.2;
anim:setSequence("idle");
--play animation based on selected frames
anim:play();

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