Terrain = {}
Terrain.__index = Terrain

function Terrain:create(x, y, width, height, angleDiffLimit, minLengthX, maxLenghtX, minLengthOfLandable, angleOfLandable, angleOfSmoothering, tryGenerateGuaranteed)
    local terrain = {}
    setmetatable(terrain, Terrain)
    terrain.x = x
    terrain.y = y
    terrain.width = width
    terrain.height = height
    -- Issue 1: due to realisation of terrain gen there probably will be a case of
    --          generating off-limit angle spike between last and first terrain vertice;
    -- Issue 3: there may be spikes in some cases (see Step III. Generate terrain by Y)
    terrain.angleDiffLimit = angleDiffLimit
    -- Issue 2: generating off-minimum-limit by X segment at the end of the terrain.
    terrain.minLengthX = minLengthX
    terrain.maxLengthX = maxLenghtX
    -- Todo: implement
    terrain.minLengthOfLandable = minLengthOfLandable
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
    local breakCondition = true
    while (breakCondition) do
        if (j == 0) then
            i = i + 1
            if (i <= #self.guaranteed) then
                j = self.guaranteed[i][2]
            else 
                breakCondition = false
            end
        else
            j = j - 1
            tempSegmentLengths[#tempSegmentLengths + 1] = self.guaranteed[i][1] 
        end
    end
    shuffle(tempSegmentLengths)

    -- dangerous hotfix, but it's necessary to know which are "guaranteed" to possible landing
    local gSegments = {}
    for i = 1, #tempSegmentLengths do
        if (tempSegmentLengths[i] == math.floor(tempSegmentLengths[i])) then
            gSegments[i] = true
        else
            gSegments[i] = false
        end
    end

    -- III. Generate terrain by Y (by complete segments)
    -- todo: fix microspikes
    gSegments[0] = true
    local previousAngle = 0
    local previousPoint = Vector:create(self.x, self.y + math.random() * self.height)
    for i = 1, #tempSegmentLengths - 1 do
        -- For each segment, calculate boundaries on an angle
        local minAngleY = math.max(math.atan2( self.y                - previousPoint.y, tempSegmentLengths[i]), previousAngle - self.angleDiffLimit)
        local maxAngleY = math.min(math.atan2((self.y + self.height) - previousPoint.y, tempSegmentLengths[i]), previousAngle + self.angleDiffLimit)
        -- There might be a case when it's necessary to break the angle since it can't be put into boundaries (Issue 3)
        local randRange = -minAngleY + maxAngleY
        local fairRange = 0
        -- if previous platform was landable, this needs to be not | same if length is too low
        if (gSegments[i - 1] or tempSegmentLengths[i] < self.minLengthOfLandable) then
            -- check if maxAngleY or minAngleY overlaps with self.angleOfLandable
            local unfairRange = 0
            if (maxAngleY > self.angleOfLandable) then
                unfairRange = math.min(unfairRange + maxAngleY - self.angleOfLandable, randRange)
            end
            if (minAngleY < -self.angleOfLandable) then
                unfairRange = math.min(unfairRange - minAngleY - self.angleOfLandable, randRange)
            end
            fairRange = randRange - unfairRange
            randRange = unfairRange
        end
        -- Terrain generator cannot connect two landable platforms :(
        -- But it also tries to prevent generation of two in a row (see above; also Issue 3)
        if (randRange <= 0) then
            print("WARN : Segment", i, "angle random range is less or equal to 0")
            print("     : randRange", randRange, "fairRange", fairRange)
            print("     : minAngleY", minAngleY, "maxAngleY", maxAngleY)
            print("     : previousAngle", previousAngle, "previousPoint.y", previousPoint.y)

            -- Copy-paste but ignoring angleDiffLimit boundary
            minAngleY = math.atan2( self.y                - previousPoint.y, tempSegmentLengths[i])
            maxAngleY = math.atan2((self.y + self.height) - previousPoint.y, tempSegmentLengths[i])
            randRange = -minAngleY + maxAngleY
            fairRange = 0
            if (gSegments[i - 1] or tempSegmentLengths[i] < self.minLengthOfLandable) then
                local unfairRange = 0
                if (maxAngleY > self.angleOfLandable) then
                    unfairRange = math.min(unfairRange + maxAngleY - self.angleOfLandable, randRange)
                end
                if (minAngleY < -self.angleOfLandable) then
                    unfairRange = math.min(unfairRange - minAngleY - self.angleOfLandable, randRange)
                end
                fairRange = randRange - unfairRange
                randRange = unfairRange
            end

            if (randRange <= 0) then
                print("ERROR: Fatal Terrain generation error, angleOfLandable and/or height are too strict!")
            else
                print("INFO : SoT generation success (ignoring angleOfLandable for this segment)")
            end
        end

        -- Generate random angle with known boundaries
        local angle = math.random() * randRange + minAngleY
        if (angle > -self.angleOfLandable) then
            angle = angle + fairRange
        end

        if (angle >= -self.angleOfLandable and angle <= self.angleOfLandable) then
            gSegments[i] = true
            angle = math.min(math.max(angle, -self.angleOfSmoothering), self.angleOfSmoothering)
        else
            gSegments[i] = false
        end
        
        -- Finally, convert angle to vector
        local dy = math.sin(angle) * tempSegmentLengths[i]
        self.segments[i] = Segment:create(Vector:create(previousPoint.x, previousPoint.y), Vector:create(previousPoint.x + tempSegmentLengths[i], previousPoint.y + dy))
        if (gSegments[i]) then
            self.segments[i].color = {1, 0, 0, 1}
        end

        -- Prepare next cycle
        previousPoint.x = previousPoint.x + tempSegmentLengths[i]
        previousPoint.y = previousPoint.y + dy
        previousAngle = angle
    end
    -- hotfix to make connected vertices between last and first (this leads to Issue 1)
    self.segments[#tempSegmentLengths] = Segment:create(Vector:create(previousPoint.x, previousPoint.y), Vector:create(previousPoint.x + tempSegmentLengths[#tempSegmentLengths], self.segments[1].p1.y))

    -- debug
    for i = 1, #self.segments do
        local diffX = self.segments[i].p2.x - self.segments[i].p1.x
        local diffY = self.segments[i].p2.y - self.segments[i].p1.y
        if (diffX < self.minLengthOfLandable and math.abs(math.atan2(diffY, diffX)) < self.angleOfLandable) then
            self.segments[i].color = {1, 1, 1, 1}
            print("WARN : Segment", i, "is marked as landable but has length less then minLengthOfLandable")
            print("     : angle", math.atan2(diffY, diffX), "length", diffX)
            print("INFO : Segment set as NOT possible to land on.")
            print("     : Mathematical error:", math.abs(self.angleOfLandable - math.abs(math.atan2(diffY, diffX))))
        end
    end
end

function Terrain:draw(offsetX, offsetY, scaleX, scaleY)
    -- local i = 1
    -- local m = 0
    -- local currX = self.segments[i].p1.x
    -- while (currX < Width * scaleX + offsetX) do
    --     self.segments[i]:draw(offsetX + self.width * m, offsetY, scaleX, scaleY)
    --     i = i + 1
    --     if (i > #self.segments) then
    --         i = 1
    --         m = m + 1
    --     end
    --     currX = self.segments[i].p1.x + self.width * m
    -- end
    -- i = #self.segments
    -- m = -1
    -- currX = self.segments[i].p2.x - self.width
    -- while (currX > -offsetX) do
    --     self.segments[i]:draw(offsetX + self.width * m, offsetY, scaleX, scaleY)
    --     i = i - 1
    --     if (i < 1) then
    --         i = #self.segments
    --         m = m - 1
    --     end
    --     currX = self.segments[i].p2.x + self.width * m
    -- end
    
end