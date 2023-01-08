require "game.camera"
require "game.collider"
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

    SoundTerrainApproach = love.audio.newSource("sound/terrain_safe.mp3", "static")
    SoundTerrainDanger   = love.audio.newSource("sound/terrain_danger.mp3", "static")
    SoundEngineUp        = love.audio.newSource("sound/travel.mp3", "static")
    SoundEngineAngle     = love.audio.newSource("sound/rotate.mp3", "static")
    SoundExplosion       = love.audio.newSource("sound/explosion.mp3", "static")

    CurrentGame = Game:create()
end

function love.update(dt)
    -- 15 fps min limit (to avoid getting too big delta time when game window is not in focus)
    dt = math.min(dt, 0.067)

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