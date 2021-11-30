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
local life = 1;
local runtime = 0
local scrollSpeed = 1.4
local triChance = 0.0035   --spawn enemy
local lastEnemy = 0         --spawn enemy
local enemyChance = 0.0035  --spawn enemy
local enemies = {}         --spawn enemy
local powerButton
--global
score = -1
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--set background image
local background = display.newImageRect( "background.png",
               (display.viewableContentWidth*1.2), display.viewableContentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY
background:toBack()
background.alpha=1


--left and right boundary
local left= display.newRect( -47,display.viewableContentHeight-50, 10, 10 )
left.anchorX = -40; left.anchorY = display.viewableContentHeight-50
left.alpha = 0
physics.addBody(left, "dynamic", { friction=1000.0, mass=1000})
left.name = "wall"
-- Local collision handling
local function onLocalPreCollision( self, event )
  local vx, vy = ship:getLinearVelocity()
  if vx < 0 then
    ship:setLinearVelocity( 0, 0 )
    hitBoxS:setLinearVelocity( 0, 0 )
    ship:setSequence("idle");
  end
end
left.preCollision = onLocalPreCollision
left:addEventListener( "preCollision" )

local right= display.newRect( display.contentWidth+55,display.viewableContentHeight-50, 10, 10 )
right.anchorX = display.contentWidth+40; right.anchorY = display.viewableContentHeight-50
right.alpha = 0
physics.addBody(right, "dynamic", { friction=1000.0, mass=1000})
right.name = "wall"
-- Local collision handling
local function onLocalPreCollision( self, event )
  local vx, vy = ship:getLinearVelocity()
  if vx > 0 then
    ship:setLinearVelocity( 0, 0 )
    hitBoxS:setLinearVelocity( 0, 0 )
    ship:setSequence("idle");
  end
end
right.preCollision = onLocalPreCollision
right:addEventListener( "preCollision" )

--level 1 scrollable background
local function addScrollableBg()
    local bgImage = { type="image", filename="background.png" }

    -- Add First bg image
    bg1 = display.newRect(scene.view, 0, 0, (display.actualContentWidth), display.actualContentHeight)
    bg1.fill = bgImage
    bg1.x = display.contentCenterX
    bg1.y = display.contentCenterY
    bg1.alpha = 0.7

    -- Add Second bg image
    bg2 = display.newRect(scene.view, 0, 0, (display.actualContentWidth), display.actualContentHeight)
    bg2.fill = bgImage
    bg2.x = display.contentCenterX
    bg2.y = display.contentCenterY - display.actualContentHeight
    bg2.alpha = 0.7
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
		{ x = 19, y = 17, width = 208, height = 196}, --idle 1

		{ x = 278, y = 22, width = 202, height = 184}, --right turn begin 2
		{ x = 537, y = 27, width = 197, height = 179}, --right turn end 3

		{ x = 1308, y = 22, width = 197, height = 184}, --left turn begin 4
		{ x = 1058, y = 21, width = 188, height = 186} --left turn end 5
  }
}

-- include sprite image sheet
local playerSheet = graphics.newImageSheet( "ship.png", playerFrames);

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
physics.addBody( ship, "dynamic", {box = offsetShipSize, bounce = 0} )
--play animation based on selected frames
ship:play();
hitBoxS= display.newCircle( display.contentCenterX+25, display.viewableContentHeight-50, 12 )
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

  		local hitBoxM= display.newCircle( mEnemy.x, mEnemy.y, 10 )
  		hitBoxM.alpha = 0
  		physics.addBody(hitBoxM, "dynamic")
  		hitBoxM.name = "enemy"
  		transition.to( hitBoxM, {x=mEnemy.x,y=display.viewableContentHeight,time=2500, onComplete = removeEnemy})
  		transition.to( mEnemy, {x=mEnemy.x,y=display.viewableContentHeight,time=2500, onComplete = removeEnemy})
  		table.insert(enemies, hitBoxM)
  	elseif (chance < 2) then
      --powerup collectible
      -- set sprite animation and initial state
      local pup = display.newImage("powerUp.png")
         pup.xScale = 0.55
         pup.yScale = 0.55
         pup.x = math.random( display.contentWidth )
         pup.y = 0
         pup.alpha = 1.0

      pup.isSensor = true

  		lastEnemy = system.getTimer()
  		table.insert(enemies, pup)

  		local hitBoxP= display.newCircle( pup.x, pup.y, 15 )
  		hitBoxP.alpha = 0
  		physics.addBody(hitBoxP, "dynamic")
  		hitBoxP.name = "pup"
  		transition.to( hitBoxP, {x=pup.x,y=display.viewableContentHeight,time=3000, onComplete = removeEnemy})
  		transition.to( pup, {x=pup.x,y=display.viewableContentHeight,time=3000, onComplete = removeEnemy})
  		table.insert(enemies, hitBoxP)
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

  		local hitBoxSE= display.newCircle( sEnemy.x, sEnemy.y, 10 )
  		hitBoxSE.alpha = 0
  		physics.addBody(hitBoxSE, "dynamic")
  		hitBoxSE.name = "enemy"
  		transition.to( hitBoxSE, {x=ship.x,y=ship.y+20,time=4000, onComplete = removeEnemy})
  		transition.to( sEnemy, {x=ship.x,y=ship.y+20,time=4000, onComplete = removeEnemy})
  		table.insert(enemies, hitBoxSE)
    end

end

