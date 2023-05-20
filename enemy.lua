Enemy = {}

Enemy.color = {0.8, 0.1, 0.05, 1}
Enemy.health = 200
Enemy.speed = 60
Enemy.detectionRange = 200
Enemy.chasing = false
Enemy.state = "alive"
Enemy.damage = 30

function Enemy:initializeNew(world, w, h, ew, eh, pw, pos, hero)
    local o = {}
    local k
    local r = ew / 2
    local rh = eh - r
    local start

    o.platformLeftBorder = (w - pw)/2
    o.platformRightBorder = (w - o.platformLeftBorder)

    if pos == "left" then
        k = 1
        start = o.platformLeftBorder
    else
        k = -1
        start = o.platformRightBorder
    end

    o.worldWidth = w
    o.worldHeight = h
    o.normalY = (h - eh) / 2
    o.leftLimit = o.platformLeftBorder + r
    o.rightLimit = o.platformRightBorder - r
    o.yRestore = h/2 - ((rh + r)/2)
    o.body = love.physics.newBody(world, start + (k * ew/2), h/2 - ((rh + r)/2), "dynamic")
    o.body:setFixedRotation(true)
    o.shapeUpper = love.physics.newRectangleShape(0, -r/2, ew, rh)
    o.shapeLower = love.physics.newCircleShape(0, (rh - r)/2, r)
    o.fixtureUpper = love.physics.newFixture(o.body, o.shapeUpper, 0)
    o.fixtureLower = love.physics.newFixture(o.body, o.shapeLower, 3)
    o.fixtureUpper:setUserData("enemyUp")
    o.fixtureLower:setUserData("enemyDown")
    o.face = ((math.random(2) == 1) and "right") or "left"
    o.stepCount = math.random(100, 200)
    o.body:setUserData(o)
    o.standardDY = hero.normalY - ((h - eh)/2)

    setmetatable(o, self)
    self.__index = self
    return o
end

function Enemy:render()
    if self.state == "alive" then
        love.graphics.setColor(self.color)
        local cx, cy = self.body:getWorldPoint(self.shapeLower:getPoint())
        love.graphics.polygon("fill", self.body:getWorldPoints(self.shapeUpper:getPoints()))
        love.graphics.circle("fill",  cx, cy, self.shapeLower:getRadius())
    elseif self.state == "dead" then
        self.shapeUpper:release()
        self.shapeLower:release()
        self.state = "destroyed"
    end
end

function Enemy:move(dt, chState, cx, cy)
    local k
    local vel
    local pos

    if self.state == "alive" then

        local ex, ey = self.body:getWorldCenter()

        if (math.abs(cx - ex) <= self.detectionRange) and chState == "alive" then
            if not self.chasing then
                self.stepCount = math.random(100, 200)
                self.chasing = true
            end

            if cx < ex then
                k = -1
            elseif cx > ex then
                k = 1
            else
                k = 0
            end
        else
            if self.chasing then
                self.chasing = false
            end

            if self.stepCount == 0 then
                if self.face == "right" then
                    self.face = 'left'
                elseif self.face == 'left' then
                    self.face = 'right'
                end
                self.stepCount = math.random(100, 200)
            end

            if self.face == "right" then
                k = 1
            elseif self.face == 'left' then
                k = -1
            end
        end

        vel = k * self.speed
        pos = ex + vel*dt

        if pos > self.rightLimit then
            vel = (self.rightLimit - ex) / dt
        elseif pos < self.leftLimit then
            vel = (self.leftLimit - ex) / dt
        end

        self.body:setLinearVelocity(vel, 0)
        if not self.chasing then
            self.stepCount = self.stepCount - 1
        end
    end
end

function Enemy:takeHit(dmg)
    self.health = self.health - dmg
    if self.health <= 0 then
        local world = self.body:getWorld()
        local x, y = self.body:getWorldCenter()
        self.body:destroy()
        self.world = world
        self.deathXPosition = x
        self.deathYPosition = y
        self.state = "deat_and_should_drop"
        sounds["enemy_killed"]:play()
    end
end

function Enemy:drop()
    if self.state == "deat_and_should_drop" then
        self.state = "dead"
        drops:addNew(self.world, self.worldWidth, self.worldHeight, self.deathXPosition, self.deathYPosition)
    end
end

--[[
function Enemy:preventFall()
    local ex, ey = self.body:getWorldCenter()
    local pos = ex

    if ex < self.leftLimit then
        pos = self.leftLimit
    elseif ex > self.rightLimit then
        pos = self.rightLimit
    end

    self.body:setPosition(pos, self.yRestore)
end
]]
