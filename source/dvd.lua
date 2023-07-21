import "CoreLibs/crank"
import "CoreLibs/graphics"
import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("dvd").extends()

function dvd:init(xspeed, yspeed)
    self.label = {
		x = 155,
		y = 110,
		xspeed = xspeed,
		yspeed = yspeed,
		width = 100,
		height = 20,
		radius = 10
	}
end

function dvd:swapColors()
	if (gfx.getBackgroundColor() == gfx.kColorWhite) then
		gfx.setBackgroundColor(gfx.kColorBlack)
		gfx.setImageDrawMode("inverted")
		gfx.setColor(gfx.kColorWhite)
	else
		gfx.setBackgroundColor(gfx.kColorWhite)
		gfx.setImageDrawMode("copy")
		gfx.setColor(gfx.kColorBlack)
	end
end

function dvd:update()
    local label = self.label;
    local swap = false
	if (label.x + label.width >= 400 or label.x <= 0) then
        label.xspeed = -label.xspeed;
		swap = true
    end
        
    if (label.y + label.height >= 240 or label.y <= 0) then
        label.yspeed = -label.yspeed;
		swap = true
	end

	if (swap) then
		self:swapColors()
	end

	label.x += label.xspeed
	label.y += label.yspeed
end

function dvd:handleCrank(change, acceleratedChange)
	local label = self.label
	label.radius += change
	if label.radius < 1 then
		label.radius = 1
	end
end

function dvd:draw()
    local label = self.label;
	gfx.drawCircleAtPoint(label.x, label.y, label.radius)
    gfx.drawTextInRect("Template", label.x, label.y, label.width, label.height)
end