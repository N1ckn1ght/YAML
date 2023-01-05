Terrain = {}
Terrain.__index = Terrain

function Terrain:create(x, y, width, height, angleDiffLimit, minLengthX, maxLenghtX, guaranteed)
    local terrain = {}
    setmetatable(terrain, Terrain)
    terrain.x = x
    terrain.y = y
    terrain.width = width
    terrain.height = height
    terrain.angleDiffLimit = angleDiffLimit
    -- Warning: due to realisation of terrain gen there probably will be a case of
    --          generating off-minimum-limit by X segment at the end of the terrain
    terrain.minLengthX = minLengthX
    terrain.maxLengthX = maxLenghtX
    terrain.guaranteed = guaranteed
    terrain.segments = {}
    terrain:init()
    return terrain
end

function Terrain:init()
    -- I. Generate terrain by X

    -- but disinclude fair width
    local randomWidth = self.width
    for i = 1, #self.guaranteed do
        randomWidth = randomWidth - self.guaranteed[1] * self.guaranteed[2]
    end

    local length = self.maxLengthX - self.minLengthX
    local currentWidth = 0
    local tempSegmentLengths = {}
    while (currentWidth < self.randomWidth) do
        local x = math.random() * length + self.minLengthX
        tempSegmentLengths[#tempSegmentLengths + 1] = x
        currentWidth = currentWidth + x
    end
    -- hotfix for getting out of bounds by x
    local dx = currentWidth - self.randomWidth
    tempSegmentLengths[#tempSegmentLengths] = x - dx    

    -- II. Set guaranteed platforms to land
    
    local i = 0
    local j = 0
    while (true) do
        if (j == 0) then
            i = i + 1
            if (i <= #self.guaranteed) then
                j = self.guaranteed[i][2]
            else 
                break
            end
        else
            tempSegmentLengths[#tempSegmentLengths + 1] = self.guaranteed[i][1] 
        end
    end
    shuffle(tempSegmentLengths)

    -- III. Generate terrain by Y

    
end