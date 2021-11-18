local composer = require("composer")
local entity = require("entity")
local pentagon = require("pentagon")
local triangle = require("triangle")
local projectile = require("projectile")
local widget = require("widget")

local scene = composer.newScene()

local cnt = 0
local score = 0
local timeLimit = 3 * 60000
local pause = false
local runtime = 0
local triChance = 0.0035
local pentChance = 0.0035
local lastTri = 0
local lastPent = 0
local scrollSpeed = 1.4
local bg1 = nil
local bg2 = nil
local enemies = {}

local function addScrollableBg()
    local bgImage = { type="image", filename="bg.png" }

    -- Add First bg image
    bg1 = display.newRect(scene.view, 0, 0, display.contentWidth, display.actualContentHeight)
    bg1.fill = bgImage
    bg1.x = display.contentCenterX
    bg1.y = display.contentCenterY

    -- Add Second bg image
    bg2 = display.newRect(scene.view, 0, 0, display.contentWidth, display.actualContentHeight)
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

local function scoreUp ()
    score = score + 100
    scene.scoreText.text = "Score: " .. score
    audio.play(sfx.point)
end

local function getDeltaTime()
    local temp = system.getTimer()
    local dt = (temp - runtime) / (1000 / 60)
    runtime = temp
    return dt
end

local function spawnPentagon()
    local pent = pentagon:new({ x = math.random(25, display.contentWidth - 25), y = 135 }, { destY = scene.player.y })
    pent:spawn(scene.view)
    pent:move()

    pent.shape.isFixedRotation = true
    pent.onDeath = scoreUp
    lastPent = system.getTimer()

    table.insert(enemies, pent.shape)
end

local function spawnTriangle()
    local tri = triangle:new({ x = math.random(25, display.contentWidth - 25), y = 135 }, { target = scene.player.shape })
    tri:spawn(scene.view)
    tri:move()

    tri.shape.isFixedRotation = true
    tri.onDeath = scoreUp
    lastTri = system.getTimer()

    table.insert(enemies, tri.shape)
end

local function enterFrame()
    local dt = getDeltaTime()
    local t = system.getTimer()

    scene.hpText.text = "HP: " .. scene.player.hp

    if pause then return end

    moveBg(dt)

    local rt = triChance * dt
    local rp = pentChance * dt

    if math.random() < rt or t - lastTri > 2000 then spawnTriangle() end
    if math.random() < rp or t - lastPent > 2000 then spawnPentagon() end
end

local function menuReturn(e)
  local ops = {
    effect = "fade",
    time = 500
  }
  composer.gotoScene("menu", ops)
end

local function gameOver()
    local txt = "Game Over"
    if scene.player.hp > 0 then
        txt = "Congratulations!"
        audio.play(sfx.win)
    end

    scene.gameOverTxt = display.newGroup()
    scene.view:insert(scene.gameOverTxt)

    local t = display.newText(scene.gameOverTxt, txt, display.contentCenterX, display.contentCenterY,
    native.systemFont, 32 );

    local restartButton = widget.newButton({
      label = "Main Menu",
      labelColor = { default = { 1, 1, 1, 0.8 }, over = { 0.2, 0.2, 0.2, 0.8 } },
      font = font,
      onRelease = menuReturn,
      shape = "roundedRect",
      width = display.contentWidth / 2,
      height = display.contentHeight / 8,
      cornerRadius = 4,
      fillColor = { default = {0, 0.2, 1, 1}, over = { 0.2, 0.4, 1, 1 } },
      strokeColor = { default = { 0, 0.1, 0.8, 0.8 }, over = { 0.4, 0.6, 1, 1 } },
      strokeWidth = 4,
      emboss = true
    })
    restartButton.x = display.contentWidth * 0.5
    restartButton.y = display.contentHeight * 0.7

    scene.gameOverTxt:insert(restartButton)

    pause = true
    physics.pause()

    transition.cancel()

    --timer.performWithDelay(3000, menuReturn)
end

