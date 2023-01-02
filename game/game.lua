Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)
    return game
end

function Game:update(dt)

end

function Game:draw()

end