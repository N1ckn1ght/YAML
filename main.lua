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