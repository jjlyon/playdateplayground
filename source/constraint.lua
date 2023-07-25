import "CoreLibs/graphics"
import "CoreLibs/object"

local geo <const> = playdate.geometry

class("constraint").extends()

function constraint:init(point0, point1, distance, springForce, springDamping)
    self.point0 = point0
    self.point1 = point1
    self.distance = distance
    self.springForce = springForce
    self.springDamping = springDamping
    self.name = point0.name .. "-" .. point1.name
end

function constraint:constrain(dt)
    local pos0, vel0 = self.point0.position, self.point0.velocity
    local pos1, vel1 = self.point1.position, self.point1.velocity

    local dPos = pos1 - pos0
    local direction = dPos:normalized()

    local requiredDelta = direction * self.distance
    local deltaDelta = requiredDelta - dPos
    local force = deltaDelta * self.springForce

    vel0 -= force * dt
    vel1 += force * dt

    self.point0.velocity = vel0
    self.point1.velocity = vel1

    -- local vrel = vel1 - vel0
    -- vrel = vrel:dotProduct(direction)
    -- local dampingFactor = math.exp(-self.springDamping * dt)
    -- local newVrel = vrel * dampingFactor
    -- local vrelDelta = newVrel - vrel

    -- vel0 -= vrelDelta / 2
    -- vel1 += vrelDelta / 2
end