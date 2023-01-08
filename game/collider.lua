Collider = {}
Collider.__index = Collider

function Collider:create(game, ship, terrain)
    local collider = {}
    setmetatable(collider, Collider)

    self.game = game
    self.ship = ship
    self.terrain = terrain

    return collider
end

function Collider:update()
    local buf = self.ship.size * self.ship.k 
    local x = self.ship.location.x - buf
    buf = buf * 2
   
    local m = 0
    if (x < 0) then
        x = x + self.terrain.width
        m = m - 1
    end
    
    local segment = self.terrain:findNearestSegment(x)
    segment = segment - 1
    if (segment < 1) then
        segment = #self.terrain.segments
        m = m - 1
    end

    local startX = self.terrain.segments[segment].p2.x + m * self.terrain.width
    local currX  = startX
    local collisions = {}
    
    local shipNormals = self.ship:getNormals(m * self.terrain.width)

    while (true) do
        local segmentNormals = self.terrain.segments[segment]:getNormals()
        local flag = false
        for _, normals in pairs({shipNormals, segmentNormals}) do
            for i = 1, #normals do 
                local p1, p2 = self.ship:getMinMaxProj(normals[i])
                local q1, q2 = self.terrain.segments[segment]:getMinMaxProj(normals[i])
                if ((p2 < q1) or (q2 < p1)) then
                    flag = true
                    break
                end
            end
            if (flag) then
                break
            end
        end

        if (not flag) then
            collisions[#collisions + 1] = segment
        end
        if (currX - buf > startX) then
            break 
        end
        
        segment = segment + 1
        if (segment > #self.terrain.segments) then
            segment = 1
            m = m + 1
            shipNormals = self.ship:getNormals(m * self.terrain.width)
        end
        currX = self.terrain.segments[segment].p1.x + m * self.terrain.width
    end

    if (#collisions > 0) then
        self.game:onCollision(collisions)
    end
end