Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)
    game:init()
    return game
end

function Game:init()
    self.ship = Ship:create(400, 400, 5, 1.6, 25, 1, 1000, 80)
    self.segments = {}
    for i = 1, 100 do
        local ty = -10
        if (i % 2 == 0) then
            ty = -ty
        end
        self.segments[i] = Segment:create(Vector:create((i - 1) * 20 - 500, Height - ty), Vector:create(i * 20 - 500, Height + ty))
    end
    self.cameras = {}
    self.cameras[1]   = Camera:create(Width, Height, self.ship)
    self.cameras[2]   = Camera:create(Width * 0.5, Height * 0.5, self.ship)
    self.camera = 1
    self.gravity = 7
    self.friction = 0.05
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
    
    local friction = -self.friction * self.ship.velocity.x
    self.ship:applyForce(Vector:create(friction, self.gravity))
    self.ship:update(dt)    
    self.cameras[self.camera]:update()
end

function Game:draw()
    local offsetX = -self.cameras[self.camera].location.x
    local offsetY = -self.cameras[self.camera].location.y
    local scaleX  =  self.cameras[self.camera].scaleX
    local scaleY  =  self.cameras[self.camera].scaleY
    self.ship:draw(offsetX, offsetY, scaleX, scaleY)
    for i = 1, #self.segments do
        self.segments[i]:draw(offsetX, offsetY, scaleX, scaleY)
    end
end