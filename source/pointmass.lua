import "CoreLibs/graphics"
import "CoreLibs/object"

import "collision"

local geo <const> = playdate.geometry

class("pointmass").extends()

function pointmass:init(pos, vel, name)
    self.position = pos
    self.velocity = vel
    self.name = name
end

function pointmass:getPositionPoint()
    return geo.point.new(self.position.x, self.position.y)
end

function pointmass:update(acl, dt)
    self.velocity += acl * dt
    self.position.x += self.velocity.x * dt
    self.position.y += self.velocity.y * dt
end
