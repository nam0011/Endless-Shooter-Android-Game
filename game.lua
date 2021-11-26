---------------------------------------------------------------------------------------------------
--  Group Project: CS371, Instructor: Dr Chung, Program: Navigate ship through aliens,
--	  Filename: scene1.lua, Purpose: Background, aliens, text, controls, & ship handles.
--	  Author:   Natalie Bush, nlb0017@uah.edu, Nathan Moore, Aaron Mendez. Created:  2021-11-08
---------------------------------------------------------------------------------------------------
local entity = require("entity")
--local pentagon = require("enemy")
--local triangle = require("triangle")
--local projectile = require("projectile")
local widget = require("widget")

local loadsave = require( "loadsave" ) --json loader
local physics = require( "physics" )


local composer = require( "composer" )
local json = require( "json" )

local scene = composer.newScene()

--locals
local delay = 10
local score = -1
local life = 1;
local runtime = 0
local scrollSpeed = 1.4
local triChance = 0.0035   --spawn enemy
local lastPent = 0         --spawn enemy
local pentChance = 0.0035  --spawn enemy
local enemies = {}         --spawn enemy

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--set background image
local background = display.newImageRect( "background.png",
               (display.viewableContentWidth*1.2), display.viewableContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY
background:toBack()

local function addScrollableBg()
    local bgImage = { type="image", filename="background.png" }

    -- Add First bg image
    bg1 = display.newRect(scene.view, 0, 0, (display.actualContentWidth), display.actualContentHeight)
    bg1.fill = bgImage
    bg1.x = display.contentCenterX
    bg1.y = display.contentCenterY

    -- Add Second bg image
    bg2 = display.newRect(scene.view, 0, 0, (display.actualContentWidth), display.actualContentHeight)
    bg2.fill = bgImage
    bg2.x = display.contentCenterX
    bg2.y = display.contentCenterY - display.actualContentHeight
end

local function moveBg(dt)
    bg1.y = bg1.y + scrollSpeed * dt
    bg2.y = bg2.y + scrollSpeed * dt

    if (bg1.y - display.contentHeight/2) > display.actualContentHeight then
        bg1:translate(0, -bg1.contentHeight * 2)
    end
    if (bg2.y - display.contentHeight/2) > display.actualContentHeight then
        bg2:translate(0, -bg2.contentHeight * 2)
    end
end

local function getDeltaTime()
    local temp = system.getTimer()
    local dt = (temp - runtime) / (1000 / 60)
    runtime = temp
    return dt
end

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
local ship = display.newSprite (playerSheet, playerSequences);
ship.anchorX = display.contentCenterX;
ship.anchorY = display.viewableContentHeight-60;
ship.x = display.contentCenterX+25;
ship.y = display.viewableContentHeight-35;
ship.xScale = 0.15;
ship.yScale = 0.15;
--physics.start()
--physics.addBody(ship, "static")
ship.name = "ship"
ship:setSequence("idle");
ship.isSensor = true;
--play animation based on selected frames
ship:play();

---------------------------------------------------------------------------------------------------
--spawn enemies
local function listener(obj)
	display.remove(obj)
	table.remove( enemies,mEnemy )
	table.remove(enemies,sEnemy)
end

local function mainEnemy()
	local chance = math.random(6)
	if chance <= 3 then
		local opt = {
   			width = 256,
    		height = 256,
    		numFrames = 76
		}

		local sheet = graphics.newImageSheet("enemy1.png", opt)

		local enemy = {
    	-- consecutive frames sequence
    		{
      		name = "normalRun",
       		start = 1,
        	count = 76,
        	time = 800,
        	loopCount = 76,
        	loopDirection = "forward"
    		}
		}

		local mEnemy = display.newSprite(sheet, enemy )
		mEnemy:scale( 0.15, 0.15 )
		mEnemy.x = math.random( 0, 800 )
		mEnemy.y = 0
		mEnemy.onDeath = scoreUp
		lastPent = system.getTimer()
		--physics.addBody(mEnemy,"dynamic")
		mEnemy.name = "first"
		table.insert(enemies, mEnemy)
		mEnemy:play( )
		transition.to( mEnemy, {x=mEnemy.x,y=display.contentHeight,time=2000, onComplete = listener})

	
	else
		local opt = {
   			width = 256,
    		height = 256,
    		numFrames = 76
		}

		local sheet = graphics.newImageSheet("enemy2.png", opt)

		local enemy = {
    	-- consecutive frames sequence
    		{
        		name = "normalrun",
        		start = 1,
        		count = 76,
        		time = 800,
        		loopCount = 76,
        		loopDirection = "forward"
    		}
		}

		local sEnemy = display.newSprite(sheet, enemy )
		sEnemy:scale( 0.15, 0.15 )
		sEnemy.x = math.random( 0, 800 )
		sEnemy.y = 0
		sEnemy.onDeath = scoreUp
		sEnemy.isSensor = true
		sEnemy.name = "second"

		lastPent = system.getTimer()
		--physics.addBody( sEnemy, "dynamic")
		sEnemy:play( )
		transition.to( sEnemy, {x=ship.x,y=ship.y+20,time=2000, onComplete = listener})


	end

end



--[[local function spawnPentagon()
    --local pent = pentagon:new({ x = math.random(25, display.contentWidth - 25), y = 0 }, { destY = scene.player.y })
		local pent = pentagon:new({ x = math.random(25, display.contentWidth - 25), y = 0 }, { destY = display.actualContentHeight + 5 })
    pent:spawn(scene.view)
    pent:move()

    pent.shape.isFixedRotation = true
    pent.onDeath = scoreUp
    lastPent = system.getTimer()

    table.insert(enemies, pent.shape)
end]]--

---------------------------------------------------------------------------------------------------
--start frames
local function enterFrame()
    local dt = getDeltaTime()
    local t = system.getTimer()


    --scene.hpText.text = "HP: " .. scene.player.hp

    if pause then return end

    moveBg(dt)

    local rt = triChance * dt
    local rp = pentChance * dt

    --if math.random() < rt or t - lastTri > 2000 then spawnTriangle() end
    if math.random() < rp or t - lastPent > 500 then mainEnemy() end
end


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
--JSON
local loadedSettings = loadsave.loadTable( "settings.json" )
if (loadedSettings == nil ) then
	loadedSettings = {
	    musicOn = true,
	    soundOn = true,
	    difficulty = "easy",
	    highScore = 10000,
	    highestLevel = 7
	}
end

print( loadedSettings.highScore )

---------------------------------------------------------------------------------------------------
--scoreUp - increases score as play
local function scoreUp ()
    score = score + 1
    --scene.scoreText.text = "Score: " .. score
		--update fatalities with value
		scoreLabel.text = "Score: " .. score
    --audio.play(sfx.point)
end


---------------------------------------------------------------------------------------------------
-- Collision handler
--[[local function onLocalCollision( self, event )
	if ( event.phase == "began" ) then
		print( ": collision began "  )
		--.. event.other.enemyname )
	elseif ( event.phase == "ended" ) then

		gameOver()
		--print( self.myname .. ": collision ended with "  )
		--.. event.other.enemyname )
	end
end
ship.collision = onLocalCollision
ship:addEventListener( "collision" )]]--

