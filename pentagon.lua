--  Group Project: CS371, Instructor: Dr Chung
local entity = require("entity")

if not Pentagon then
    Pentagon = entity:new({
        tag = "enemy",
        hp = 2,
        shapePath = {
            0, -15,
            -14, -5,
            -9, 12,
            9, 12,
            14, -5
        },
        color = {0.8, 0.8, 0.1, 1},
        pathLoop = false,
        power = 1,
        physics = {"dynamic", {}},
        destroyOnCollide = { player = true }
    })
end

function Pentagon:setup(args)
    
    if not self.path or #self.path < 1 then
        self.path = {{x = args.destX or self.x, y = args.destY or display.actualContentHeight, time = args.time or 3000}}
    end
end

function Pentagon:onPathFinished()
  if self.shape and self.shape.removeSelf then
    self.shape:removeSelf()
  end
    self.shape = nil
end

function Pentagon:onDamage(val)
  audio.play(sfx.death)
end

return Pentagon
