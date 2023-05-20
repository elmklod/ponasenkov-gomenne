function beginContact(a, b, coll)
    local f1
    local f2
    local f1Data
    local f2Data
    local aData = a:getUserData()
    local bData = b:getUserData()
    local f1Body
    local f2Body
    local f1Object
    local f2Object
    
    if (aData == "bullet") or (aData == "actorUp") or (aData == "actorDown") then
        f1 = a
        f2 = b
    elseif (bData == "bullet") or (bData == "actorUp") or (bData == "actorDown") then
        f1 = b
        f2 = a
    else
        f1 = a
        f2 = b
    end

    f1Data = f1:getUserData()
    f2Data = f2:getUserData()

    if f1Data == "bullet" then
        f1Body = f1:getBody()
        f1Object = f1Body:getUserData()
        --if f2Data == "platform" then
        --    f1Object:hit()
        if (f2Data == "enemyUp") or (f2Data == "enemyDown") then
            f1Object:hit()

            f2Body = f2:getBody()
            f2Object = f2Body:getUserData()
            f2Object:takeHit(f1Object.damage)
        end
    elseif (f1Data == "actorUp") or (f1Data == "actorDown") then
        f1Body = f1:getBody()
        f1Object = f1Body:getUserData()
        if (f2Data == "enemyUp") or (f2Data == "enemyDown") then
            f2Body = f2:getBody()
            f2Object = f2Body:getUserData()
            f1Object:takeHit(f2Object)
        elseif f2Data == "drop" then
            f2Body = f2:getBody()
            f2Object = f2Body:getUserData()
            f2Object:getCollected(f1Object)
        end
    end
end

function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, nI, tI)
end