---------------------------------------------------------------------------------------------------
-- Create Scene
--create initial scene
function scene:create( event )
   local sceneGroup = self.view

	 physics.start()
	 physics.setGravity( 0, 3 )

	 addScrollableBg()


  --note: use to spawn circle spawn mock (circle) player for testing
	 self.player = entity:new({ x = display.contentCenterX+25, y = display.viewableContentHeight-35, damagers = { projectile = true, enemy = true }, tag = "player", hp = 1 })
	 self.player:spawn(sceneGroup)
	 self.player.shape.markX = self.player.x
	 self.player.onDeath = function () audio.play(sfx.death); gameOver() end

	 -- Button Events
	 local moveLeft = function(event)
	 	local t = event.target
	 	local phase = event.phase

	 	if "began" == phase then
	 	ship:setSequence("left");
	 		ship.x = ship.x - 1
	 	end
	 end

	 local moveRight = function(event)
	 	local t = event.target
	 	local phase = event.phase

	 	if "began" == phase then
	 		ship:setSequence("right");
	 		ship.x = ship.x + 1
	 	end
	 end

	 local changeColor = function(event)
	 	local t = event.target
	 	local phase = event.phase

	 	if "began" == phase then

	 	end
	 end
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
			local powerButton = display.newImage("powerButtonRing.png")
			   powerButton.xScale = 1
			   powerButton.yScale = 1
			   powerButton.x = 480
			   powerButton.y = 217
			   --powerButton:setFillColor(1,0,0,.5)
				 powerButton:toBack()
				 powerButton.alpha = 0.7
				 sceneGroup:insert(powerButton);
				 powerButton:addEventListener( "touch", changeColor )


  --initialize score value
  	scoreLabel.text = "Score: " .. score

