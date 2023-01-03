Segment = {}
Segment.__index = Segment

function Segment:create(p1, p2)
    local segment = {}
    setmetatable(segment, Segment)
    segment.p1      = p1
    segment.p2      = p2
    segment.mag     = nil
    segment.heading = nil
    segment.normals = nil
    segment.color   = {1, 1, 1, 1}
    segment:init()
    return segment
end

function Segment:init()
    local diff   = Vector:create(self.p2.x - self.p1.x, self.p2.y - self.p1.y)
    self.heading = diff:heading()
    self.mag     = diff:mag()
    self.normals = {{-diff.y, diff.x}, {diff.x, diff.y}}
end

function Segment:draw(offsetX, offsetY, scaleX, scaleY)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scaleX, scaleY)
    love.graphics.setColor(self.color)
    love.graphics.line(self.p1.x, self.p1.y, self.p2.x, self.p2.y)
    love.graphics.pop()
    love.graphics.setColor(r, g, b, a)
end

-- Collision detection --

function Segment:getNormals()
    return self.normals
end

function Segment:getDots()
    return {{p1.x, p1.y}, {p2.x, p2.y}}
end

function Segment:getMinMaxProj(axis)
    local first  = dotProduct(self.p1, axis)
    local second = dotProduct(self.p2, axis)
    if (first > second) then
        return {second, first}
    else
        return {first, second}
    end
end