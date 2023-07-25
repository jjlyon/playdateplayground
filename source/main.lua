import "dvd" -- DEMO
import "softbody" -- DEMO

local dvd = dvd(1, -1) -- DEMO
local softbody = softbody() -- DEMO

local gfx <const> = playdate.graphics
local font = gfx.font.new('font/Mini Sans 2X') -- DEMO

local function loadGame()
	playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
	math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
	gfx.setFont(font) -- DEMO
	-- playdate.inputHandlers.push(softbody:buttonHandlers())
end

local function updateGame()
	-- dvd:update() -- DEMO
	softbody:update(1 / playdate.getFPS())
end

local function drawGame()
	gfx.clear() -- Clears the screen
	-- dvd:draw() -- DEMO
	softbody:draw()
end

loadGame()

function playdate.update()
	updateGame()
	drawGame()
	playdate.drawFPS(0,0) -- FPS widget
end

function playdate.cranked(change, acceleratedChange)
	-- dvd:handleCrank(change, acceleratedChange)
end