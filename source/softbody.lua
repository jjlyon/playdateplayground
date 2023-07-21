import "CoreLibs/graphics"
import "CoreLibs/object"

local gfx <const> = playdate.graphics

-- Constants
local SCREEN_WIDTH, SCREEN_HEIGHT = 400, 240
local SPEED_X, SPEED_Y = 1, -1

class("softbody").extends()

function softbody:init()
    self.x = SCREEN_WIDTH / 2
    self.y = SCREEN_HEIGHT / 2
    self.radius = 30
    self.segments = 10
    self.stiffness = 50
    self.points = {}
    self:create()
end

function softbody:create()
    for i = 1, self.segments do
        local angle = (i - 1) * (2 * math.pi / self.segments)
        local point = {
            x = self.x + self.radius * math.cos(angle),
            y = self.y + self.radius * math.sin(angle),
            vx = 0,
            vy = 0
        }
        table.insert(self.points, point)
    end
end

function softbody:update()
    local dt = 0.02
    for i, point in ipairs(self.points) do
        local dx, dy = self.x - point.x, self.y - point.y
        local distance = math.sqrt(dx * dx + dy * dy)
        local targetDistance = self.radius-- + self.radius * (i / self.segments)

        local force = self.stiffness * (distance - targetDistance)

        local angle = math.atan(dy, dx)
        point.vx = point.vx + force * math.cos(angle)
        point.vy = point.vy + force * math.sin(angle)

        point.x = point.x + point.vx * dt
        point.y = point.y + point.vy * dt
    end
    self:handleButtons()
end

function softbody:draw()
    for _, point in ipairs(self.points) do
        gfx.drawCircleAtPoint(point.x, point.y, 3)
    end
    gfx.drawCircleAtPoint(self.x, self.y, 5)

    gfx.setLineWidth(2)
    for i = 1, self.segments - 1 do
        gfx.drawLine(self.points[i].x, self.points[i].y, self.points[i + 1].x, self.points[i + 1].y)
    end
    gfx.drawLine(self.points[1].x, self.points[1].y, self.points[self.segments].x, self.points[self.segments].y)
end

function softbody:handleButtons()
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        self.y += SPEED_Y
    end
    
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        self.y -= SPEED_Y
    end
    
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.x += SPEED_X
    end
    
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.x -= SPEED_X
    end
end

function softbody:buttonHandlers()
    return {
        upButtonDown = function()
            self.y += SPEED_Y
            print("up")
        end,
        downButtonDown = function()
            self.y -= SPEED_Y
        end,
        rightButtonDown = function()
            self.x += SPEED_X
        end,
        leftButtonDown = function()
            self.x -= SPEED_X
        end
    }
end