---------------------------------------------------------------------------------------------------
--  Group Project: CS371, Instructor: Dr Chung, Program: Navigate ship through aliens,
--	  Filename: scene1.lua, Purpose: Background, aliens, text, controls, & ship handles.
--	  Author:   Natalie Bush, nlb0017@uah.edu, Nathan Moore, Aaron Mendez. Created:  2021-11-08
---------------------------------------------------------------------------------------------------
local entity = require("entity")
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
physics.setContinuous( enabled )
physics.setDrawMode("normal")
local delay = 10
local score = -1
local life = 1;
local runtime = 0
local scrollSpeed = 1.4
local triChance = 0.0035   --spawn enemy
local lastEnemy = 0         --spawn enemy
local pentChance = 0.0035  --spawn enemy
local enemies = {}         --spawn enemy
local GObool = false
local powerButton

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--set background image
local background = display.newImageRect( "background.png",
               (display.viewableContentWidth*1.2), display.viewableContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY
background:toBack()

--left and right boundary
local left = display.newRect(-40, 0, 1, display.contentHeight)
left.anchorX = 0; left.anchorY = 0
left.isVisible = false
local right = display.newRect(display.viewableContentWidth+40, 0, 1, display.contentHeight)
right.anchorX = 0; right.anchorY = 0
right.isVisible = false
physics.addBody(left, "static", { isSensor=true } )
physics.addBody(right, "static", { isSensor=true } )

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
ship.isSensor = true
ship:setSequence("idle");
local offsetShipSize = {halfWidth = 10, halfHeight = 10}
physics.addBody( ship, "kinematic", {box = offsetShipSize} )
--play animation based on selected frames
ship:play();
hitBoxS= display.newCircle( display.contentCenterX+15, display.viewableContentHeight-50, 12 )
hitBoxS.alpha = 0
hitBoxS.name = "ship"
hitBoxS.isSensor = true
physics.setGravity( 0, 0 )
physics.addBody(hitBoxS, "kinematic")

---------------------------------------------------------------------------------------------------
--spawn enemies
local function removeEnemy(obj)
	display.remove(obj)
end

local function mainEnemy()
  local chance = math.random(9)
  if (chance > 4) then
    local mFrames =
    {
    frames = {
          { x = 8, y = 0, width = 41, height = 58},
          { x = 66, y = 1, width = 41, height = 57},
          { x = 123, y = 0, width = 41, height = 58},
          { x = 183, y = 0, width = 38, height = 58},
          { x = 242, y = 0, width = 36, height = 58},
          { x = 300, y = 0, width = 36, height = 58},
          { x = 359, y = 0, width = 36, height = 58},
          { x = 418, y = 0, width = 35, height = 58},
          { x = 477, y = 1, width = 34, height = 57},
          { x = 534, y = 0, width = 36, height = 58},
          { x = 594, y = 1, width = 35, height = 57},
          { x = 654, y = 0, width = 31, height = 58},
          { x = 709, y = 0, width = 35, height = 58},
          { x = 767, y = 1, width = 37, height = 57},
            { x = 825, y = 0, width = 37, height = 58},
            { x = 881, y = 0, width = 39, height = 58},
            { x = 940, y = 0, width = 37, height = 58},
            { x = 997, y = 0, width = 39, height = 58},
            { x = 1056, y = 0, width = 38, height = 58}
          --  { x = 1116, y = 1, width = 35, height = 57}
            --{ x = 1173, y = 1, width = 36, height = 57},
            --{ x = 1231, y = 0, width = 35, height = 58}
        }
      }

      local mSheet = graphics.newImageSheet("enemyDrone00.png", mFrames)
      local mSequences = {
      	{name = "idle", frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19}, time = 1000}
      }

  		local mEnemy = display.newSprite(mSheet, mSequences )
  		mEnemy.x = math.random( display.contentWidth )
  		mEnemy.y = 0
      mEnemy:scale( 0.55, 0.55 )
      mEnemy:toFront()
      mEnemy:setSequence("idle");
      mEnemy:play()

      mEnemy.onDeath = scoreUp
  		lastEnemy = system.getTimer()
  		table.insert(enemies, mEnemy)

  		local hitBoxM= display.newCircle( mEnemy.x, mEnemy.y, 15 )
  		hitBoxM.alpha = 0
  		physics.addBody(hitBoxM, "dynamic")
  		hitBoxM.name = "enemy"
  		transition.to( hitBoxM, {x=mEnemy.x,y=display.viewableContentHeight,time=2000, onComplete = removeEnemy})
  		transition.to( mEnemy, {x=mEnemy.x,y=display.viewableContentHeight,time=2000, onComplete = removeEnemy})

  	elseif (chance < 2) then
      --powerup
      -- set sprite animation and initial state
      local pup = display.newImage("powerUp.png")
         pup.xScale = 0.55
         pup.yScale = 0.55
         pup.x = math.random( display.contentWidth )
         pup.y = 0
         pup.alpha = 0.7

      pup.isSensor = true
      --physics.addBody( pup, "dynamic" )

  		lastEnemy = system.getTimer()
  		table.insert(enemies, pup)

  		local hitBoxP= display.newCircle( pup.x, pup.y, 15 )
  		hitBoxP.alpha = 0
  		physics.addBody(hitBoxP, "dynamic")
  		hitBoxP.name = "pup"
  		transition.to( hitBoxP, {x=pup.x,y=display.viewableContentHeight,time=3000, onComplete = removeEnemy})
  		transition.to( pup, {x=pup.x,y=display.viewableContentHeight,time=3000, onComplete = removeEnemy})

    else
      local sFrames =
      {
      frames = {
            { x = 14, y = 0, width = 35, height = 64},
            { x = 78, y = 0, width = 37, height = 64},
            { x = 145, y = 0, width = 32, height = 64},
            { x = 210, y = 0, width = 30, height = 64},
            { x = 273, y = 0, width = 31, height = 64},
            { x = 336, y = 0, width = 30, height = 64},
            { x = 401, y = 0, width = 29, height = 64},
            { x = 465, y = 0, width = 32, height = 64},
            { x = 531, y = 0, width = 29, height = 64},
            { x = 597, y = 0, width = 27, height = 64},
            { x = 661, y = 0, width = 25, height = 64},
            { x = 726, y = 0, width = 27, height = 64},
            { x = 792, y = 0, width = 24, height = 64},
            { x = 854, y = 0, width = 27, height = 64},
            { x = 919, y = 0, width = 26, height = 64},
            { x = 983, y = 0, width = 26, height = 64},
            { x = 1047, y = 0, width = 26, height = 64},
            { x = 1110, y = 0, width = 29, height = 64},
            { x = 1174, y = 0, width = 29, height = 64}
        }
      }

      local sSheet = graphics.newImageSheet("enemyTall00.png",sFrames)
      local sSequences = {
      	{name = "idle", frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19}, time = 900}
      }

  		local sEnemy = display.newSprite(sSheet, sSequences )
  		sEnemy.x = math.random( display.contentWidth )
  		sEnemy.y = 0
      sEnemy:scale( 0.80, 0.65 )
      sEnemy:toFront()
      sEnemy:setSequence("idle");
      sEnemy:play()

      sEnemy.onDeath = scoreUp
  		lastEnemy = system.getTimer()
  		table.insert(enemies, sEnemy)

  		local hitBoxSE= display.newCircle( sEnemy.x, sEnemy.y, 15 )
  		hitBoxSE.alpha = 0
  		physics.addBody(hitBoxSE, "dynamic")
  		hitBoxSE.name = "enemy"
  		transition.to( hitBoxSE, {x=ship.x,y=ship.y+20,time=4000, onComplete = removeEnemy})
  		transition.to( sEnemy, {x=ship.x,y=ship.y+20,time=4000, onComplete = removeEnemy})

  	  end

      --add boss enemy
      if(score > 1000 and math.random(1000) > 800) then

        local bossFrames =
        {
        frames = {
              { x = 22, y = 39, width = 207, height = 185},
              { x = 22, y = 39, width = 207, height = 185}
          }
        }

        local bossSheet = graphics.newImageSheet("boss.png",bossFrames)
        local bossSequences = {
          {name = "idle", frames={1,2}, time = 1}
        }

        local bossEnemy = display.newSprite(bossSheet, bossSequences )
        bossEnemy.x = math.random( display.contentWidth )
        bossEnemy.y = 20
        bossEnemy:scale( 0.35, 0.4 )
        bossEnemy:toFront()
        bossEnemy:setSequence("idle");
        bossEnemy:play()

        bossEnemy.onDeath = scoreUp
        lastEnemy = system.getTimer()
        table.insert(enemies, bossEnemy)

        local hitBoxBoss= display.newCircle( bossEnemy.x, bossEnemy.y, 35 )
        hitBoxBoss.alpha = 0
        physics.addBody(hitBoxBoss, "dynamic")
        hitBoxBoss.name = "enemy"
        transition.to( bossEnemy, {x=ship.x,y=ship.y+20,time=3000, onComplete = removeEnemy})
        transition.to( hitBoxBoss, {x=ship.x,y=ship.y+20,time=3000, onComplete = removeEnemy})
      end

