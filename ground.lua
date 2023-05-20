Platform = {}

function Platform:initializeNew(world, w, h, wsize, hsize)
    local o = {}

    o.body = love.physics.newBody(world, w/2, (h + hsize)/2, "static")
    o.shape = love.physics.newRectangleShape(0, 0, wsize, hsize)
    o.fixture = love.physics.newFixture(o.body, o.shape, 0)
    --o.fixture:setUserData("platform")

    setmetatable(o, self)
    self.__index = self

    return o
end

Platform.color = {0.66, 0, 0.70, 1}

function Platform:render()
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end