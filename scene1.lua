---------------------------------------------------------------------------------------------------
--  Group Project: CS371, Instructor: Dr Chung, Program: Navigate ship through aliens,
--	  Filename: scene1.lua, Purpose: Background, aliens, text, controls, & ship handles.
--	  Author:   Natalie Bush, nlb0017@uah.edu, Nathan Moore, Aaron Mendez. Created:  2021-11-08
---------------------------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 3 )
local composer = require( "composer" )
local scene = composer.newScene()



--globals
best = 0
delay = 90
--locals
local score = 0
local life = 1;
--local timerRef = timer.performWithDelay( 
--1000, 
--function() 
--end, 
--0 
--)

--separating for OO requirements later
---------------------------------------------------------------------------------------------------
-- Sprites
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
anim.y = display.viewableContentHeight-70;
anim.xScale = 0.15;
anim.yScale = 0.15;
anim:setSequence("idle");
--play animation based on selected frames
anim:toBack()
anim:play();

---------------------------------------------------------------------------------------------------

--set background image
local background = display.newImageRect( "background.png",
               (display.viewableContentWidth*1.2), display.viewableContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY
background:toBack()

---------------------------------------------------------------------------------------------------
-- Scoring Text
--initialize text for current score
local header = 
{
    text = "Score:",     
    x = display.viewableContentWidth/10,
    y = display.viewableContentHeight/10,
    width = 150,
    font = native.systemFont,   
    fontSize = 16,
    align = "left"  -- Alignment parameter
} 
scoreLabel = display.newText( header )

--initialize text for high score
header = 
{
    text = "High Score:",     
    x = display.viewableContentWidth-60,
    y = display.viewableContentHeight/10,
    width = 150,
    font = native.systemFont,   
    fontSize = 16,
    align = "right"  -- Alignment parameter
}
highscoreLabel = display.newText(header)


---------------------------------------------------------------------------------------------------
-- Create Scene
--create initial scene
function scene:create( event )
   local sceneGroup = self.view

	--create Left button
	local buttonLeft = widget.newButton(
	    {
			x = (display.viewableContentWidth/10)-30,
			y = display.viewableContentHeight-60,
         id = "left",
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
	buttonLeft:toBack()
	--add button to sceneGroup
	sceneGroup:insert(buttonLeft);

	--create Right button
	local buttonRight = widget.newButton(
	    {
			x = display.viewableContentWidth-20,
			y = display.viewableContentHeight-60,
         id = "right",
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
	buttonRight:toBack()
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

   --scene2 call on game over
   local function gameOver (event)
     composer.gotoScene("scene2", options);
   end
   --listen for button click
   --buttonLeft:addEventListener("tap", next);


end  --end create scene

---------------------------------------------------------------------------------------------------
-- raindrops
local function rain (event)
	if (life==0) then return end;
	local drop = display.newRect(math.random(0, display.contentWidth), 0, 5, 20);
	physics.addBody ( drop, { density=1, friction=2, bounce=0 }, "dynamic" );--( crate, { density=3.0, friction=0.5, bounce=0.3 } )
	drop:setFillColor (math.random(), math.random(), 0.5);	
	drop:applyForce(0,-1, drop.x, drop.y);
	drop.isSensor = true;

	local timeVal = 1500;
	local function dropHandler (event)
		if (event.phase == "ended") then
			event.target:removeEventListener("collision", dropHandler);
			event.target:removeSelf();
			event.target = nil;
			if (timeVal > 0) then
				timeVal = timeVal - 10
			end
			--timer.performWithDelay(timeVal, rain, 0);
		end
	end
	drop:addEventListener("collision", dropHandler);

end


---------------------------------------------------------------------------------------------------
-- Updating whatever, may not need
--update if needed
function update()

end

---------------------------------------------------------------------------------------------------
-- Events
local timer1 = timer.performWithDelay(delay, rain, 0)
--show scene
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
   	--physics.start()

   elseif ( phase == "did" ) then
   	--start timer when scene is shown
   	timer1 = timer.performWithDelay(delay,rain,0)
   end
end
 
--hide scene
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
   	--cancel timer before moving to next scene
   	timer.cancel(timer1)
   	--physics.stop()
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
--local timer1 = timer.performWithDelay(30, update, 0)
return scene