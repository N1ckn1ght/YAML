Terrain = {}
Terrain.__index = Terrain

function Terrain:create(x, y, width, height, angleDiffLimit, minLengthX, maxLenghtX, minLengthOfLandable, dangerousLengthOfLandable, angleOfLandable, angleOfFlattening, tryGenerateGuaranteed)
    local terrain = {}
    setmetatable(terrain, Terrain)
    terrain.x = x
    terrain.y = y
    terrain.width = width
    terrain.height = height
    terrain.angleDiffLimit = angleDiffLimit
    terrain.minLengthX = minLengthX
    terrain.maxLengthX = maxLenghtX
    terrain.minLengthOfLandable = minLengthOfLandable
    terrain.dangerousLengthOfLandable = dangerousLengthOfLandable
    terrain.angleOfLandable = angleOfLandable
    terrain.angleOfFlattening = angleOfFlattening
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
        local x = math.random()^2 * length + self.minLengthX
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

    -- dangerous hotfix, but it's necessary to know which are "guaranteed" to possible landing (Issue 4)
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
        elseif (gSegments[i]) then
            minAngleY = math.max(math.atan2( self.y                - previousPoint.y, tempSegmentLengths[i]), -self.angleOfLandable)
            maxAngleY = math.min(math.atan2((self.y + self.height) - previousPoint.y, tempSegmentLengths[i]), self.angleOfLandable)
            randRange = -minAngleY + maxAngleY
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
                print("     : SoT generation success (ignoring angleOfLandable for this segment)")
            end
        end

        -- Generate random angle with known boundaries
        local angle = math.random() * randRange + minAngleY
        if (angle > -self.angleOfLandable) then
            angle = angle + fairRange
        end
        if (angle >= -self.angleOfFlattening and angle <= self.angleOfFlattening) then
            angle = 0
        end
        if (angle >= -self.angleOfLandable and angle <= self.angleOfLandable) then
            gSegments[i] = true
            if (gSegments[i - 1]) then
                print("WARN : Bad generation at segment", i, "two landables in a row?")
            end
        else
            gSegments[i] = false
        end
        
        -- Finally, convert angle to vector
        local dy = math.sin(angle) * tempSegmentLengths[i]
        self.segments[i] = Segment:create(Vector:create(previousPoint.x, previousPoint.y), Vector:create(previousPoint.x + tempSegmentLengths[i], previousPoint.y + dy))

        -- Prepare next cycle
        previousPoint.x = previousPoint.x + tempSegmentLengths[i]
        previousPoint.y = previousPoint.y + dy
        previousAngle = angle
    end
    -- hotfix to make connected vertices between last and first (this leads to Issue 1)
    self.segments[#tempSegmentLengths] = Segment:create(Vector:create(previousPoint.x, previousPoint.y), Vector:create(previousPoint.x + tempSegmentLengths[#tempSegmentLengths], self.segments[1].p1.y))

    -- set scores for platforms
    for i = 1, #self.segments do
        local prev = (i - 2) % #self.segments + 1
        local next = (i    ) % #self.segments + 1
        local score = 0
        if (gSegments[i]) then
            score = 1
            if (self.segments[prev].heading > 0 and self.segments[next].heading < 0) then
                score = score * 1.5
            end
            if (self.segments[i].p2.x - self.segments[i].p1.x <= self.dangerousLengthOfLandable) then
                score = score * 1.5
            end
            if (math.abs(self.segments[i].heading) > self.angleOfFlattening) then
                score = score * 1.5
            end
            self.segments[i]:setScore(score)
        end
    end
end

function Terrain:draw(offsetX, offsetY, scaleX, scaleY)
    -- find current segment
    local nearest = self:findNearestSegment(offsetX)

    -- draw [current; maximum to right]
    local current = nearest
    local m = 0
    while ((self.segments[current].p1.x + self.width * m) * scaleX < -offsetX * scaleX + Width) do
        self.segments[current]:draw(offsetX + self.width * m, offsetY, scaleX, scaleY)
        current = current + 1
        if (current > #self.segments) then
            current = 1
            m = m + 1
        end
    end

    -- draw [maximum to left; current)
    current = nearest - 1
    m = 0
    if (current == 0) then
        current = #self.segments
        m = -1
    end
    while ((self.segments[current].p2.x + self.width * m) * scaleX > -offsetX * scaleX - Width) do
        self.segments[current]:draw(offsetX + self.width * m, offsetY, scaleX, scaleY)
        current = current - 1
        if (current < 1) then
            current = #self.segments
            m = m - 1
        end
    end
end

-- Will return index of a closest of segments to given x by p1
function Terrain:findNearestSegment(x, center)
    center = center or false
    -- failsafe
    if (x < self.x) then
        return 1
    elseif (x > self.segments[#self.segments].p1.x) then
        return #self.segments
    end
    -- binary search
    local iMin = 1
    local iMax = #self.segments

    local add = 0

    while (iMin <= iMax) do
        local iMid = math.floor((iMin + iMax) / 2)

        if (center) then
            add = self.segments[iMid].p2.x - self.segments[iMid].p1.x
        end

        if (self.segments[iMid].p1.x + add > x) then
            iMax = iMid - 1
        elseif (self.segments[iMid].p1.x + add < x) then
            iMin = iMid + 1
        else
            return iMid
        end
    end
    -- iMin = iMax + 1 after cycling

    -- failsafe 2
    if (iMax< 1) then
        return 1
    elseif (iMin > #self.segments) then
        return #self.segments
    end

    local addMin = 0
    local addMax = 0
    if (center) then
        addMin = self.segments[iMin].p2.x - self.segments[iMin].p1.x
        addMax = self.segments[iMax].p2.x - self.segments[iMax].p1.x
    end

    if (x - self.segments[iMax].p1.x + addMax < self.segments[iMin].p1.x + addMin - x) then
        return iMax
    else
        return iMin
    end
end