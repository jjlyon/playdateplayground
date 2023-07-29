import "CoreLibs/graphics"
import "CoreLibs/object"

class("softbody", {size = 0, indexed = {}}).extends()

local vec <const> = playdate.geometry.vector2D.new

function softbody:appendVertex(vertex)
    local vertex = {value = vertex, index = self.size}
    self.indexed[self.size] = vertex.value
    if not self.vertices then self.vertices = vertex end
    if not self.tail then
        self.tail = self.vertices
    else
        self.tail.next = vertex
        self.tail = vertex
    end
    self.size += 1
end

function softbody:getPointAt(index)
    return self.indexed[index]
end

function softbody:iterator()
    local head = self.vertices
    return function ()
        if not head then return nil end
        local vertex = head.value
        local index = head.index
        head = head.next
        return vertex, index
    end
end

function softbody:centerOfMass()
    local center = vec(0, 0)
    for point in self:iterator() do
        center += point.position
    end
    return center / self.size
end