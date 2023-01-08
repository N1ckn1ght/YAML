Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)
    game:init()
    return game
end

function Game:init()
    self.ship = Ship:create(1000, 150, 3.4, 27, 2, 1000, 15)
    self.ship.velocity.x = 100
    self.ship.velocity.y = 0
    self.ship.heading = -math.pi
    self.cameras = {}
    self.cameras[1]   = Camera:create(Width,       Height,       self.ship, {250, 100, 250, 300})
    self.cameras[1].location.y = self.cameras[1].location.y + 200
    self.cameras[2]   = Camera:create(Width * 0.5, Height * 0.5, self.ship, {150, 120, 150, 150})
    self.cameras[3]   = Camera:create(Width * 0.25, Height * 0.25, self.ship, {100, 80, 100, 80})
    self.camera = 1
    self.gravity = 7.5
    self.friction = 0.06
    self.terrain = Terrain:create(0, 200, 6000, 640, 0.6, 0.05, 20, self.ship.size * 2.25, self.ship.size * 4, 0.15, 0.1, {{20, 1}})
    self.collider = Collider:create(self, self.ship, self.terrain)
end

function Game:update(dt)
    if (self.ship ~= nil and self.stop == nil) then
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

        local nearestSegmentIndex = self.terrain:findNearestSegment(self.ship.location.x)

        local altitude = self.terrain.segments[nearestSegmentIndex].p1.y - self.ship.location.y
        if (altitude < 120) then
            if (altitude < 20) then
                if (self.carema ~= 3) then
                    self.cameras[3]:center()
                    self.camera = 3
                end
            else
                if (self.camera == 1) then
                    self.cameras[2]:center()
                    self.camera = 2
                elseif (altitude > 40) then
                    self.camera = 2
                end
            end
        elseif (altitude > 150) then
            self.camera = 1
        end
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

        self.collider:update()
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

function Game:onCollision(segments)
    self.ship.colorFill = {1, 0, 0, 1}
    self.stop = 1
    for i = 1, #segments do
        print("Collision confirmed with the segment No.", segments[i])
    end
end