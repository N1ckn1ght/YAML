Particle = {}
Particle.__index = Particle

function Particle:create(p1, p2, gravity)
    local particle = {}
    setmetatable(particle, Particle)

    particle.p1 = p1
    particle.p2 = p2
    particle.acceleration = Vector:create(0, gravity or 10)
    particle.velocity = Vector:create(math.random() * 150 - 75, -math.random() * 75)
    particle.lifespan = math.random() * 5 + 5

    return particle
end

function Particle:update(dt)
    self.velocity:add(self.acceleration * dt)
    self.p1:add(self.velocity * dt)
    self.p2:add(self.velocity * dt)
    -- make it to not make memory leak later, please
    self.lifespan = self.lifespan - dt
end

function Particle:draw()
    if (self.lifespan > 0) then
        love.graphics.line(self.p1.x, self.p1.y, self.p2.x, self.p2.y)
    end
end