--update high score with value
  --use for loop in case of multiple records
	--[[for k,v in pairs(loadedSettings) do
	    --print( k,v )
			if (k == "highScore") then
      	highLabel.text = "High Score: " .. v
			end
	end--]]
		highLabel.text = "High Score: " .. loadedSettings.highScore


end  --end create scene

---------------------------------------------------------------------------------------------------
-- Game Over
function gameOver ()

	  if (bIsFirstPass == true) then
			gameoverGroup.text.isVisible = true
			bIsFirstPass = false

			--table
    	if (score > loadedSettings.highScore) then
				loadedSettings.highScore = score;
			end
			highLabel.text = "High Score: " .. loadedSettings.highScore
			--save to json table
			loadsave.saveTable( loadedSettings, "settings.json" )
		end

	--set effects for scene transition
	 local options = {
		 effect = "fade",
     --time = 500
	    time = 2000
	 }

		--call menu on game over
		timer.performWithDelay(400000, composer.gotoScene("menu", options), 1)

 end
---------------------------------------------------------------------------------------------------
-- raindrops
--[[local function rain (event)
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

end]]


---------------------------------------------------------------------------------------------------
-- Updating whatever, may not need
--update if needed
function update()

end

---------------------------------------------------------------------------------------------------
-- Events

--local timer1 = timer.performWithDelay(delay, rain, 0)
local timer1 = timer.performWithDelay(delay,scoreUp,1)
--show scene
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
		 physics.start()

		 score = 0

     --note: use for testing with circle
		 self.player.hp = 1
		 if not self.player.shape then
			 self.player:spawn(sceneGroup)
		 end

		--reset first pass every game
		bIsFirstPass = true
   elseif ( phase == "did" ) then
   	--start timer when scene is shown
   	--timer1 = timer.performWithDelay(delay,rain,0)

    --note: use for spawning pentagons and circle
    local spawnEnemy = Runtime:addEventListener("enterFrame", enterFrame)
		timer1 = timer.performWithDelay(delay,scoreUp,0)
   end
end

--hide scene
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
   	--cancel timer before moving to next scene
   	timer.cancel(timer1)

		--write high score to json file on game over
		 --local data = "My app state data";
		 --local path = system.pathForFile( "xglider.txt", system.DocumentsDirectory );
		 --local file = io.open( path, "w" );
		 --file:write( serializedString );
		 --io.close( file );
		 --file = nil


   elseif ( phase == "did" ) then
     --physics.stop()
     transition.cancelAll()
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

local function onGlobalCollision( event )
 
    if ( event.phase == "began" ) then
    	if event.object1.name == "ship" then
    		gameOver()
        print( event.object1.name )
        print(event.object2.name)
    elseif event.object2.name =="ship"then
    	gameOver()
    	print(event.object2.name)
    	print(event.object1.name)
    end
    end
end
 
Runtime:addEventListener( "collision", onGlobalCollision )
--local timer1 = timer.performWithDelay(30, update, 0)
--local timer1 = timer.performWithDelay(30, scoreUp, 0)


--Runtime:addEventListener("enterFrame", enterFrame)

return scene
