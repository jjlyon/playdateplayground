import "CoreLibs/graphics"
import "CoreLibs/object"

import "collision"

local geo <const> = playdate.geometry

class("pointmass").extends()

function pointmass:init(x, y, vx, vy)
    self.position = geo.vector2D.new(x, y)
    self.velocity = geo.vector2D.new(vx, vy)
end

function pointmass:getPositionPoint()
    return geo.point.new(self.position.x, self.position.y)
end

function pointmass:update(acl, dt)
    self.velocity += acl * dt
    self.position.x += self.velocity.x * dt
    self.position.y += self.velocity.y * dt
end
