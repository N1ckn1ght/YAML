Segment = {}
Segment.__index = Segment

function Segment:create(p1, p2)
    local segment = {}
    setmetatable(segment, Segment)
    segment.p1      = p1
    segment.p2      = p2
    segment.mag     = nil
    segment.angle   = nil
    segment.normals = nil
    segment:init()
    return segment
end

function Segment:init()
    local diff = p2:sub(p1)
    self.angle = diff:heading()
    self.mag   = diff:mag()
    self.normals = {{-diff.y, diff.x}, {diff.x, diff.y}}
end

function Segment:draw()
    draw({p1.x, p1.y, p2.x, p2.y}, "line")
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