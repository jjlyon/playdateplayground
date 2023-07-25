import "CoreLibs/graphics"
import "CoreLibs/object"

import "collision"
import "pointmass"

local geo <const> = playdate.geometry
local gfx <const> = playdate.graphics

local vec <const> = geo.vector2D.new

local inf <const> = 1e309

-- Constants
local SCREEN_WIDTH, SCREEN_HEIGHT = playdate.display.getWidth(), playdate.display.getHeight()
local SPEED_X, SPEED_Y = 1, -1

class("softbody").extends()

function softbody:init()
    self.points = {}
    self.gravity = vec(0, 10)
    self.elasticity = 0.5
    self.friction = 10
    for i = 1, 1 do
        self.points[i] = pointmass(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 100, 100, 100)
    end
    -- self.box = createRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
end

function softbody:update()
    local dt = 0.02
    
    for i = 1, #self.points do
        -- playdate.wait(500)
        local p = self.points[i]
        p:update(self.gravity, 0.2)

        local collision = softbody:collideWithWorld(p)
        
        print("pos " .. p.position.y .. " depth " .. collision.depth)

        -- skip if already collided
        if collision.depth < 0 then
            print("skipping")
            goto continue
        end

        -- resolve constraint
        p.position += collision.normal * collision.depth

        -- compute normal and tangential velocities
        local vn = collision.normal * collision.normal:dotProduct(p.velocity)
        local vt = p.velocity - vn

        -- bounce
        vn *= -self.elasticity

        -- friction
        vt *= math.exp(-self.friction * dt)

        p.velocity = vn + vt
        ::continue::
    end
    -- self:handleButtons()
end

function softbody:collideWithWorld(point)
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

function softbody:findCollision()
    local collision = nil
    for i = 1, #self.points do
        local c = self.points[i]:collision(SCREEN_HEIGHT)
        if not collision or c.depth > collision.depth then
            collision = c
        end
    end
    return collision
end

function softbody:draw()
    for i = 1, #self.points do
        local p = self.points[i]:getPositionPoint()
        gfx.drawCircleAtPoint(p.x, p.y, 5)
    end
    -- gfx.drawPolygon(self.box)
end

function softbody:handleButtons()
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

function createCircle(center, radius, segments)
    local points = {}
    for i = 0, segments do
        local angle = (i - 1) * (2 * math.pi / segments)
        
        points[i] = geo.point.new(center.x + radius * math.cos(angle),center.y + radius * math.sin(angle))
    end
    local polygon = geo.polygon.new(points)
    polygon:close()
    return polygon
end
