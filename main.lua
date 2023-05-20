w = 1024
h = 720

gw = 800
gh = 100

smallFont = love.graphics.newFont("font.ttf", 16)
largeFont = love.graphics.newFont("font.ttf", 32)
superLargeFont = love.graphics.newFont("font.ttf", 96)

sounds = {
    ["bullet_shot"] = love.audio.newSource("sounds/shot.wav", "static"),
    ["bullet_hit"] = love.audio.newSource("sounds/bullet_hit.wav", "static"),
    ["character_jump"] = love.audio.newSource("sounds/jump.wav", "static"),
    ["enemy_killed"] = love.audio.newSource("sounds/enemy_killed.wav", "static"),
    ["character_killed"] = love.audio.newSource("sounds/character_killed.wav", "static"),
    ["defeat"] = love.audio.newSource("sounds/defeat.mp3", "static"),
    ["play"] = love.audio.newSource("sounds/surf.mp3", "static"),
    ["victory"] = love.audio.newSource("sounds/victory.mp3", "static"),
    ["menu"] = love.audio.newSource("sounds/menu.mp3", "static"),
    ["button_push"] = love.audio.newSource("sounds/button_push.wav", "static"),
    ["drop_pickup"] = love.audio.newSource("sounds/drop_pickup.wav", "static")
}
sounds["play"]:setLooping(true)
sounds["defeat"]:setLooping(true)
sounds["victory"]:setLooping(true)
sounds["menu"]:setLooping(true)

require 'game'
require 'drops'
require 'hero'
require 'enemy'
require 'ground'
require 'bullet'
require 'callbacks'

function love.load()
    love.window.setMode(w, h, {
        fullscreen = false,
        resizable = false,
        vsync = false
    })

    love.physics.setMeter(10)
    generateAll()
end

function generateAll()
    math.randomseed(os.time())
    game:initialize(love.physics.newWorld(0, 10 * 10), sounds)
    drops:initialize()
    game.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    hero = Actor:initializeNew(game.world, w, h, 20, 40)
    ground = Platform:initializeNew(game.world, w, h, gw, gh)
    bastard1 = Enemy:initializeNew(game.world, w, h, 15, 27.5, gw, "left", hero)
    bastard2 = Enemy:initializeNew(game.world, w, h, 10, 15, gw, "right", hero)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == "m" then
        if not (game.state == "menu") then
            game.world:destroy()
            generateAll()
            --game:changeState("menu")
        end
    elseif game.state == "menu" then
        if (key == "enter") or (key == "return") then
            sounds["button_push"]:play()
            game:changeState("play")
        end
    elseif game.state == "play" then
        if key == 'up' then
            hero:applyYVel()
        elseif key == 'right' then
            hero:applyXVel('right')
        elseif key == 'left' then
            hero:applyXVel('left')
        elseif key == 'b' then
            hero:shoot()
        end
    elseif (game.state == "victory") or (game.state == "defeat") then
        game.world:destroy()
        sounds["button_push"]:play()
        sounds[game.state]:stop()
        generateAll()
        game:changeState("play")
    end
end

function love.update(dt)
    if game.state == "play" then
        game.world:update(dt)
        if (((bastard1.state == "alive") or (bastard2.state == "alive")) and hero.state == "alive")  then

            -- bastard1:preventFall()
            -- bastard2:preventFall()

            bastard1:drop()
            bastard2:drop()

            if love.keyboard.isDown('right') or love.keyboard.isDown('left') then
            else
                hero:resetXVel()
            end

            if love.keyboard.isDown('up') then
            else
                hero:resetYVel()
            end

            hero:move()
            --if hero.state == "alive" then
            bastard1:move(dt, hero.state, hero.body:getWorldCenter())
            bastard2:move(dt, hero.state, hero.body:getWorldCenter())
            --else
            --    bastard1:move(dt, hero.state, 0, 0)
            --    bastard2:move(dt, hero.state, 0, 0)
            --end
            for bullet in hero:ammo() do
                bullet:move()
            end
            for drop in drops:all() do
                drop:eradicateIfOutside()
            end
        elseif hero.state == "alive" then
            game:changeState("victory")
        else
            game:changeState('defeat')
        end
    end
end

function love.draw()
    love.graphics.clear(0, 0, 0, 1)
    displayFPS()
    if (game.state == "play") or (game.state == "defeat") then
        hero:render()
        bastard1:render()
        bastard2:render()
        ground:render()
        for bullet in hero:ammo() do
            bullet:render()
        end
        for drop in drops:all() do
            drop:render()
        end
        if game.state == "defeat" then
            displayDefeat()
        end
    elseif game.state == "menu" then
        drawMenu()
    elseif game.state == "victory" then
        displayVictory()
    end
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayVictory()
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(superLargeFont)
    love.graphics.printf("CONGRATULATIONS!", 0, h/2 - 100, w, "center")
end

function displayDefeat()
    love.graphics.setColor(1,0,1,1)
    love.graphics.setFont(largeFont)
    love.graphics.printf("GAME OVER", 0, h/2 - 200, w, 'center')
end

function drawMenu()
    love.graphics.setFont(superLargeFont)
    love.graphics.setColor(1,1,1,1)
    love.graphics.printf(game.name, 0, h/2 - 350, w, "center")
    love.graphics.setLineWidth(7)
    love.graphics.rectangle("line", w/2 - 200, h/2 - 100, 400, 200)
    love.graphics.setLineWidth(1)
    love.graphics.setFont(superLargeFont)
    love.graphics.printf("START", 0, h/2 - 60, w, "center")
end