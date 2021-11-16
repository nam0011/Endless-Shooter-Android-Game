---------------------------------------------------------------------------------------------------
--  Group Project: CS371, Instructor: Dr Chung, Program: Navigate ship through aliens,
--	  Filename: scene1.lua, Purpose: Background, aliens, text, controls, & ship handles.
--	  Author:   Natalie Bush, nlb0017@uah.edu, Nathan Moore, Aaron Mendez. Created:  2021-11-08
---------------------------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 3 )
local composer = require( "composer" )
local json = require( "json" )
local scene = composer.newScene()

--globals
gameoverGroup = display.newGroup()

--locals
local delay = 90
local score = 0
local life = 1;

---------------------------------------------------------------------------------------------------
--game over label
local gamend =
{
	 text = "Game Over",
	 x = display.contentCenterX+10,
	 y = display.contentCenterY+80,
	 width = 250,
	 font = native.systemFont,
	 fontSize = 35,
	 align = "center"  -- Alignment parameter
}
gameoverGroup.text = display.newText(gamend)
gameoverGroup.text.isVisible = false

---------------------------------------------------------------------------------------------------
--JSON
local high = { score = 456 }

print( high.score )

local serializedString = json.encode( high )
print( serializedString )

--testing for midterm
local tester = {
	{ name="Clark Kent", nickname="Superman",
	address="Metropolis", age=32 },
	{ name="Bruce Wayne", nickname="Batman",
	address="Gotham", age=36 },
	{ name="Diana Prince", nickname="Wonder Woman",
	address="New York", age=28 }
}
local serializedTester = json.encode( tester )
print( serializedTester )

--write high score to json file on game over
 --system.DocumentsDirectory, In the Corona Simulator, this will be in a
 --sandboxed folder on a per-application basis.
 --You can view its directories/files via File → Show Project Sandbox
local path = system.pathForFile( "xglider.txt", system.DocumentsDirectory );
 -- Open the file handle
local file, errorString = io.open( path, "w+" )

if not file then
    -- Error occurred; output the cause
    print( "File error: " .. errorString )
else
    -- Output lines
    for line in file:lines() do
        print( line )
    end
		file:write( serializedString );
    -- Close the file handle
    io.close( file )
end
file = nil

---------------------------------------------------------------------------------------------------
-- PLayer Sprite Initialization
--define sprite frames
local playerFrames =
{
frames = {
		{ x = 23, y = 30, width = 182, height = 171}, --idle 1

		{ x = 800, y = 30, width = 179, height = 169}, --right turn begin 2
		{ x = 1060, y = 30, width = 165, height = 174}, --right turn end 3

		{ x = 14889, y = 30, width = 181, height = 171}, --left turn begin 4
		{ x = 14387, y = 30, width = 172, height = 171} --left turn end 5
  }
}

-- include sprite image sheet
local playerSheet = graphics.newImageSheet( "SF01a_strip60.png", playerFrames);

--set the frames for the animation of each of the 6 poses
local playerSequences = {
	{name = "idle", frames={1}, time = 500},
	{name = "right", frames={2,3}, time = 500},
	{name = "left", frames={4,5}, time = 500}
}


-- set sprite animation and initial state
local player = display.newSprite (playerSheet, playerSequences);
player.anchorX = display.contentCenterX;
player.anchorY = display.viewableContentHeight-60;
player.x = display.contentCenterX+25;
player.y = display.viewableContentHeight-35;
player.xScale = 0.15;
player.yScale = 0.15;
player:setSequence("idle");
physics.addBody( player, "kinematic", {bounce=0, radius=20} );
player.isSensor = true;
--play animation based on selected frames
player:toBack()
player:play();

---------------------------------------------------------------------------------------------------
-- Collision handler
local function onLocalCollision( self, event )
	if ( event.phase == "began" ) then
		print( ": collision began "  )
		--.. event.other.enemyname )
	elseif ( event.phase == "ended" ) then

		gameOver()
		--print( self.myname .. ": collision ended with "  )
		--.. event.other.enemyname )
	end
end
player.collision = onLocalCollision
player:addEventListener( "collision" )
--crate2.collision = onLocalCollision
--crate2:addEventListener( "collision" )

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
highLabel = display.newText(header)


---------------------------------------------------------------------------------------------------
-- Button Events
local moveLeft = function(event)
	local t = event.target
	local phase = event.phase

	if "began" == phase then
	player:setSequence("left");
		player.x = player.x - 1
	end
end

local moveRight = function(event)
	local t = event.target
	local phase = event.phase

	if "began" == phase then
		player:setSequence("right");
		player.x = player.x + 1
	end
end

local changeColor = function(event)
	local t = event.target
	local phase = event.phase

	if "began" == phase then

	end
end



---------------------------------------------------------------------------------------------------
-- Create Scene
--create initial scene
function scene:create( event )
   local sceneGroup = self.view

--creation of left button
local leftButton = display.newImage("leftButtonShape.png")
   leftButton.xScale = 0.75
   leftButton.yScale = 0.75
   leftButton.x = 0
   leftButton.y = 270
  --leftButton:setFillColor(1,0,0,.5)
	leftButton:toBack()
	leftButton.alpha = 0.7
	sceneGroup:insert(leftButton);
	leftButton:addEventListener( "touch", moveLeft )

--creation of right button
local rightButton = display.newImage("rightButtonShape.png")
   rightButton.xScale = 0.75
   rightButton.yScale = 0.75
   rightButton.x = 480
   rightButton.y = 270
   --rightButton:setFillColor(1,0,0,.5)
	rightButton:toBack()
	rightButton.alpha = 0.7
	sceneGroup:insert(rightButton);
	rightButton:addEventListener( "touch", moveRight )

	--creation of powerButton
	local powerButton = display.newImage("powerButton.png")
	   powerButton.xScale = 1
	   powerButton.yScale = 1
	   powerButton.x = 480
	   powerButton.y = 217
	   --powerButton:setFillColor(1,0,0,.5)
		 powerButton:toBack()
		 powerButton.alpha = 0.8
		 sceneGroup:insert(powerButton);
		 powerButton:addEventListener( "touch", changeColor )

--update fatalities with value
   scoreLabel.text = "Score: " .. score

--update high score with value
   highLabel.text = "High Score: " .. high.score

end  --end create scene

---------------------------------------------------------------------------------------------------
-- Game Over
function gameOver ()

	  if (bIsFirstPass == true) then
			gameoverGroup.text.isVisible = true
			bIsFirstPass = false
		end

	--set effects for scene transition
	 local options = {
	    effect = "slideDown",
	    time = 2000
	 }

		--call scene2 on game over
		timer.performWithDelay(400000, composer.gotoScene("scene2", options), 1)

 end
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
		--reset first pass every game
		bIsFirstPass = true
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
		--write high score to json file on game over
		 --local data = "My app state data";
		 --local path = system.pathForFile( "xglider.txt", system.DocumentsDirectory );
		 --local file = io.open( path, "w" );
		 --file:write( serializedString );
		 --io.close( file );
		 --file = nil

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
