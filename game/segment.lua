Segment = {}
Segment.__index = Segment

function Segment:create(p1, p2, score)
    local segment = {}
    setmetatable(segment, Segment)

    segment.p1      = p1
    segment.p2      = p2
    segment.score   = score or 0
    segment.mag     = nil
    segment.heading = nil
    segment.color   = nil

    segment:init()
    return segment
end

function Segment:init()
    local diff   = Vector:create(self.p2.x - self.p1.x, self.p2.y - self.p1.y)
    self.heading = diff:heading()
    self.mag     = diff:mag()
    self:setScore(self.score)

    -- Collision detection --

    self.vertices = {Vector:create(self.p1.x, Height * 2), self.p1, self.p2}
    self.normals  = {Vector:create(-diff.y, diff.x), Vector:create(diff.x, diff.y)}
end

function Segment:draw(offsetX, offsetY, scaleX, scaleY)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.push()
    love.graphics.scale(scaleX, scaleY)
    love.graphics.translate(offsetX, offsetY)
    love.graphics.setColor(self.color)
    love.graphics.line(self.p1.x, self.p1.y, self.p2.x, self.p2.y)

    if (self.score >= 1) then
        local px = self.p1.x
        local py = math.min(self.p1.y, self.p2.y) - 50
        love.graphics.printf("x"..self.score, px, py, 100, "left")
    end

    love.graphics.pop()
    love.graphics.setColor(r, g, b, a)
end

function Segment:setScore(score)
    self.score = score

    if (self.score == 0) then
        self.color = {1, 1, 1, 1}
    elseif (self.score == 1) then
        self.color = {1, 1, 0, 1}
    elseif (self.score == 1.5) then
        self.color = {1, 0.5, 0, 1}
    elseif (self.score == 2.25) then
        self.color = {1, 0, 0, 1}
    elseif (self.score == 3.375) then
        self.color = {1, 0, 1, 1}
    else
        print("WARN : Unspecified segment score, x", self.p1.x, "y", self.p1.y)
        self.color = {0, 0, 1, 1}
    end
end

-- Collision detection --

function Segment:getVertices()
    return self.vertices
end

function Segment:getNormals()
    return self.normals
end

function Segment:getMinMaxProj(axis)
    local min_proj = dotProduct(self.vertices[1], axis)
    local max_proj = min_proj
    for i = 2, #self.vertices do
        local temp = dotProduct(self.vertices[i], axis)
        if (temp < min_proj) then
            min_proj = temp
        elseif (temp > max_proj) then
            max_proj = temp
        end
    end
    return min_proj, max_proj
end