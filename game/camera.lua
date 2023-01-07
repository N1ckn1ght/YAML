Camera = {}
Camera.__index = Camera

function Camera:create(width, height, track, borders)
    local camera = {}
    setmetatable(camera, Camera)
    camera.width     = width
    camera.height    = height
    camera.track     = track
    camera.borders   = borders
    camera.location  = Vector:create(track.location.x - width * 0.5, track.location.y - height * 0.5)
    camera.scaleX    = Width / width
    camera.scaleY    = Height / height
    return camera
end

function Camera:update()
    if (self.location.x > self.track.location.x - self.borders[1]) then
        self.location.x = self.track.location.x - self.borders[1]
    elseif (self.location.x < self.track.location.x - self.width + self.borders[3]) then
        self.location.x = self.track.location.x - self.width + self.borders[3]
    end
    if (self.location.y > self.track.location.y - self.borders[2]) then
        self.location.y = self.track.location.y - self.borders[2]
    elseif (self.location.y < self.track.location.y - self.height + self.borders[4]) then
        self.location.y = self.track.location.y - self.height + self.borders[4]
    end
end

function Camera:center()
    self.location = Vector:create(self.track.location.x - self.width * 0.5, self.track.location.y - self.height * 0.5)
end

function Camera:saveRelativePosition()
    self.savedRelativePosition = Vector:create(self.location.x - self.track.location.x, self.location.y - self.track.location.y)
end

function Camera:loadRelativePosition()
    self.location = Vector:create(self.savedRelativePosition.x + self.track.location.x, self.savedRelativePosition.y + self.track.location.y)
end