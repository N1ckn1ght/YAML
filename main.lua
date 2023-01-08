require "game.camera"
require "game.game"
require "game.segment"
require "game.ship"
require "game.terrain"
require "utility.vector"
require "utility.utility"

function love.load()
    local seed = os.time()
    math.randomseed(seed)
    print(seed)

    Width = love.graphics.getWidth()
    Height = love.graphics.getHeight()
    love.window.setFullscreen(true, "exclusive")
    Fullscreen = true
    
    local font = love.graphics.newImageFont("fonts/consolas_24px.png", [[ ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-=_+!@#$%^&*()[]{}\|;':",./<>?]])
    love.graphics.setFont(font)
    FontSize = 24

    CurrentGame = Game:create()
end

function love.update(dt)
    
    -- 15 fps min limit (to avoid getting too big delta time when game window is not in focus)
    dt = math.min(dt, 0.067)

    CurrentGame:update(dt)
end

function love.draw()
    CurrentGame:draw()
    showStat(CurrentGame.ship.location.x, 120, 10,  240, FontSize, 0.7, 3, "x   : ", "left")
    showStat(CurrentGame.ship.location.y, 120, 40,  240, FontSize, 0.7, 3, "y   : ", "left")
    showStat(CurrentGame.ship.velocity.x, 120, 70,  240, FontSize, 0.7, 3, "spdX: ", "left")
    showStat(CurrentGame.ship.velocity.y, 120, 100, 240, FontSize, 0.7, 3, "spdY: ", "left")
    showStat(CurrentGame.ship.heading   , 120, 130, 240, FontSize, 0.7, 3, "head: ", "left")
    showStat(CurrentGame.ship.fuel      , 120, 160, 240, FontSize, 0.7, 3, "fuel: ", "left")
    showStat(CurrentGame.terrain:findNearestSegment(CurrentGame.ship.location.x), 120, 190, 240, FontSize, 0.7, 0, "near: ", "left")
end

function love.keypressed(key)
    if (key == "f") then
        Fullscreen = not Fullscreen
        love.window.setFullscreen(Fullscreen, "exclusive")
    end
    if (key == "g") then
        CurrentGame.camera = CurrentGame.camera % 2 + 1
        CurrentGame.cameras[2]:center()
    end
    if (key == "p") then
        CurrentGame.cameras[CurrentGame.camera]:saveRelativePosition()
        CurrentGame.ship.location.x = CurrentGame.ship.location.x - 300
        CurrentGame.cameras[CurrentGame.camera]:loadRelativePosition()
    end
end

function showStat(metric, x, y, width, fontSize, transparency, mantissa, addText, align)
    local r, g, b, a = love.graphics.getColor()
    metric = string.format("%."..mantissa.."f", metric)
    addText = addText or ""
    love.graphics.setColor(0, 0, 0, transparency)
    love.graphics.polygon("fill", {x - width * 0.5, y - fontSize * 0.2, x + width * 0.5, y - fontSize * 0.2, x + width * 0.5, y + fontSize * 1.2, x - width * 0.5, y + fontSize * 1.2})
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(addText..metric, x - width * 0.5, y, width, align)
    love.graphics.setColor(r, g, b, a)
end