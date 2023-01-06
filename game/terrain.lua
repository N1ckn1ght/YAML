Terrain = {}
Terrain.__index = Terrain

function Terrain:create(x, y, width, height, angleDiffLimit, minLengthX, maxLenghtX, angleOfLandable, angleOfSmoothering, tryGenerateGuaranteed)
    local terrain = {}
    setmetatable(terrain, Terrain)
    terrain.x = x
    terrain.y = y
    terrain.width = width
    terrain.height = height
    -- Issue 1: due to realisation of terrain gen there probably will be a case of
    --          generating off-limit angle spike between last and first terrain vertice;
    terrain.angleDiffLimit = angleDiffLimit
    -- Issue 2: generating off-minimum-limit by X segment at the end of the terrain.
    terrain.minLengthX = minLengthX
    terrain.maxLengthX = maxLenghtX
    terrain.angleOfLandable = angleOfLandable
    terrain.angleOfSmoothering = angleOfSmoothering
    -- Format: {{length by x, amount}, ...}
    terrain.guaranteed = tryGenerateGuaranteed
    terrain.segments = {}
    terrain:init()
    return terrain
end

function Terrain:init()
    -- I. Generate terrain by X

    -- but disinclude width of self.guaranteed platforms ('fair' width)
    local randomWidth = self.width
    for i = 1, #self.guaranteed do
        randomWidth = randomWidth - self.guaranteed[i][1] * self.guaranteed[i][2]
    end

    local length = self.maxLengthX - self.minLengthX
    local currentWidth = 0
    local tempSegmentLengths = {}
    while (currentWidth < randomWidth) do
        local x = math.random() * length + self.minLengthX
        tempSegmentLengths[#tempSegmentLengths + 1] = x
        currentWidth = currentWidth + x
    end
    -- hotfix for getting out of bounds by x (this leads to Issue 2)
    local dx = currentWidth - randomWidth
    tempSegmentLengths[#tempSegmentLengths] = tempSegmentLengths[#tempSegmentLengths] - dx    

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

    -- local curX = self.x
    -- for i = 1, #tempSegmentLengths do
    --     local y2 = self.y - 20
    --     self.segments[i] = Segment:create(Vector:create(curX, self.y), Vector:create(curX + tempSegmentLengths[i], y2))
    --     curX = curX + tempSegmentLengths[i]
    --     self.y, y2 = y2, self.y
    -- end

    -- -- dangerous hotfix, but it's necessary to know which are "guaranteed" to possible landing
    -- local gSegments = {}
    -- for i = 1, #tempSegmentLengths do
    --     if (tempSegmentLengths[i] == math.floor(tempSegmentLengths[i])) then
    --         gSegments[i] = true
    --     else
    --         gSegments[i] = false
    --     end
    -- end

    -- -- III. Generate terrain by Y (by complete segments)
    -- gSegments[0] = true
    -- local previousAngle = 0
    -- local previousPoint = Vector:create(self.x, self.y + math.random() * self.height)   
    -- for i = 1, #tempSegmentLengths - 1 do
    --     -- For each segment, calculate boundaries on an angle
    --     local maxAngleY = math.min(math.atan2(previousPoint.y, tempSegmentLengths[i]), previousAngle + self.angleDiffLimit)
    --     local minAngleY = math.max(math.ata2n(self.height - previousPoint.y, tempSegmentLengths[i]), previousAngle - self.angleDiffLimit)
    --     local randRange = -minAngleY + maxAngleY
    --     local fairRange = 0
    --     -- if previous platform was landable, this needs to be not
    --     if (gSegments[i - 1]) then
    --         -- check if maxAngleY or minAngleY overlaps with self.angleOfLandable
    --         local unfairRange = 0
    --         if (maxAngleY > self.angleOfLandable) then
    --             unfairRange = unfairRange + math.max(maxAngleY - self.angleOfLandable, randRange)
    --         end
    --         if (minAngleY < -self.angleOfLandable) then
    --             unfairRange = unfairRange + math.max(minAngleY - self.angleOfLandable, randRange)
    --         end
    --         fairRange = randRange - unfairRange
    --         randRange = unfairRange
    --     end
    --     -- Terrain generator cannot connect two landable platforms :(
    --     -- But it also tries to prevent generation of two in a row (see above)
    --     if (randRange <= 0) then
    --         print("Terrain generation has failed. 'angleOfLandable' is too strict!")
    --     end

    --     -- Generate random angle with known boundaries
    --     local angle = math.random() * randRange + minAngleY
    --     if (angle > -self.angleOfLandable) then
    --         angle = angle + fairRange
    --     end
    --     if (angle >= -self.angleOfLandable and angle <= self.angleOfLandable) then
    --         gSegments[i] = true
    --         angle = math.min(math.max(angle, -self.angleOfSmoothering), self.angleOfSmoothering)
    --     end

    --     -- Finally, convert angle to vector
    --     local dy = math.sin(angle) * tempSegmentLengths[i]
    --     self.segments[i] = Segment:create(Vector:create(previousPoint.x, previousPoint.y), Vector:create(previousPoint.x + tempSegmentLengths[i], previousPoint.y + dy))
    --     if (gSegments[i]) then
    --         self.segments[i].color = {0, 1, 0, 1}
    --     end

    --     -- Prepare next cycle
    --     previousPoint.x = previousPoint.x + tempSegmentLengths[i]
    --     previousPoint.y = previousPoint.y + dy
    --     previousAngle = angle
    -- end
    -- -- hotfix to make connected vertices between last and first (this leads to Issue 1)
    -- self.segments[#tempSegmentLengths] =  Segment:create(Vector:create(previousPoint.x, previousPoint.y), Vector:create(self.segments[1].p1.x, self.segments[1].p1.y))
end

function Terrain:draw(offsetX, offsetY, scaleX, scaleY)
    for i = 1, #self.segments do
        self.segments[i]:draw(offsetX, offsetY, scaleX, scaleY)
    end
end