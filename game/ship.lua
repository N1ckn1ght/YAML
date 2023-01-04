Ship = {}
Ship.__index = Ship

function Ship:create(x, y, size, k, engineAccel, engineAngle, fuel, fuelConsumption)
    local ship = {}
    setmetatable(ship, Ship)

    ship.location     = Vector:create(x, y)
    ship.velocity     = Vector:create(0, 0)
    ship.acceleration = Vector:create(0, 0)
    ship.heading      = -math.pi * 0.5

    -- these are draw() vertices
    ship.vertices     = {size * k, 0, -size * k, -size, -size, 0, -size * k, size}
    -- these are vertices for collision detector
    ship.collisions   = {{}, {}}

    ship.fuel             = fuel
    ship.fuelConsumption  = fuelConsumption
    ship.isSpending       = false
    ship.engineAccel      = engineAccel
    ship.engineAngle      = engineAngle
    ship.size             = size
    ship.k                = k

    ship:init()
    return ship
end

function Ship:init()
    -- Collision detection --
    self.normals = nil
end

function Ship:update(dt)
    self.velocity:add(self.acceleration * dt)
    self.location:add(self.velocity * dt)
    self.acceleration:mul(0)
    if (self.isSpending) then
        self.fuel = self.fuel - self.fuelConsumption * dt
        self.isSpending = false
    end
end

function Ship:draw(offsetX, offsetY, scaleX, scaleY)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.push()
    love.graphics.scale(scaleX, scaleY)
    love.graphics.translate(offsetX + self.location.x, offsetY + self.location.y)
    love.graphics.rotate(self.heading)
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

function Ship:applyPower()
    if (self.fuel > 0) then
        local fx = self.engineAccel * math.cos(self.heading)
        local fy = self.engineAccel * math.sin(self.heading)
        self.isSpending = true
        self:applyForce(Vector:create(fx, fy))
    end
end

function Ship:rotate(dt)
    self.heading = self.heading + self.engineAngle * dt
    if (self.heading < -math.pi) then
        self.heading = -math.pi
    elseif (self.heading > 0) then
        self.heading = 0
    end
end