end

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

    if(score < 500) then
      if math.random() < rp or t - lastEnemy > 1000 then
        mainEnemy()
      end
    elseif (score > 500 and score < 1000) then
      if math.random() < rp or t - lastEnemy > 750 then
        mainEnemy()
      end
    elseif (score > 1000 and score < 1500) then
      if math.random() < rp or t - lastEnemy > 500 then
        mainEnemy()
      end
    end

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
	    highScore = 0,
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
                      ship:setLinearVelocity( -100, 0 )
                      hitBoxS:setLinearVelocity( -100, 0 )
                      if((ship.x - ship.width * 0.001) < 0) then
                        ship.x = ship.width * 0.001
                      elseif((ship.x + ship.width * 0.001) > display.contentWidth) then
                        ship.x = display.contentWidth - ship.width * 0.001
                      end
                      if((hitBoxS.x - hitBoxS.width * 0.001) < 0) then
                        hitBoxS.x = hitBoxS.width * 0.001
                      elseif((hitBoxS.x + hitBoxS.width * 0.001) > display.contentWidth) then
                        hitBoxS.x = display.contentWidth - hitBoxS.width * 0.001
                      end
                  elseif ( buttonGroup.activeButton.ID == "right" ) then
                      ship:setLinearVelocity( 100, 0 )
                      hitBoxS:setLinearVelocity( 100, 0 )
                      if((ship.x - ship.width * 0.001) < 0) then
                        ship.x = ship.width * 0.001
                      elseif((ship.x + ship.width * 0.001) > display.contentWidth) then
                        ship.x = display.contentWidth - ship.width * 0.001
                      end
                      if((hitBoxS.x - hitBoxS.width * 0.001) < 0) then
                        hitBoxS.x = hitBoxS.width * 0.001
                      elseif((hitBoxS.x + hitBoxS.width * 0.001) > display.contentWidth) then
                        hitBoxS.x = display.contentWidth - hitBoxS.width * 0.001
                      end
                  end
              end
              return true
          end



      elseif ( event.phase == "moved" ) then

      elseif ( event.phase == "ended" and buttonGroup.activeButton ~= nil ) then

          -- Release this touch ID
          buttonGroup.touchID = nil
          -- Set that no button is active
          buttonGroup.activeButton = nil
          -- Stop the action
          ship:setLinearVelocity( 0, 0 )
          hitBoxS:setLinearVelocity( 0, 0 )
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
			powerButton = display.newImage("powerButtonRing.png")
			   powerButton.xScale = 1
			   powerButton.yScale = 1
			   powerButton.x = 480
			   powerButton.y = 217
			   --powerButton:setFillColor(1,0,0,.5)
				 powerButton:toBack()
				 powerButton.alpha = 0.7
				 sceneGroup:insert(powerButton);
				 --powerButton:addEventListener( "touch", changeColor )


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
    hitBoxS:setLinearVelocity( 0, 0 )
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
	    time = 1000
	 }

		--call menu on game over
		timer.performWithDelay(1000, composer.gotoScene("menu", options), 1)

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
     bgMusicChannel = audio.play( sfx.bg, { channel=1, loops=-1, fadein=1000 } )
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

    physics.pause()

    for i, v in ipairs(enemies) do
      if v.removeSelf then
        v:removeSelf()
      end
    end

    enemies = {}
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
local function addHB( event )
	--print(hitBoxS.name)
	hitBoxS.name = "ship"
  hitBoxS.alpha = 0
	--print(hitBoxS.name)
end
local function removeHB( event )
	hitBoxS.name = "invinc"
  hitBoxS.alpha = 0.5
	timer.performWithDelay( 5000, addHB,1)
end

--Runtime:addEventListener("enterFrame", enterFrame)
local function onGlobalCollision( event )
    if event.phase == "began" then
    	if event.object1.name == "ship" then
        if event.object2.name == "enemy" then
    		  gameOver()
    	  elseif event.object2.name == "pup" then
      		powerButton.alpha = 1
      		powerButton:addEventListener( "touch", removeHB )
    	  end
      end
    end
end
Runtime:addEventListener( "collision", onGlobalCollision )

return scene
