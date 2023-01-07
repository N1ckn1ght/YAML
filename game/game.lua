Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)
    game:init()
    return game
end

function Game:init()
    self.ship = Ship:create(400, 200, 4, 1.6, 25, 1, 10000, 80)
    self.ship.velocity.x = 120
    self.ship.velocity.y = 20
    self.cameras = {}
    self.cameras[1]   = Camera:create(Width,       Height,       self.ship, {250, 100, 250, 300})
    self.cameras[2]   = Camera:create(Width * 0.5, Height * 0.5, self.ship, {150, 120, 150, 150})
    self.camera = 1
    self.gravity = 7
    self.friction = 0.05
    self.terrain = Terrain:create(0, 300, 6000, 700, 1.5, 2, 30, 20, 0.08, 0, {{30, 1}, {20, 4}})
end

function Game:update(dt)
    if (love.keyboard.isDown("w", "up")) then
        self.ship:applyPower()
    end
    if (love.keyboard.isDown("a", "left")) then
        self.ship:rotate(-dt)
    end
    if (love.keyboard.isDown("d", "right")) then
        self.ship:rotate(dt)
    end
    if (love.keyboard.isDown("c")) then
        self.ship.velocity:mul(0)
    end
    
    local friction = -self.friction * self.ship.velocity.x
    self.ship:applyForce(Vector:create(friction, self.gravity))
    self.ship:update(dt)    
    self.cameras[self.camera]:update()

    if (self.ship.location.x < self.terrain.x or self.ship.location.x > self.terrain.x + self.terrain.width) then
        for i = 1, #self.cameras do
            self.cameras[i]:saveRelativePosition()
        end
        self.ship.location.x = (self.ship.location.x - self.terrain.x) % self.terrain.width
        for i = 1, #self.cameras do
            self.cameras[i]:loadRelativePosition()
        end
    end
end

function Game:draw()
    local offsetX = -self.cameras[self.camera].location.x
    local offsetY = -self.cameras[self.camera].location.y
    local scaleX  =  self.cameras[self.camera].scaleX
    local scaleY  =  self.cameras[self.camera].scaleY
    self.ship:draw(offsetX, offsetY, scaleX, scaleY)
    self.terrain:draw(offsetX, offsetY, scaleX, scaleY)
end