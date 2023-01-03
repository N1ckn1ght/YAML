Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)
    game:init()
    return game
end

function Game:init()
    self.ship = Ship:create(400, 400)
    self.segments = {}
    for i = 1, 100 do
        local ty = -10
        if (i % 2 == 0) then
            ty = -ty
        end
        self.segments[i] = Segment:create(Vector:create((i - 1) * 20 - 500, -ty), Vector:create(i * 20 - 500, ty))
    end
    self.cameras = {}
    self.cameras[1]   = Camera:create(Width, Height, self.ship)
    self.cameras[2]   = Camera:create(Width * 0.5, Height * 0.5, self.ship)
    self.camera = 1
end

function Game:update(dt)
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