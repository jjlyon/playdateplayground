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

    -- connection vector
    local dPos = pos1 - pos0
    -- connection unit vector
    local direction = dPos:normalized()

    -- desired connection vector
    local requiredDelta = direction * self.distance
    -- difference between desired connection and actual
    local deltaDelta = requiredDelta - dPos
    -- force to be applied to points to put them in desired state
    local force = deltaDelta * self.springForce

    -- applying forces
    vel0 -= force * dt
    vel1 += force * dt

    -- velocity relative to each other
    local vrel = vel1 - vel0
    -- scalar projection of relative velocity in the direction of the connection vector
    vrel = vrel:dotProduct(direction)
    -- dampy math stuff
    local dampingFactor = math.exp(-self.springDamping * dt)
    -- how much it will slow down
    local newVrel = vrel * dampingFactor
    -- new speed
    local vrelDelta = newVrel - vrel

    -- I think this is going to apply the new speed to the velocities, but I might need to make them in the direction of the connection first
    vel0 -= direction * (vrelDelta / 2)
    vel1 += direction * (vrelDelta / 2)

    -- setting new velocity to points
    self.point0.velocity = vel0
    self.point1.velocity = vel1
end