Ship = {}
Ship.__index = Ship

function Ship:create(x, y)
    local ship = {}
    setmetatable(ship, Ship)
    return ship
end