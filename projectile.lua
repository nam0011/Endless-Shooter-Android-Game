--  Group Project: CS371, Instructor: Dr Chung
local entity = require("entity")
local physics = require("physics")

if not Projectile then
  Projectile = entity:new({
    tag = "projectile",
    hp = 1,
    power = 1,
    physics = {"dynamic", { radius = 4 }},
    initialVelocity = {0, 0},
    force = {0, -2},
    lifeTime = 1000,
    destroyOnCollide = { enemy = true }
  })
end

local function killProjectile(e)
    if e.source and e.source.params and e.source.params.self then
        local s = e.source.params.self
        if s.removeSelf then
            s.pp.shape = nil
            s:removeSelf()
        end
    end
end

function Projectile:spawn(grp)
    self.shape = display.newCircle(self.x or 0, self.y or 0, 5)
    self.shape:setFillColor(0, 1, 0)
    self.shape.anchorY = 1

    self:initShape(grp)

    self.shape:setLinearVelocity(unpack(self.initialVelocity))
    self.shape:applyForce(self.force[1], self.force[2], self.x, self.y)

    self.lifeTimer = timer.performWithDelay(self.lifeTime, killProjectile)
    self.lifeTimer.params = { self = self.shape }
end

function Projectile:collision(event)
  if event.name == "postCollision" then
    local r = self:onDeath()
    if r then return end

    event.target:removeSelf()
    self.shape = nil
  end
end

return Projectile
