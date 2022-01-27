---------------------------
    -- ESX --
---------------------------
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
---------------------------
    -- Event Handlers --
---------------------------
local inDragStrip = {}
RegisterServerEvent('vinDragStrip:sv_JoinDragRace')
AddEventHandler('vinDragStrip:sv_JoinDragRace', function(raceId)
    local src = source

    if #inDragStrip >= Config.DragStrip[2]["JoinRace"].maxplayers then
        TriggerClientEvent('mythic_notify:client:SendAlert', src, {type = "error", text = "There is already an ongoing race!"})
        return
    end

    local linepos = 1
    local dragRace = {DragRace = raceId, [raceId] = {playerId = src}}
    table.insert(inDragStrip, dragRace)

    for i=1, #inDragStrip do
        if inDragStrip[i].DragRace == raceId then
            TriggerClientEvent('vinDragStrip:cl_JoinDragRace', inDragStrip[i][raceId].playerId, raceId, linepos)
            linepos = linepos + 1
        end
    end
    
    if #inDragStrip == Config.DragStrip[2]["JoinRace"].maxplayers then
        TriggerClientEvent('vinDragStrip:cl_StartDragRace', -1, raceId)
        linepos = 1
    end
end)

RegisterServerEvent('vinDragStrip:sv_RaceFinished')
AddEventHandler('vinDragStrip:sv_RaceFinished', function(dragRaceId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer ~= nil then
        TriggerClientEvent('vinDragStrip:cl_RaceFinished', -1, dragRaceId, xPlayer.getName())
        endDragRace(dragRaceId)
    end
end)

RegisterServerEvent('vinDragStrip:sv_EndRaceEarly')
AddEventHandler('vinDragStrip:sv_EndRaceEarly', function(dragRaceId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer ~= nil then
        TriggerClientEvent('vinDragStrip:cl_EndRaceEarly', -1, dragRaceId, xPlayer.getName())
        endDragRace(dragRaceId)
    end
end)

endDragRace = function(dragRaceId)
    for i=1, #inDragStrip do
        if inDragStrip[i].DragRace == dragRaceId then
            inDragStrip = {}
        end
        break
    end
end