local function move ( event )
    if pause then return end

    local cube = scene.player.shape
    if event.phase == "began" then
        cube.markX = cube.x
    elseif event.phase == "moved" then
        local x = (event.x - event.xStart) + cube.markX

        if (x <= 20 + cube.width / 2) then
            cube.x = 20 + cube.width / 2;
        elseif (x >= display.contentWidth - 20 - cube.width / 2) then
            cube.x = display.contentWidth - 20 - cube.width / 2;
        else
            cube.x = x;
        end

    end
end

local function fire (event)
    if pause then return end
    if (cnt < 3) then
        cnt = cnt + 1;
        local p = projectile:new({ x = scene.player.shape.x, y = scene.player.shape.y - 16 })
        p:spawn(scene.view)

        p.onDeath = function (s) cnt = cnt - 1; end

        table.insert(enemies, p.shape)

        audio.play(sfx.shoot)
    end
end

function scene:create(event)
    local sg = self.view

    physics.start()
    physics.setGravity(0, 0)

    addScrollableBg()

    --- Arena
    local top = display.newRect(sg, 0, 100, display.contentWidth, 20)
    local left = display.newRect(sg, 0, 0, 20, display.contentHeight)
    local right = display.newRect(sg, display.contentWidth - 20, 0, 20, display.contentHeight)
    local bottom = display.newRect(sg, 0, display.contentHeight - 120, display.contentWidth, 20)

    top.anchorX = 0; top.anchorY = 0
    left.anchorX = 0; left.anchorY = 0
    right.anchorX = 0; right.anchorY = 0
    bottom.anchorX = 0; bottom.anchorY = 0

    physics.addBody( bottom, "static" )
    physics.addBody( left, "static" )
    physics.addBody( right, "static" )
    physics.addBody( top, "static")

    local controlBar = display.newRect (sg, display.contentCenterX, display.contentHeight - 65, display.contentWidth, 70)
    controlBar:setFillColor(1, 1, 1, 0.5)
    controlBar:addEventListener("touch", move)

    self.player = entity:new({ x = display.contentCenterX, y = display.contentHeight - 150, damagers = { projectile = true, enemy = true }, tag = "player", hp = 5 })
    self.player:spawn(sg)
    self.player.shape.markX = self.player.x
    self.player.onDeath = function () audio.play(sfx.death); gameOver() end
    self.player.onDamage = function (v) audio.play(sfx.crash) end

    self.scoreText =
    display.newEmbossedText(sg, "Score: 0", 210, 50,
    native.systemFont, 32 );

    self.scoreText:setFillColor( 0, 0.5, 0 );

    local color =
    {
        highlight = {0, 1, 1},
        shadow = {0, 1, 1}
    }
    self.scoreText:setEmbossColor( color );

    self.hpText =
    display.newEmbossedText(sg, "HP: 5", 75, 50,
    native.systemFont, 32 );

    self.hpText:setFillColor( 0, 0, 0.5 );

    local color =
    {
        highlight = {0, 1, 1},
        shadow = {0, 1, 1}
    }
    self.hpText:setEmbossColor( color );

    self.scoreText:toFront()
    self.hpText:toFront()

    if self.gameTimer then timer.cancel(self.gameTimer) end
    self.gameTimer = timer.performWithDelay(timeLimit, gameOver)
end

function scene:show(event)
    local sg = self.view

    if event.phase == "will" then
        physics.start()
        self.player.hp = 5
        score = 0

        if not self.player.shape then
          self.player:spawn(sg)
        end
    end

    if event.phase == "did" then
      if self.gameTimer then timer.cancel(self.gameTimer) end
      self.gameTimer = timer.performWithDelay(timeLimit, gameOver)
      pause = false
    end
end

function scene:hide(event)
    local sg = self.view
    if event.phase == "will" then
        physics.pause()

        for i, v in ipairs(enemies) do
          if v.removeSelf then
            v:removeSelf()
          end
        end

        enemies = {}

        if self.gameOverTxt then self.gameOverTxt:removeSelf() end
    end

    if event.phase == "did" then

    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

Runtime:addEventListener("tap", fire)
Runtime:addEventListener("enterFrame", enterFrame)

return scene
