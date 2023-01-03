Collider = {}
Collider.__index = Collider

function Collider:create(x, y)
    local collider = {}
    setmetatable(collider, Collider)
    return collider
end