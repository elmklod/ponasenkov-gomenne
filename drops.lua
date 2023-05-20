Drop = {}

Drop.health = 20
Drop.ammo = 10
Drop.color = {1, 1, 1, 1}
Drop.dimension = 16

drops = {}

function Drop:initializeNew(world, ww, wh, x, y)
    local o = {}

    o.topBorder = 0 - (self.dimension / 2)
    o.bottomBorder = wh + (self.dimension / 2)
    o.leftBorder = 0 - (self.dimension / 2)
    o.rightBorder = ww + (self.dimension / 2)
    o.body = love.physics.newBody(world, x, y - 20, "dynamic")
    o.shape = love.physics.newRectangleShape(0, 0, self.dimension, self.dimension)
    o.fixture = love.physics.newFixture(o.body, o.shape, 1)
    o.fixture:setUserData("drop")
    o.body:setUserData(o)
    o.type = (math.random(2) == 1 and "health") or "bullets"
    o.state = "in-game"

    setmetatable(o, self)
    self.__index = self
    return o
end

function Drop:render()
    if self.state == "in-game" then
        local x, y = self.body:getWorldCenter()
        love.graphics.setColor(self.color)
        love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
        if self.type == "health" then
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle("fill", x - 4, y - 1, 8, 2)
            love.graphics.rectangle("fill", x - 1, y - 4, 2, 8)
        elseif self.type == "bullets" then
            love.graphics.setColor(1, 1, 0, 1)
            love.graphics.rectangle("fill", x - 5, y - 4, 2, 8)
            love.graphics.rectangle("fill", x - 1, y - 4, 2, 8)
            love.graphics.rectangle("fill", x + 3, y - 4, 2, 8)
        end
    elseif self.state == "removed" then
        self.shape:release()
        self.state = "destroyed"
    end
end

function Drop:getCollected(character)
    self.body:destroy()
    self.state = "removed"
    if not sounds["drop_pickup"]:isPlaying() then
        sounds["drop_pickup"]:play()
    end

    if self.type == "health" then
        character:healthUp(self.health)
    elseif self.type == "bullets" then
        character:ammoUp(self.ammo)
    end
end

function Drop:eradicateIfOutside()
    if self.state == "in-game" then
        local x, y = self.body:getWorldCenter()
        if (x > self.rightBorder) or (x < self.leftBorder) or (y < self.topBorder) or (y > self.bottomBorder) then
            self.body:destroy()
            self.shape:release()
            self.state = "destroyed"
        end
    end
end

function drops:initialize()
    self.stuff = {}
end

function drops:all()
    local i = 0
    local n = #self.stuff

    return function ()
             i = i + 1
             if i <= n then return self.stuff[i] end
            end
end

function drops:addNew(world, ww, wh, x, y)
    table.insert(drops.stuff, Drop:initializeNew(world, ww, wh, x, y))
end