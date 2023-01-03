Ship = {}
Ship.__index = Ship

function Ship:create(x, y, size, k)
    local ship = {}
    setmetatable(ship, Ship)
    ship.location     = Vector:create(x, y)
    ship.velocity     = Vector:create(0, 0)
    ship.acceleration = Vector:create(0, 0)
    ship.heading      = -math.pi * 0.5
    ship.normals      = nil
    ship.size         = size or 5
    ship.k            = k or 1.6
    ship.vertices     = {ship.size * ship.k, 0, -ship.size * ship.k, -ship.size, -ship.size, 0, -ship.size * ship.k, ship.size}
    return ship
end

function Ship:update(dt)
    self.velocity:add(self.acceleration * dt)
    self.location:add(self.velocity * dt)
    self.acceleration:mul(0)
end

function Ship:draw(offsetX, offsetY, scaleX, scaleY)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.push()
    love.graphics.translate(offsetX + self.location.x, offsetY + self.location.y)
    love.graphics.rotate(self.heading)
    love.graphics.scale(scaleX, scaleY)
    love.graphics.setColor(0, 1, 1, 1)
    love.graphics.polygon("fill", self.vertices)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.polygon("line", self.vertices)
    love.graphics.pop()
    love.graphics.setColor(r, g, b, a)
end

function Ship:applyForce(force)
    self.acceleration:add(force)
end