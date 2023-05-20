Bullet = {}

Bullet.color = {1, 1, 0, 1}
Bullet.damage = 20
Bullet.speed = 300
Bullet.width = 10
Bullet.height = 4

function Bullet:initializeNew(world, ww, wh, cw, cx, cy, pos)
    local o = {}
    local k
    if pos == "left" then
        o.velocity = -self.speed
        k = -1
    else
        o.velocity = self.speed
        k = 1
    end

    o.body = love.physics.newBody(world, cx + (k*(cw + self.width + 16)/2), cy, "kinematic")
    o.body:setFixedRotation(true)
    o.shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
    o.fixture = love.physics.newFixture(o.body, o.shape, 0)
    o.fixture:setUserData("bullet")
    o.body:setBullet(true)
    o.state = "in game"
    o.body:setLinearVelocity(o.velocity, 0)
    o.rightBorder = ww + (self.width / 2)
    o.leftBorder = 0 - (self.width / 2)
    o.topBorder = 0 - (self.height / 2)
    o.bottomBorder = wh + (self.height / 2)
    o.body:setUserData(o)

    setmetatable(o, self)
    self.__index = self
    return o
end

function Bullet:move()
    if self.state == "in game" then
        local x, y = self.body:getWorldCenter()
        if (x > self.rightBorder) or (x < self.leftBorder) or (y < self.topBorder) or (y > self.bottomBorder) then
            self.state = "removed from game"
            self.body:destroy()
            self.shape:release()
        end
    end
end

function Bullet:render()
    if self.state == "in game" then
        love.graphics.setColor(self.color)
        love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    elseif self.state == "hit" then
        self.shape:release()
        self.state = "removed from game"
    end
end

function Bullet:hit()
    self.state = "hit"
    self.body:destroy()
    if not sounds["bullet_hit"]:isPlaying() then
        sounds["bullet_hit"]:play()
    end
end