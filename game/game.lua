Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)
    game:init()
    return game
end

function Game:init()
    self.ship = Ship:create(1000, 150, 3.4, 27, 2, 1000, 28)
    self.ship.velocity.x = 100
    self.ship.velocity.y = 0
    self.ship.heading = -math.pi
    self.cameras = {}
    self.cameras[1]   = Camera:create(Width,       Height,       self.ship, {250, 100, 250, 300})
    self.cameras[1].location.y = self.cameras[1].location.y + 200
    self.cameras[2]   = Camera:create(Width * 0.5, Height * 0.5, self.ship, {150, 120, 150, 150})
    self.cameras[3]   = Camera:create(Width * 0.25, Height * 0.25, self.ship, {100, 80, 100, 80})
    self.camera = 1
    -- self.terrain = Terrain:create(0, 200, 6000, 640, 0.6, 0.05, 20, self.ship.size * 2.25, self.ship.size * 4, 0.15, 0.1, {{20, 1}})
    self.terrain = Terrain:create(0, 200, 10000, 640, 0.6, 0.05, 100, self.ship.size * 2.25, self.ship.size * 4, 0.15, 0.1, {{100, 1}})
    self.collider = Collider:create(self, self.ship, self.terrain)
    
    self.nearestSegmentIndex = 1

    self.gravity = 7.5
    self.friction = 0.06
    self.safeLandingSpeed = 10
    self.safeLandingSlide = 2.49
    self.safeRelativeAngle = 0.075

    self.magnitude = 255
    self.relativeHorizontalSpeed = 255
    self.relativeAngle = 255

    self.state = 1
    self.score = 0
end

function Game:update(dt)
    if (self.state == 1) then
        if (love.keyboard.isDown("w", "up")) then
            self.ship:applyPower()
            if (self.ship.fuel > 0) then
                love.audio.play(SoundEngineUp)
            else
                love.audio.stop(SoundEngineUp)
            end
        else
            love.audio.stop(SoundEngineUp)
        end

        local soundAngle = false
        if (love.keyboard.isDown("a", "left")) then
            self.ship:rotate(-dt)
            soundAngle = true
        end
        if (love.keyboard.isDown("d", "right")) then
            self.ship:rotate(dt)
            soundAngle = true
        end
        if (not soundAngle) then
            if (love.keyboard.isDown("q", "left")) then
                self.ship:rotate(-dt * 0.5)
                soundAngle = true
            end
            if (love.keyboard.isDown("e", "right")) then
                self.ship:rotate(dt * 0.5)
                soundAngle = true
            end
        end

        if (soundAngle) then
            love.audio.play(SoundEngineAngle)
        else
            love.audio.stop(SoundEngineAngle)
        end

        local friction = -self.friction * self.ship.velocity.x
        self.ship:applyForce(Vector:create(friction, self.gravity))

        -- debug cheats
        if (love.keyboard.isDown("p")) then
            self.ship.velocity:mul(0)
            self.ship.acceleration:mul(0)
        end
        if (love.keyboard.isDown("[")) then
            self.ship.velocity.x = self.ship.velocity.x - 40
        end
        if (love.keyboard.isDown("]")) then
            self.ship.velocity.x = self.ship.velocity.x + 40
        end
        if (love.keyboard.isDown("\\")) then
            self.ship.velocity.y = self.ship.velocity.y + 20
        end

        self.ship:update(dt)

        self.nearestSegmentIndex = self.terrain:findNearestSegment(self.ship.location.x, true)

        local altitude = self.terrain.segments[self.nearestSegmentIndex].p1.y - self.ship.location.y
        if (altitude < 150) then
            if (altitude < 40) then
                if (self.camera ~= 3) then
                    self.cameras[3]:center()
                    self.camera = 3
                end
                if (self.ship.velocity.y > self.safeLandingSpeed * 2) then
                    love.audio.stop(SoundTerrainApproach)
                    love.audio.play(SoundTerrainDanger)
                else
                    love.audio.stop(SoundTerrainDanger)
                end
            else
                if (self.camera == 1) then
                    self.cameras[2]:center()
                    self.camera = 2
                    love.audio.play(SoundTerrainApproach)
                elseif (altitude > 60) then
                    self.camera = 2
                end
            end
        elseif (altitude > 180) then
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
        self:calculateRelativeData(self.nearestSegmentIndex)
    elseif (not self.ship.isAlive) then
        self.ship:update(dt)
    end
end

