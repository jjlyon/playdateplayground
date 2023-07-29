import "CoreLibs/graphics"
import "CoreLibs/object"

import "collision"
import "constraint"
import "pointmass"
import "softbody"

local geo <const> = playdate.geometry
local gfx <const> = playdate.graphics

local vec <const> = geo.vector2D.new

local inf <const> = 1e309

-- Constants
local SCREEN_WIDTH, SCREEN_HEIGHT = playdate.display.getWidth(), playdate.display.getHeight()
local SPEED_X, SPEED_Y = 1, -1

class("sbengine").extends()

function sbengine:init()
    self.gravity = vec(0, 9.8)
    self.elasticity = 0.5
    self.friction = 10
    self.springForce = 100
    -- self.points = {}
    -- self.points[1] = pointmass(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 100, 100, 100)
    -- self.points[2] = pointmass(SCREEN_WIDTH - 110, SCREEN_HEIGHT - 110, 100, 100)

    -- self.constraints = {}

    -- self.constraints[1] = constraint(self.points[1], self.points[2], 14, 100, 10)
    -- self.box = createRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.points = createCircleSoftbody(vec(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2), 30, 10)
    self._points = createCircleSoftbody(vec(0, 0), 30, 10)
    
    -- printTable(self.constraints)
end

function sbengine:update(dt)
    -- playdate.wait(500)
    for point, i in self.points:iterator() do
        -- playdate.wait(500)
        point:update(self.gravity, dt)

        local collision = sbengine:collideWithWorld(point)
        self:resolveCollision(point, collision, dt)
    end
    -- for i, constraint in ipairs(self.constraints) do
    --     constraint:constrain(dt)
    -- end
    self:rotateShapeBody(self.points:centerOfMass(), dt)
    -- self:handleButtons()
end

function sbengine:resolveCollision(point, collision, dt)
    -- skip if already/never collided
    if collision.depth < 0 then
        return
    end

    -- resolve constraint
    point.position += collision.normal * collision.depth

    -- compute normal and tangential velocities
    local vn = collision.normal * collision.normal:dotProduct(point.velocity)
    local vt = point.velocity - vn

    -- bounce
    vn *= -self.elasticity

    -- friction
    vt *= math.exp(-self.friction * dt)

    point.velocity = vn + vt
end

function sbengine:collideWithWorld(point)
    local pos = point.position
    local collision_h = collision(-inf, vec(0, 0))
    if pos.x < 0 then
        collision_h = collision(0 - pos.x, vec(1, 0))
    elseif pos.x > SCREEN_WIDTH then
        collision_h = collision(pos.x - SCREEN_WIDTH, vec(-1, 0))
    end

    local collision_v = collision(-inf, vec(0, 0))
    if pos.y < 0 then
        collision_v = collision(0 - pos.y, vec(0, 1))
    elseif pos.y > SCREEN_HEIGHT then
        collision_v = collision(pos.y - SCREEN_HEIGHT, vec(0, -1))
    end

    if collision_h.depth > collision_v.depth then return collision_h else return collision_v end
end

function sbengine:calculateCenterOfMass(sb)
    local center = vec(0, 0)
    local count = 0
    for point in sb:iterator() do
        center += point.position
        count += 1
    end
    return center / count
end

function sbengine:rotateShapeBody(center, dt)
    local a, b = 0, 0
    for point, i in self.points:iterator() do
        local r = point.position - center
        local v = self._points:getPointAt(i)
        a += r:dotProduct(v.position)
        b += wedgeProduct(r, v.position)
    end
    local angle = -math.atan(b, a)
    if math.abs(angle) < 0.001 then angle = 0 end
    for point, i in self.points:iterator() do
        local pointOffsetAngle = (i * 2 * math.pi / self.points.size) + angle
        local v = self._points:getPointAt(i)
        local target = geo.vector2D.newPolar(v.position:magnitude(), pointOffsetAngle * 180 / math.pi + 90) + center
        print("target " .. tostring(target) .. " point " .. tostring(v.position) .. " angle " .. angle .. " pointoffset " .. pointOffsetAngle)
        local delta = target - point.position
        point.velocity += delta * self.springForce * dt
        print(delta)
    end
end

function wedgeProduct(a, b)
    return a.x * b.y - a.y * b.x
end

function sbengine:draw()
    for point in self.points:iterator() do
        local p = point.position
        gfx.drawCircleAtPoint(p.x, p.y, 5)
    end
    local center = self.points:centerOfMass()
    gfx.drawCircleAtPoint(center.x, center.y, 10)

    -- for i, constraint in ipairs(self.constraints) do
    --     gfx.drawLine(constraint.point0.position.x, constraint.point0.position.y, constraint.point1.position.x, constraint.point1.position.y)
    -- end
        -- gfx.drawPolygon(self.box)
end

function sbengine:handleButtons()
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        self.position.y += SPEED_Y
    end
    
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        self.position.y -= SPEED_Y
    end
    
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.position.x += SPEED_X
    end
    
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.position.x -= SPEED_X
    end
end

function createRect(x, y, width, height)
    local polygon = geo.polygon.new(x, y, x + width, y, x + width, y + height, x, y + height)
    polygon:close()
    return polygon
end

-- function createCircle(center, radius, segments)
--     local points = {}
--     for i = 0, segments do
--         local angle = (i - 1) * (2 * math.pi / segments)
        
--         points[i] = geo.point.new(center.x + radius * math.cos(angle),center.y + radius * math.sin(angle))
--     end
--     local polygon = geo.polygon.new(points)
--     polygon:close()
--     return polygon
-- end

function createCircle(center, radius, segments, springForce)
    local points = {}
    for i = 1, segments do
        local angle = (i) * (2 * math.pi / segments)
        local angleDeg = angle * 180 / math.pi
        local x = center.x + radius * math.cos(angle)
        local y = center.y + radius * math.sin(angle)
        local name = "point" .. angleDeg
        points[i] = pointmass(vec(x, y), vec(0, 0), name)
    end
    local arc = 2 * math.pi * radius / segments
    local constraints = {}
    local last = points[segments]
    for i, point in ipairs(points) do
        constraints[i] = constraint(last, point, arc, springForce, 10)
        last = point
    end
    return points, constraints
end


function createCircleSoftbody(center, radius, segments)
    local sb = softbody()
    for i = 0, segments - 1 do
        local angle = i * 2 * math.pi / segments
        local x = center.x + radius * math.cos(angle)
        local y = center.y + radius * math.sin(angle)
        sb:appendVertex(pointmass(vec(x, y), vec(0, 0)))
    end
    return sb
end