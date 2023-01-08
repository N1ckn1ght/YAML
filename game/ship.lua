Ship = {}
Ship.__index = Ship

function Ship:create(x, y, size, engineAccel, engineAngle, fuel, fuelConsumption)
    local ship = {}
    setmetatable(ship, Ship)

    ship.location        = Vector:create(x, y)
    ship.velocity        = Vector:create(0, 0)
    ship.acceleration    = Vector:create(0, 0)
    ship.heading         = -math.pi * 0.5
    ship.polygons        = {}
    ship.fuel            = fuel
    ship.fuelConsumption = fuelConsumption
    ship.isSpending      = false
    ship.engineAccel     = engineAccel
    ship.engineAngle     = engineAngle
    ship.size            = size
    ship.colorFill       = {0, 1, 1, 1}
    ship.colorLine       = {1, 1, 1, 1}

    ship:init()
    return ship
end

function Ship:init()
    local k = {0.6, 0.5, 0.3, 1.1, 1.3}
    
    self.polygons[1] = {self.size * k[5],         0,                -self.size * k[5],        -self.size,        -self.size,       0}
    self.polygons[2] = {self.size * k[5],         0,                -self.size * k[5],         self.size,        -self.size,       0}
    self.polygons[3] = {self.size * k[5] * k[1], -self.size * k[2], -self.size * k[5] * k[3], -self.size * k[4], -self.size * 0.2, 0}
    self.polygons[4] = {self.size * k[5] * k[1],  self.size * k[2], -self.size * k[5] * k[3],  self.size * k[4], -self.size * 0.2, 0}

    -- Collision detection --
    
    -- todo: make more precise and non-convex collision (use {or} AND {or} checks for different convex parts)
    self.k = k[5]
    self.vertices = {{}, {}}
    self.vertices[1] = Vector:create( self.size * k[5],         0)
    self.vertices[2] = Vector:create(-self.size * k[5] * k[3], -self.size * k[4])
    self.vertices[3] = Vector:create(-self.size * k[5],        -self.size)
    self.vertices[4] = Vector:create(-self.size * k[5],         self.size)
    self.vertices[5] = Vector:create(-self.size * k[5] * k[3],  self.size * k[4])

    self.dots = {}
    for i = 1, #self.vertices do
        self.dots[i] = self.vertices[i]:copy()
    end

    self.normals = {}
    for i = 1, #self.vertices do
        local next = i % #self.vertices + 1
        local px = self.vertices[next].x - self.vertices[i].x
        local py = self.vertices[next].y - self.vertices[i].y
        self.normals[i] = Vector:create(-py, px)
    end
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
    love.graphics.setColor(self.colorFill)
    for i = 1, #self.polygons do
        love.graphics.polygon("fill", self.polygons[i])
    end
    love.graphics.setColor(self.colorLine)
    for i = 1, #self.polygons do
        love.graphics.polygon("line", self.polygons[i])
    end
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

-- Collision detection --

function Ship:getVertices(offset)
    offset = offset or 0
    for i = 1, #self.vertices do
        self.dots[i].x = self.vertices[i].x * math.cos(self.heading) - self.vertices[i].y * math.sin(self.heading) + self.location.x + offset
        self.dots[i].y = self.vertices[i].x * math.sin(self.heading) - self.vertices[i].y * math.cos(self.heading) + self.location.y
    end
    return self.dots
end

function Ship:getNormals(offset)
    local dots = self:getVertices(offset)
    for i = 1, #self.normals do
        local next = i + 1
        if (next > #self.normals) then
            next = 1
        end
        self.normals.y = dots[next].x - dots[i].x
        self.normals.x = dots[i].y - dots[next].y
    end
    return self.normals
end 

function Ship:getMinMaxProj(axis, offset)
    local dots = self:getVertices(offset)
    local min_proj = dotProduct(dots[1], axis)
    local max_proj = min_proj
    for i = 2, #dots do
        local temp = dotProduct(dots[i], axis)
        if (temp < min_proj) then
            min_proj = temp
        elseif (temp > max_proj) then
            max_proj = temp
        end
    end
    return min_proj, max_proj
end