function Game:draw()
    local offsetX = -self.cameras[self.camera].location.x
    local offsetY = -self.cameras[self.camera].location.y
    local scaleX  =  self.cameras[self.camera].scaleX
    local scaleY  =  self.cameras[self.camera].scaleY
    self.ship:draw(offsetX, offsetY, scaleX, scaleY)
    self.terrain:draw(offsetX, offsetY, scaleX, scaleY)

    showStat(self.ship.fuel      , 180, 10, 320, FontSize, 0, 0, "FUEL      ", "left")
    showStat(self.ship.location.x, 180, 40, 320, FontSize, 0, 0, "LONGITUDE ", "left")
    showStat(self.ship.location.y, 180, 70, 320, FontSize, 0, 0, "ALTITUDE  ", "left")

    if (self.camera < 3) then
        local angle = self.ship.heading * 180 / math.pi + 90
        showStat(angle,                Width - 150, 10, 320, FontSize, 0, 0, "ANGLE            ", "left")
        showStat(self.ship.velocity.x, Width - 150, 40, 320, FontSize, 0, 0, "HORIZONTAL SPEED ", "left")
        showStat(self.ship.velocity.y, Width - 150, 70, 320, FontSize, 0, 0, "VERTICAL SPEED   ", "left")
    else
        local color = {1, 1, 1, 1}
        if (self.relativeAngle > self.safeRelativeAngle) then
            color = {1, 0, 0, 1}
        end
        showStat(self.relativeAngle * 180 / math.pi, Width - 150, 10, 320, FontSize, 0, 0, "RELATIVE ANGLE   ", "left", color)
        color = {1, 1, 1, 1}
        if (math.abs(self.relativeHorizontalSpeed) > self.safeLandingSlide) then
            color = {1, 0, 0, 1}
        end
        showStat(self.relativeHorizontalSpeed,       Width - 150, 40, 320, FontSize, 0, 0, "SLIDE SPEED      ", "left", color)
        color = {1, 1, 1, 1}
        if (self.magnitude > self.safeLandingSpeed) then
            color = {1, 0, 0, 1}
        end
        showStat(self.magnitude,                     Width - 150, 70, 320, FontSize, 0, 0, "ABSOLUTE SPEED   ", "left", color)
    end
    -- showStat(self.nearestSegmentIndex, 180, 100, 320, FontSize, 0, 0, "SEGMENT           ", "left")

    if (self.state == 0) then
        showStat(self.score, 180, 100, 320, FontSize, 0, 0, "SCORE     ", "left", {1, 0, 1, 1})
    end
end

function Game:onCollision(segments)
    love.audio.stop(SoundTerrainDanger)
    love.audio.stop(SoundEngineAngle)
    love.audio.stop(SoundEngineUp)

    self.state = 0
    for i = 1, #segments do
        print("INFO : Collision confirmed with a segment", segments[i])
    end
    if (#segments > 1) then
        self.ship:crash(self.gravity)
        love.audio.play(SoundExplosion)
        print("INFO : Crash because of a landing on a several segments at a time")
        return
    end
    if (self.terrain.segments[segments[1]].score == 0) then
        self.ship:crash(self.gravity)
        love.audio.play(SoundExplosion)
        print("INFO : Crash because of a landing on a bad platform")
        return
    end

    self:calculateRelativeData(segments[1])
    if (self.magnitude > self.safeLandingSpeed) then
        self.ship:crash(self.gravity)
        love.audio.play(SoundExplosion)
        print("INFO : Crash because of a speed")
        print("INFO : It's", self.magnitude, ", but maximum is", self.safeLandingSpeed)
        return
    end
    if (math.abs(self.relativeHorizontalSpeed) > self.safeLandingSlide) then
        self.ship:crash(self.gravity)
        love.audio.play(SoundExplosion)
        print("INFO : Crash because of a big horizontal slide relative to a landing platform")
        print("INFO : It's", self.relativeHorizontalSpeed, ", but maximum is", self.safeLandingSlide)
        return
    end
    if (self.relativeAngle > self.safeRelativeAngle) then
        self.ship:crash(self.gravity)
        love.audio.play(SoundExplosion)
        print("INFO : Crash because of a too big relative to landing platform ship angle")
        print("INFO : It's", self.relativeAngle, ", but maximum is", self.safeRelativeAngle)
        return
    end

    self.ship.colorIdle = {0, 0, 0, 1}
    self.ship.colorFill = {0, 0, 0, 1}
    self.score = self.terrain.segments[segments[1]].score * self.ship.fuel
end

function Game:calculateRelativeData(nearest)
    local segment = self.terrain.segments[nearest]
    local diffX = segment.p2.x - segment.p1.x
    local diffY = segment.p2.y - segment.p1.y
    local normal  = Vector:create(diffY, -diffX)
    local normalAngle = math.atan2(normal.y, normal.x)
    local segmentAngle = math.atan2(diffY, diffX)

    self.relativeAngle = math.abs(normalAngle - self.ship.heading)
    self.relativeHorizontalSpeed = self.ship.velocity.x * math.cos(segmentAngle) - self.ship.velocity.y * math.sin(segmentAngle)
    self.magnitude = self.ship.velocity:mag()
end