---------------------------------------------------------------------------------------------------
--start frames
local function enterFrame()
    local dt = getDeltaTime()
    local t = system.getTimer()

    if pause then return end

    moveBg(dt)

    local rp = enemyChance * dt
    if (score < 500) then
      if math.random() < rp or t - lastEnemy > 1000 then mainEnemy() end
    else
      if math.random() < rp or t - lastEnemy > 700 then mainEnemy() end
    end
    if score > 1000 then
      levelUp()
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
--global
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
--global
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
		--update fatalities with value
		scoreLabel.text = "Score: " .. score
end

---------------------------------------------------------------------------------------------------
-- Create Scene
--create initial scene
function scene:create( event )
   local sceneGroup = self.view

	 physics.start()
	 --physics.setGravity( 0, 0 )

	 addScrollableBg()

  --create button group
  buttonGroup = display.newGroup()

  leftButton = display.newImageRect( buttonGroup, "leftButtonShape.png", 50, 50 )
  leftButton.x, leftButton.y = 0, 270
  leftButton.canSlideOn = true
  leftButton.ID = "left"
  leftButton:toBack()
  leftButton.alpha = 0.7
  --sceneGroup:insert(leftButton);
  buttonGroup:insert(leftButton);

  rightButton = display.newImageRect( buttonGroup, "rightButtonShape.png", 50, 50 )
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

                      ship:setSequence("left");
                  elseif ( buttonGroup.activeButton.ID == "right" ) then
                      ship:setLinearVelocity( 100, 0 )
                      hitBoxS:setLinearVelocity( 100, 0 )

                      ship:setSequence("right");
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

	--creation of powerButton
	powerButton = display.newImage("powerButtonRing.png")
	   powerButton.xScale = 1
	   powerButton.yScale = 1
	   powerButton.x = 480
	   powerButton.y = 217
		 powerButton:toBack()
		 powerButton.alpha = 0.2
		 sceneGroup:insert(powerButton);
     --set ship hit box to destructable
     local function addHB( event )
     	hitBoxS.name = "ship"
       hitBoxS.alpha = 0
     end

     --set ship to invincible
     local function powerUp( event )
       if (powerButton.alpha == 1) then
         audio.play(sfx.usepower, { channel=3 } );
       	 hitBoxS.name = "invinc"
         hitBoxS.alpha = 0.5
        	timer.performWithDelay( 5000, addHB,1)
         powerButton.alpha = 0.5
       end
     end
  powerButton:addEventListener( "touch", powerUp )

  --initialize score value
	scoreLabel.text = "Score: " .. score
	highLabel.text = "High Score: " .. loadedSettings.highScore


end  --end create scene

---------------------------------------------------------------------------------------------------
-- Game Over
function gameOver ()
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
 -- Level Up
 function levelUp ()
     audio.play(sfx.levelup, { channel=2 } );
     audio.setMaxVolume( 0.65, { channel=2 } )
     --stop ship if mid-flight
     ship:setLinearVelocity( 0, 0 )
     hitBoxS:setLinearVelocity( 0, 0 )
     ship:setSequence("idle");

     --game over label
     local levelup =
     {
        text = "Level Up",
        x = display.contentCenterX+10,
        y = display.contentCenterY+80,
        width = 250,
        font = native.systemFont,
        fontSize = 35,
        align = "center"  -- Alignment parameter
     }
     levelupGroup = display.newGroup()
     levelupGroup.text = display.newText(levelup)

     for i, v in ipairs(enemies) do
       if v.removeSelf then
         v:removeSelf()
       end
     end
     enemies = {}

   --set effects for scene transition
    local options = {
      effect = "fade",
      --time = 500
       time = 1000
    }
    --ship.x = display.contentCenterX+25
    --hitBoxS.x = display.contentCenterX+15

     --call level 2
     timer.performWithDelay(1000, composer.gotoScene("level2", options), 1)

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
   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
		 physics.start()
     addScrollableBg()
     buttonGroup:toFront()
     powerButton:toFront()
     powerButton.alpha = 0.5
     -- Play the background music on channel 1, loop infinitely, and fade in
     bgMusicChannel = audio.play( sfx.bg, { channel=1, loops=-1, fadein=1000 } )
     audio.setMaxVolume( 0.85, { channel=1 } )
		 score = 0
		 --reset first pass every game
		 bIsFirstPass = true
   elseif ( phase == "did" ) then
     Runtime:addEventListener("enterFrame", enterFrame)
		 timer1 = timer.performWithDelay(delay,scoreUp,0)
   end
end

--hide scene
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
    Runtime:removeEventListener( "enterFrame", enterFrame )
   	--cancel timer before moving to next scene
   	timer.cancel(timer1)
    --physics.pause()
   elseif ( phase == "did" ) then
     transition.cancelAll()
     for i, v in ipairs(enemies) do
       if v.removeSelf then
         v:removeSelf()
       end
     end
     enemies = {}

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



--
local function onGlobalCollision( event )
    if event.phase == "began" and event.object1.name == "ship" then

        if event.object2.name == "enemy" then
    		  gameOver()
    	  elseif event.object2.name == "pup" then
          if (powerButton.alpha < 1) then
            audio.play(sfx.collect, { channel=3 } );
            audio.setMaxVolume( 0.65, { channel=3 } )
          end
      		powerButton.alpha = 1
        end

    end
end
Runtime:addEventListener( "collision", onGlobalCollision )


return scene
