Vector = {}
Vector.__index = Vector

function math.map(value, imin, imax, omin, omax)
    local scale = (omax - omin) / (imax - imin)
    return omin + (value - imin) * scale
end

function Vector:create(x, y)
    local vector = {}
    setmetatable(vector, Vector)
    vector.x = x
    vector.y = y
    return vector
end

function Vector:__tostring()
    return "Vector(x = " .. string.format("%.2f", self.x) .. ", y = " .. string.format("%.2f", self.y) .. ")"
end

function Vector:__add(other)
    return Vector:create(self.x + other.x, self.y + other.y)
end

function Vector:__sub(other)
    return Vector:create(self.x - other.x, self.y - other.y)
end

function Vector:__mul(value)
    return Vector:create(self.x * value, self.y * value)
end

function Vector:__div(value)
    return Vector:create(self.x / value, self.y / value)
end

function Vector:mag()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:norm()
    m = self:mag()
    if (m > 0) then
        self:div(m)
    end
end

function Vector:add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
end

function Vector:sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
end

function Vector:mul(value)
    self.x = self.x * value
    self.y = self.y * value
end

function Vector:div(value)
    self.x = self.x / value
    self.y = self.y / value
end

function Vector:limit(max)
    if self:mag() > max then
        self:norm()
        self:mul(max)
    end
end

function Vector:copy()
    return Vector:create(self.x, self.y)
end

function Vector:heading()
    return math.atan2(self.y, self.x)
end

function Vector:distTo(other)
    return math.sqrt((other.x - self.x) * (other.x - self.x) + (other.y - self.y) * (other.y - self.y))
end

function dotProduct(vec1, vec2)
    return (vec1.x * vec2.x + vec1.y * vec2.y)
end