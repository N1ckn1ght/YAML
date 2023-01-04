require "game.camera"
require "game.game"
require "game.segment"
require "game.ship"
require "utility.vector"

function love.load()
    Width = love.graphics.getWidth()
    Height = love.graphics.getHeight()
    love.window.setFullscreen(true, "exclusive")
    Fullscreen = true

    CurrentGame = Game:create()
end

function love.update(dt)
    CurrentGame.ship.velocity = Vector:create(0, 0)
    if (love.keyboard.isDown("w")) then
        CurrentGame.ship.velocity = Vector:create(0, -90)
        print("Velocity:", CurrentGame.ship.velocity)
    end
    if (love.keyboard.isDown("a")) then
        CurrentGame.ship.velocity = Vector:create(-90, 0)
        print("Velocity:", CurrentGame.ship.velocity)
    end
    if (love.keyboard.isDown("s")) then
        CurrentGame.ship.velocity = Vector:create(0, 90)
        print("Velocity:", CurrentGame.ship.velocity)
    end
    if (love.keyboard.isDown("d")) then
        CurrentGame.ship.velocity = Vector:create(90, 0)
        print("Velocity:", CurrentGame.ship.velocity)
    end

    CurrentGame:update(dt)
end

function love.draw()
    CurrentGame:draw()
    showStat(CurrentGame.ship.location.x, 30, 10, 160, 18, 0.7, 0, "x: ")
    showStat(CurrentGame.ship.location.y, 30, 40, 160, 18, 0.7, 0, "y: ")
end

function love.keypressed(key)
    if (key == "f") then
        Fullscreen = not Fullscreen
        love.window.setFullscreen(Fullscreen, "exclusive")
    end
    if (key == "g") then
        CurrentGame.camera = CurrentGame.camera % 2 + 1
    end

    print("Location:", CurrentGame.ship.location)
end

function showStat(metric, x, y, width, fontSize, transparency, mantissa, addText)
    local r, g, b, a = love.graphics.getColor()
    metric = string.format("%."..mantissa.."f", metric)
    addText = addText or ""
    love.graphics.setColor(0, 0, 0, transparency)
    love.graphics.polygon("fill", {x - width * 0.5, y - fontSize * 0.2, x + width * 0.5, y - fontSize * 0.2, x + width * 0.5, y + fontSize * 1.2, x - width * 0.5, y + fontSize * 1.2})
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(addText..metric, love.graphics.newFont(fontSize), x - width * 0.5, y, width, 'center')
    love.graphics.setColor(r, g, b, a)
end