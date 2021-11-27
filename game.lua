---------------------------------------------------------------------------------------------------
--  Group Project: CS371, Instructor: Dr Chung, Program: Navigate ship through aliens,
--	  Filename: scene1.lua, Purpose: Background, aliens, text, controls, & ship handles.
--	  Author:   Natalie Bush, nlb0017@uah.edu, Nathan Moore, Aaron Mendez. Created:  2021-11-08
---------------------------------------------------------------------------------------------------
local entity = require("entity")
--local pentagon = require("enemy")
--local triangle = require("triangle")
--local projectile = require("projectile")
local pentagon = require("pentagon")
local widget = require("widget")

local loadsave = require( "loadsave" ) --json loader
local physics = require( "physics" )


local composer = require( "composer" )
local json = require( "json" )

local scene = composer.newScene()
-- Activate multitouch
system.activate( "multitouch" )
--locals
physics.start()
physics.setDrawMode("normal")
local delay = 10
local score = -1
local life = 1;
local runtime = 0
local scrollSpeed = 1.4
local triChance = 0.0035   --spawn enemy
local lastPent = 0         --spawn enemy
local pentChance = 0.0035  --spawn enemy
local enemies = {}         --spawn enemy
local GObool = false

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--set background image
local background = display.newImageRect( "background.png",
               (display.viewableContentWidth*1.2), display.viewableContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY
background:toBack()

--left and right boundary
local left = display.newRect(0, 0, 1, display.contentHeight)
left.anchorX = 0; left.anchorY = 0
left.isVisible = false
local right = display.newRect(display.contentWidth, 0, 1, display.contentHeight)
right.anchorX = 0; right.anchorY = 0
right.isVisible = false
physics.addBody(left, 'static', { isSensor=true } )
physics.addBody(right, 'static', { isSensor=true } )

--level 1 scrollable background
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

--move background
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
ship = display.newSprite (playerSheet, playerSequences);
ship.anchorX = display.contentCenterX;
ship.anchorY = display.viewableContentHeight-60;
ship.x = display.contentCenterX+25
ship.y = display.viewableContentHeight-35;
ship.xScale = 0.15;
ship.yScale = 0.15;
ship:setSequence("idle");
ship.isSensor = true;
ship.name = "ship"
physics.addBody( ship, "kinematic" )
--play animation based on selected frames
ship:play();
local hitBoxS= display.newCircle( ship.x-10, ship.y-10, 20 )
hitBoxS.alpha = 0
hitBoxS.name = "ship"
physics.setGravity( 0, 0 )
physics.addBody(hitBoxS, "kinematic")

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

		table.insert(enemies, mEnemy)
		mEnemy:play( )
		local hitBoxM= display.newCircle( mEnemy.x, mEnemy.y, 20 )
		hitBoxM.alpha = 0
		physics.addBody(hitBoxM, "dynamic")
		mEnemy.name = "first"
		transition.to( hitBoxM, {x=mEnemy.x,y=display.contentHeight,time=2000, onComplete = listener})

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


		lastPent = system.getTimer()
		sEnemy:play( )
		local hitBoxSE= display.newCircle( sEnemy.x, sEnemy.y, 20 )
		hitBoxSE.alpha = 0
		physics.addBody(hitBoxSE, "dynamic")
		hitBoxSE.name = "second"
		transition.to( hitBoxSE, {x=ship.x,y=ship.y+20,time=2000, onComplete = listener})
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
    if GObool == false then
    if math.random() < rp or t - lastPent > 500 then mainEnemy() end
	end
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
ship.collision = onLocalCollision
ship:addEventListener( "collision" )


---------------------------------------------------------------------------------------------------
-- Create Scene
--create initial scene
function scene:create( event )
   local sceneGroup = self.view

	 physics.start()
	 physics.setGravity( 0, 3 )

	 addScrollableBg()

  --create button group
  local buttonGroup = display.newGroup()

  local leftButton = display.newImageRect( buttonGroup, "leftButtonShape.png", 50, 50 )
  leftButton.x, leftButton.y = 0, 270
  leftButton.canSlideOn = true
  leftButton.ID = "left"
  leftButton:toBack()
  leftButton.alpha = 0.7
  --sceneGroup:insert(leftButton);
  buttonGroup:insert(leftButton);

  local rightButton = display.newImageRect( buttonGroup, "rightButtonShape.png", 50, 50 )
  rightButton.x, rightButton.y = 480, 270
  rightButton.canSlideOn = true
  rightButton.ID = "right"
  rightButton:toBack()
  rightButton.alpha = 0.7
  buttonGroup:insert(rightButton);

  sceneGroup:insert(buttonGroup);

  local function detectButton( event )

      for i = 1,buttonGroup.numChildren do
          local bounds = buttonGroup[i].contentBounds
          if (
              event.x > bounds.xMin and
              event.x < bounds.xMax and
              event.y > bounds.yMin and
              event.y < bounds.yMax
          ) then
              return buttonGroup[i]
          end
      end
  end

  local function handleController( event )

      local touchOverButton = detectButton( event )

      if ( event.phase == "began" ) then

          if ( touchOverButton ~= nil ) then
              if not ( buttonGroup.touchID ) then
                  -- Set/isolate this touch ID
                  buttonGroup.touchID = event.id
                  -- Set the active button
                  buttonGroup.activeButton = touchOverButton
                  -- Take proper action based on button ID
                  if ( buttonGroup.activeButton.ID == "left" ) then
                    if (ship.x > 0 ) then
                      ship:setLinearVelocity( -100, 0 )
                    elseif (ship.x < 1 ) then
                      ship:setLinearVelocity( 0, 0 )
                      ship:setSequence("idle");
                    end

                  elseif ( buttonGroup.activeButton.ID == "right" ) then
                    if (ship.x < display.viewableContentWidth ) then
                      ship:setLinearVelocity( 100, 0 )
                    elseif (ship.x > display.viewableContentWidth-1 ) then
                      ship:setLinearVelocity( 0, 0 )
                      ship:setSequence("idle");
                    end
                  end
              end
              return true
          end

      elseif ( event.phase == "moved" ) then
        --stay within the screen
        if ( ( buttonGroup.activeButton.ID == "right" ) and (ship.x > display.viewableContentWidth-1 ) ) then
          ship:setLinearVelocity( 0, 0 )
          ship:setSequence("idle");
        elseif( ( buttonGroup.activeButton.ID == "left" ) and (ship.x < 1 ) ) then
          ship:setLinearVelocity( 0, 0 )
          ship:setSequence("idle");
        end
      elseif ( event.phase == "ended" and buttonGroup.activeButton ~= nil ) then

          -- Release this touch ID
          buttonGroup.touchID = nil
          -- Set that no button is active
          buttonGroup.activeButton = nil
          -- Stop the action
          ship:setLinearVelocity( 0, 0 )
          ship:setSequence("idle");
          return true
      end
  end
  rightButton:addEventListener( "touch", handleController )
  leftButton:addEventListener( "touch", handleController )

	 local changeColor = function(event)
	 	local t = event.target
	 	local phase = event.phase

	 	if "began" == phase then

	 	end
	 end



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
		GObool = true
    --stop ship if mid-flight
    ship:setLinearVelocity( 0, 0 )
    ship:setSequence("idle");


	  if (bIsFirstPass == true) then
			gameoverGroup.text.isVisible = true
			bIsFirstPass = false

			--table
    	if (score > loadedSettings.highScore) then
				loadedSettings.highScore = score;
			end
      audio.play(sfx.death, { channel=2 } );
      audio.setMaxVolume( 0.65, { channel=2 } )
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
	GObool = false
   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
		 physics.start()
     -- Play the background music on channel 1, loop infinitely, and fade in
     local bgMusicChannel = audio.play( sfx.bg, { channel=1, loops=-1, fadein=1000 } )
		 score = 0

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
     --reset ship position
   	--cancel timer before moving to next scene
   	timer.cancel(timer1)
    audio.fadeOut( { channel=1, time=4000 } )

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
   --composer.removeScene( self.view )
end

--listen for these events
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

--local timer1 = timer.performWithDelay(30, scoreUp, 0)


--Runtime:addEventListener("enterFrame", enterFrame)
local function onGlobalCollision( event )
    if event.phase == "began" then
    	if event.object1.name == "ship" then
    		gameOver()
    	elseif event.object2.name == "ship" then
    		gameOver()
    	end
    end
end
Runtime:addEventListener( "collision", onGlobalCollision )
return scene
