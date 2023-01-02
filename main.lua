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
    Scale = 1

    CurrentGame = Game:create()
    Cameras = {Camera:create(), Camera:create()}
    CurrentGamera = Cameras[1]
end

function love.update(dt)
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
end

function draw(polygon, type)
    -- Use cameras here
end