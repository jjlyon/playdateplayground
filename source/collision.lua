import "CoreLibs/graphics"
import "CoreLibs/object"

local geo <const> = playdate.geometry

class("collision").extends()

function collision:init(depth, normal)
    self.depth = depth
    self.normal = normal
end