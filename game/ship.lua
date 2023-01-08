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
    ship.colorIdle       = {0, 1, 1, 1}
    self.colorFill       = {1, 0, 0, 1}
    ship.colorLine       = {1, 1, 1, 1}
    ship.isAlive         = true

    ship:init()
    return ship
end

function Ship:init()
    local k = {0.6, 0.5, 0.3, 1.1, 1.3}
    
    self.polygons[1] = {self.size * k[5],         0,                -self.size * k[5],        -self.size,        -self.size,       0}
    self.polygons[2] = {self.size * k[5],         0,                -self.size * k[5],         self.size,        -self.size,       0}
    self.polygons[3] = {self.size * k[5] * k[1], -self.size * k[2], -self.size * k[5] * k[3], -self.size * k[4], -self.size * 0.2, 0}
    self.polygons[4] = {self.size * k[5] * k[1],  self.size * k[2], -self.size * k[5] * k[3],  self.size * k[4], -self.size * 0.2, 0}

    self.particles = {}

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
    if (self.isAlive) then
        self.velocity:add(self.acceleration * dt)
        self.location:add(self.velocity * dt)
        self.acceleration:mul(0)
        if (self.isSpending) then
            self.fuel = self.fuel - self.fuelConsumption * dt
            self.isSpending = false
        end
    else
        for i = 1, #self.particles do
            self.particles[i]:update(dt)
        end
    end
end

function Ship:draw(offsetX, offsetY, scaleX, scaleY)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.push()
    love.graphics.scale(scaleX, scaleY)
    love.graphics.translate(offsetX + self.location.x, offsetY + self.location.y)

    if (self.isAlive) then
        love.graphics.rotate(self.heading)
        love.graphics.setColor(self.colorIdle)
        if (self.el) then
            self.el = false
            love.graphics.setColor(self.colorFill)
        end
        love.graphics.polygon("fill", self.polygons[4])
        if (self.er) then
            self.er = false
            love.graphics.setColor(self.colorFill)
        else
            love.graphics.setColor(self.colorIdle)
        end
        love.graphics.polygon("fill", self.polygons[3])
        if (self.up) then
            self.up = false
            love.graphics.setColor(self.colorFill)
        else
            love.graphics.setColor(self.colorIdle)
        end
        love.graphics.polygon("fill", self.polygons[1])
        love.graphics.polygon("fill", self.polygons[2])
        love.graphics.setColor(self.colorLine)
        for i = 1, #self.polygons do
            love.graphics.polygon("line", self.polygons[i])
        end
    else
        love.graphics.setColor(self.colorLine)
        for i = 1, #self.particles do
            self.particles[i]:draw()
        end
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
        self.up = true
    end
end

function Ship:rotate(dt)
    self.heading = self.heading + self.engineAngle * dt
    if (self.heading < -math.pi) then
        self.heading = -math.pi
    elseif (self.heading > 0) then
        self.heading = 0
    end

    if (dt < 0) then
        self.el = true
    else
        self.er = true
    end
end

function Ship:crash(gravity)
    self.particles = {}
    for i = 1, #self.polygons do
        for j = 1, #self.polygons[i], 2 do
            self.particles[#self.particles + 1] = Particle:create(Vector:create(self.polygons[i][j], self.polygons[i][j + 1]), Vector:create(self.polygons[i][(j + 1) % #self.polygons[i] + 1], self.polygons[i][(j + 2) % #self.polygons[i] + 1]), gravity)
        end
    end
    self.isAlive = false
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