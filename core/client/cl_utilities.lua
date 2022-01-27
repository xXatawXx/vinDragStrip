---------------------------
    -- Functions --
---------------------------
Utils = {
    loadModel = function(model) -- Load Model function
    while (not HasModelLoaded(model)) do
        RequestModel(model)
    Citizen.Wait(0)
    end
end,
    loadAnimDict = function(dict) -- Load Animation function
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
    Citizen.Wait(0)
    end
end,
    LocalPed = function() -- function returning the playerped
        return PlayerPedId() 
end,
    plyHealth   = function() -- Player Health function
        local plyHealth = (GetEntityHealth(GetPlayerPed(-1)) - 100)
        return plyHealth
end,
    drawNoti = function(txt) -- draw notification function
        SetNotificationTextEntry("STRING")
        AddTextComponentString(txt)
        DrawNotification(false, false)
end,
    PlayAnim = function(ped, ad, anim, ...) -- "..." in the parameter indicate functions that have a variable number of arguments.
        TaskPlayAnim(ped,ad,anim,...)
end,
    Notify = function(type, text) -- mythic notification function.
        exports['mythic_notify']:SendAlert(type, text)
end,
    SpawnObject = function(objname, obj) -- Spawn Object function
        local ped = Utils.LocalPed()
        local x,y,z = table.unpack(GetEntityCoords(ped, true))
        Utils.loadModel(objname)
        local obj = CreateObject(GetHashKey(objname), x, y, z-1.90, true, true, true)
        PlaceObjectOnGroundProperly(obj)
        SetEntityHeading(obj, heading)
        FreezeEntityPosition(obj, true)
end,
    DeleteObject = function(object2) -- Delete Object function
        local object = GetHashKey(object2)
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(), true))
        if DoesObjectOfTypeExistAtCoords(x, y, z, 0.9, object, true) then
            local obj = GetClosestObjectOfType(x, y, z, 0.9, object, false, false, false)
            DeleteObject(obj)
        end
end,
    drawTxt = function(x,y ,width,height,scale, text, r,g,b,a) -- Draw Text function
        SetTextFont(4)
        SetTextProportional(0)
        SetTextScale(scale, scale)
        SetTextColour(r, g, b, a)
        SetTextDropShadow(0, 0, 0, 0,15)
        SetTextEdge(2, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x - width/2, y - height/2)
end,
    Draw3DText = function(x,y,z, text) -- Draw 3D Text function
        local onScreen,_x,_y=World3dToScreen2d(x,y,z)
        local px,py,pz=table.unpack(GetGameplayCamCoords())
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 370
        DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end,
    DrawText3Ds = function(coords, text, scale, color, rect) -- Better Draw GD IN 3D Text function
        local x,y,z = coords.x, coords.y, coords.z
        local onScreen, _x, _y = World3dToScreen2d(x, y, z)
        local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
        color = color
        if not color then
        color = {255, 255, 255, 215}
        end
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextEntry("STRING")
        SetTextCentre(1)
        SetTextColour(color[1], color[2], color[3], color[4])
        AddTextComponentString(text)
        DrawText(_x, _y)
        if rect then
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0150, 0.005 + factor, 0.025, 41, 11, 41, 100)
        end
end,
    GetPlayers = function() -- Get active players within proximity function
        return GetActivePlayers()
end,
    GetClosestPlayer = function() -- Get Closest Player function
        local players = Utils.GetPlayers()
            local closestDistance = -1
            local closestPlayer = -1
            local ply = Utils.LocalPed()
            local plyCoords = GetEntityCoords(ply, 0)
        
            for index,value in ipairs(players) do
                    local target = GetPlayerPed(value)
                    if(target ~= ply) then
                            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
                            local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
                            if(closestDistance == -1 or closestDistance > distance) then
                                    closestPlayer = value
                                    closestDistance = distance
                            end
                    end
            end
            return closestPlayer, closestDistance
end,
    ForwardX = function() -- Forward X function
        return GetEntityForwardX(PlayerPedId())
end,
    ForwardY = function() -- Forward Y function
        return GetEntityForwardY(PlayerPedId())
end,
    AttachEntity = function(entity,rotation) -- Attach Entity function
        AttachEntityToEntity(entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, rotation or 0.0, true, true, true, false, 0.0, false)
end,
    AddBlip = function(coords, sprite, colour, scale, label) -- Create Blip function
        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, sprite)
        SetBlipColour(blip, colour)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, scale)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(label)
        EndTextCommandSetBlipName(blip)
        return blip
end,
    CreateMarker = function(coords, rgba, height, scale) -- Create Marker function
        local checkPoint = CreateCheckpoint(45, coords, coords, scale, rgba.red, rgba.green, rgba.blue, rgba.alpha, 0)-- example NetCheckPoint = CreateMarker(bottom, {red = 122, green = 155, blue = 100, alpha = 255}, 0.4, 1.0)
        SetCheckpointCylinderHeight(checkPoint, height, height, scale)
        
        return checkPoint
end,
    format_thousand = function(v) -- Comma Value function
        local s = string.format("%d", math.floor(v))
        local pos = string.len(s) % 3
        if pos == 0 then pos = 2 end
        return string.sub(s, 1, pos)
                .. string.gsub(string.sub(s, pos + 1), "(...)", ".%1")
end,
    RotationToDirection = function(rot) -- Rotation to Direction function
        local Adjustment =
        {
            x = (math.pi / 180) * rot.x,
            y = (math.pi / 180) * rot.y,
            z = (math.pi / 180) * rot.z
        }
        local Direction =
        {
            x = -math.sin(Adjustment.z) * math.abs(math.cos(Adjustment.x)),
            y = math.cos(Adjustment.z) * math.abs(math.cos(Adjustment.x)),
            z = math.sin(Adjustment.x)
        }
        return Direction
end,
    RayCastGamePlayCamera = function(dist) -- Raycast Gameplay Camera function
        local Rotation = GetGameplayCamRot()
        local Cam = GetGameplayCamCoord()
        local Dir = Utils.RotationToDirection(Rotation)
        local Des = 
        {
            x = Cam.x + Dir.x * dist,
            y = Cam.y + Dir.y * dist,
            z = Cam.z + Dir.z * dist
        }
        local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(Cam.x, Cam.y, Cam.z, Des.x, Des.y, Des.z, -1, -1, 1))
        return b, c, e, Des
end,
    Distance = function(first, second) -- Distance between function
        local distance = #(first - second)
        return distance
end,
}