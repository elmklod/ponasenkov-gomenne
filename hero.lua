Actor = {}

function Actor:initializeNew(world, w, h, rw, ch)

    local o = {}

    local r = rw / 2
    local rh = ch - r

    o.bullets = {}
    o.width = rw
    o.height = ch
    o.worldWidth = w
    o.worldHeight = h
    o.normalY = (h - ch) / 2

    o.body= love.physics.newBody(world, w/2, h/2 - ((rh + r)/2), "dynamic")
    o.body:setFixedRotation(true)
    o.shapeUpper = love.physics.newRectangleShape(0, -r/2, rw, rh)
    o.facePosition = ((math.random(2) == 1) and "right") or "left"

    o.shapeLower = love.physics.newCircleShape(0, (rh - r)/2, r)

    o.fixtureUpper = love.physics.newFixture(o.body, o.shapeUpper, 0)
    o.fixtureLower = love.physics.newFixture(o.body, o.shapeLower, 3)
    o.fixtureUpper:setUserData("actorUp")
    o.fixtureLower:setUserData("actorDown")
    o.body:setUserData(o)

    setmetatable(o, self)
    self.__index = self

    return o
end

Actor.color = {0.666, 0.777, 0.888, 1}

Actor.health = 500
Actor.ammoAmount = 200
Actor.speed = 150
Actor.yVel = 0
Actor.xVel = 0
Actor.state = "alive"

function Actor:healthUp(hp)
    self.health = math.min(Actor.health, self.health + hp)
end

function Actor:ammoUp(ammos)
    self.ammoAmount = math.min(Actor.ammoAmount, self.ammoAmount + ammos)
end

function Actor:render()
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

function Actor:ammo()
    local i = 0
    local n = #self.bullets
    return function ()
             i = i + 1
             if i <= n then return self.bullets[i] end
            end
end

function Actor:resetXVel()
    self.xVel = 0
end

function Actor:resetYVel()
    self.yVel = 0
end

function Actor:move()
    if self.state == "alive" then
        local vx, vy = self.body:getLinearVelocity()
        local vel
    
        if self.yVel == 0 then
            vel = vy
        else
            vel = self.yVel
        end

        self.body:setLinearVelocity(self.xVel, vel)
    end
end

function Actor:applyYVel()
    if not sounds["character_jump"]:isPlaying() then
        self.yVel = -self.speed
        sounds["character_jump"]:play()
    end
end

function Actor:applyXVel(pos)
    if pos == 'left' then
        self.facePosition = 'left'
        self.xVel = -self.speed
    elseif pos == "right" then
        self.facePosition = 'right'
        self.xVel = self.speed
    end
end

function Actor:shoot()
    if self.ammoAmount > 0 and (not sounds["bullet_shot"]:isPlaying()) then
        local x, y = self.body:getWorldCenter()
        table.insert(self.bullets, Bullet:initializeNew(self.body:getWorld(), self.worldWidth, self.worldHeight, self.width, x, y, self.facePosition))
        self.ammoAmount = self.ammoAmount - 1
        sounds["bullet_shot"]:play()
    end
end

function Actor:takeHit(enemy)
    local ax, ay = self.body:getWorldCenter()
    local ex, ey = enemy.body:getWorldCenter()
    --local kx, ky
    local dx, dy
    local vecx, vecy, veclen
    local sina, cosa
    local randomx = 0
    local fmod = 1000000000

    self.health = self.health - enemy.damage

    if self.health <= 0 then
        self.state = "dead"
        self.body:destroy()
        sounds["character_killed"]:play()
        game:changeState("defeat")
    else
        dx = ax - ex
        dy = self.normalY - enemy.normalY
        if dx == 0 then
            randomx = ((math.random(2) == 1) and -0.3) or 0.3
        end

        --[[if dx < 0 then
            kx = -1
        elseif dx > 0 then
            kx = 1
        else
            kx = ((math.random(2) == 1) and -0.3) or 0.3
        end

        if dy < enemy.standardDY then
            ky = -1
        elseif dy > enemy.standardDY then
            ky = 1
        else
            ky = 0
        end
        ]]

        vecx = dx
        vecy = dy - enemy.standardDY

        veclen = math.sqrt(vecx*vecx + vecy*vecy)
        sina = vecy/veclen
        cosa = vecx/veclen

        self.body:applyForce((cosa + randomx)*fmod, sina*fmod)
    end
end