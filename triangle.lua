--  Group Project: CS371, Instructor: Dr Chung
local entity = require("entity")

if not Triangle then
    Triangle = entity:new({
        tag = "enemy",
        hp = 3,
        shapePath = {
            0, 15,
            -13, -8,
            13, -8
        },
        color = {0.1, 0, 0.8, 1},
        pathLoop = false,
        power = 1,
        physics = {"dynamic", {}},
        destroyOnCollide = { player = true }
    })
end

function Triangle:setup(args)
    if not self.path or #self.path < 1 then
        if args.target then
            args.destX = args.target.x
            args.destY = args.target.y
        end

        self.path = {{x = args.destX or self.x, y = args.destY or display.actualContentHeight, time = args.time or 3000}}
    end
end

function Triangle:onPathFinished()
  if self.shape and self.shape.removeSelf then
    self.shape:removeSelf()
  end
    self.shape = nil
end

function Triangle:onDamage(val)
  audio.play(sfx.hit)
end

return Triangle
