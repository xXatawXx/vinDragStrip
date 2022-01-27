---------------------------
    -- Variables --
---------------------------
Data = {
    Player = {
        Ped = nil,
        RaceCar = nil,
        DragRaceId = 0,
        StartingRace = false,
        RaceStarted = false,
        LinePosition = nil,
        RaceCountdown = 0,
        DragRaceCP = nil,
        DragRaceData = {}
    },
    Debug = false,
}
---------------------------
    -- Event Handlers --
---------------------------
RegisterNetEvent('vinDragStrip:cl_joinRace')
AddEventHandler('vinDragStrip:cl_joinRace', function(data)
    Data.Player.Ped = PlayerPedId()
    if Data.Player.DragRaceId == 0 then
        if IsPedInAnyVehicle(Data.Player.Ped, false) then
            TriggerServerEvent('vinDragStrip:sv_JoinDragRace', data.raceId)
        else
            exports["mythic_notify"]:SendAlert("error", "You must be in a vehicle to join the race!")
            return
        end
    else
        exports["mythic_notify"]:SendAlert("error", "You are already in a race!")
        return
    end
end)

RegisterNetEvent('vinDragStrip:cl_JoinDragRace')
AddEventHandler('vinDragStrip:cl_JoinDragRace', function(raceId, line)
    Data.Player.DragRaceId = raceId
    Data.Player.LinePosition = line
    Data.Player.StartingRace = true
    Data.Player.RaceCar = GetVehiclePedIsIn(Data.Player.Ped, false)
    SetEntityCoords(Data.Player.RaceCar, Config.DragStrip[raceId]["LinePosition"][Data.Player.LinePosition].x, Config.DragStrip[raceId]["LinePosition"][Data.Player.LinePosition].y, Config.DragStrip[raceId]["LinePosition"][Data.Player.LinePosition].z)
    SetEntityHeading(Data.Player.RaceCar, Config.DragStrip[raceId]["LinePosition"][Data.Player.LinePosition].heading)
    exports["mythic_notify"]:SendAlert("inform", "You joined the race to find out who asked!")
    CreateThread(function()
        while Data.Player.StartingRace do
            Wait(5)
            if Data.Player.LinePosition == 1 and not exports["polyzones"]:PointInside("left_start_line", GetEntityCoords(Data.Player.Ped)) then
                TriggerServerEvent('vinDragStrip:sv_EndRaceEarly', Data.Player.DragRaceId)
            end
            if Data.Player.LinePosition == 2 and not exports["polyzones"]:PointInside("right_start_line", GetEntityCoords(Data.Player.Ped)) then
                TriggerServerEvent('vinDragStrip:sv_EndRaceEarly', Data.Player.DragRaceId)
            end
        end
    end)
end)

RegisterNetEvent('vinDragStrip:cl_StartDragRace')
AddEventHandler('vinDragStrip:cl_StartDragRace', function(dragRaceId)
    if Data.Player.DragRaceId ~= 0 and Data.Player.DragRaceId == dragRaceId then
        Data.Player.DragRaceCP = CreateCheckpoint(9, Config.DragStrip[1]["FinishLinePosition"][Data.Player.LinePosition].x, Config.DragStrip[1]["FinishLinePosition"][Data.Player.LinePosition].y, Config.DragStrip[1]["FinishLinePosition"][Data.Player.LinePosition].z, 0, 0, 0, 35.0, 255, 71, 94, 255, 0) 
        racestart(dragRaceId)
        CreateThread(function()
            while Data.Player.RaceStarted do
                Wait(5)
                if Data.Player.LinePosition == 1 and exports["polyzones"]:PointInside("left_finish_line", GetEntityCoords(Data.Player.Ped)) then
                    TriggerServerEvent('vinDragStrip:sv_RaceFinished', Data.Player.DragRaceId)
                end
                if Data.Player.LinePosition == 2 and exports["polyzones"]:PointInside("right_finish_line", GetEntityCoords(Data.Player.Ped)) then
                    TriggerServerEvent('vinDragStrip:sv_RaceFinished', Data.Player.DragRaceId)
                end
            end
        end)
    end
end)

RegisterNetEvent('vinDragStrip:cl_RaceFinished')
AddEventHandler('vinDragStrip:cl_RaceFinished', function(dragRaceId, dragRaceWinner_Name)
    if Data.Player.DragRaceId ~= 0 and Data.Player.DragRaceId == dragRaceId then
        DeleteCheckpoint(Data.Player.DragRaceCP)
        Data.Player.RaceStarted = false
        Data.Player.RaceCar = nil
        Data.Player.LinePosition = nil
        Data.Player.DragRaceCP = nil
        Data.Player.DragRaceId = 0
        Data.Player.RaceCountdown = 0
        exports["mythic_notify"]:SendAlert("inform", " "..dragRaceWinner_Name.." won the drag race!")
    end
end)

RegisterNetEvent('vinDragStrip:cl_EndRaceEarly')
AddEventHandler('vinDragStrip:cl_EndRaceEarly', function(dragRaceId, dragRaceLeave_name)
    if Data.Player.DragRaceId ~= 0 and Data.Player.DragRaceId == dragRaceId then
        DeleteCheckpoint(Data.Player.DragRaceCP)
        Data.Player.StartingRace = false
        Data.Player.RaceCar = nil
        Data.Player.LinePosition = nil
        Data.Player.DragRaceCP = nil
        Data.Player.DragRaceId = 0
        Data.Player.RaceCountdown = 0
        exports["mythic_notify"]:SendAlert("error", " "..dragRaceLeave_name.." left the race early!")
    end
end)
---------------------------
    -- Threads --
---------------------------
CreateThread(function()
    Utils.AddBlip(vector3(850.68, -2921.45, 5.9), 38, 0, 0.65, "Drag Strip Racing")
    exports["polyzones"]:AddBoxZone("finish_line_1", vector3(1132.57, -2914.11, 5.9), 13.0, 0.8, {
        heading = 0,
        debugPoly = false,
        minZ = 4.7,
        maxZ = 8.9,
        data = {
            id = 1,
            ref = "left_finish_line"
        }
    })
    exports["polyzones"]:AddBoxZone("finish_line_2", vector3(1132.54, -2927.0, 5.9), 10.2, 1.0, {
        heading = 0,
        debugPoly = false,
        minZ = 4.7,
        maxZ = 8.9,
        data = {
            id = 2,
            ref = "right_finish_line"
        }
    })
    for i = 1, #Config.DragStrip do
        local tracking_length, tracking_width = Config.DragStrip[i]["JoinRace"].tracking_length, Config.DragStrip[i]["JoinRace"].tracking_width
        local tracking_minZ, tracking_maxZ = Config.DragStrip[i]["JoinRace"].tracking_minZ, Config.DragStrip[i]["JoinRace"].tracking_maxZ
        local tracking_heading = Config.DragStrip[i]["JoinRace"].tracking_heading
        local tracking_distance = Config.DragStrip[i]["JoinRace"].tracking_distance
        exports["qtarget"]:AddBoxZone("join_dragstrip_race", vector3(Config.DragStrip[i]["JoinRace"].x,Config.DragStrip[i]["JoinRace"].y,Config.DragStrip[i]["JoinRace"].z), tracking_length, tracking_width, {
            name = "join_dragstrip_race",
            debugPoly = false,
            heading = tracking_heading,
            minZ = tracking_minZ,
            maxZ = tracking_maxZ,
        }, {
            options = {
                {
                    event = "vinDragStrip:cl_joinRace",
                    icon = "fas fa-cars",
                    label = "Join Dragstrip Race",
                    raceId = i,
                },
            },
            job = {"all"},
            distance = tracking_distance
        })
    end
    for i = 1, #Config.DragStrip do
        local coords = vector3(Config.DragStrip[i]["LinePosition"][1].x,Config.DragStrip[i]["LinePosition"][1].y,Config.DragStrip[i]["LinePosition"][1].z)
        local length, width = Config.DragStrip[i]["LinePosition"][1].length, Config.DragStrip[i]["LinePosition"][1].width
        local minZ, maxZ = Config.DragStrip[i]["LinePosition"][1].minZ, Config.DragStrip[i]["LinePosition"][1].maxZ
        exports["polyzones"]:AddBoxZone("first_line", coords, length, width, {
            debugPoly = false,
            heading = 0,
            minZ = minZ,
            maxZ = maxZ,
            data = {
                id = 1,
                ref = "left_start_line"
            }
        })
        local coords = vector3(Config.DragStrip[i]["LinePosition"][2].x,Config.DragStrip[i]["LinePosition"][2].y,Config.DragStrip[i]["LinePosition"][2].z)
        local length, width = Config.DragStrip[i]["LinePosition"][2].length, Config.DragStrip[i]["LinePosition"][2].width
        local minZ, maxZ = Config.DragStrip[i]["LinePosition"][2].minZ, Config.DragStrip[i]["LinePosition"][2].maxZ
        exports["polyzones"]:AddBoxZone("second_line", coords, length, width, {
            debugPoly = false,
            heading = 0,
            minZ = minZ,
            maxZ = maxZ,
            data = {
                id = 2,
                ref = "right_start_line"
            }
        })
    end
end)
---------------------------
    -- Functions --
---------------------------
racestart = function(dragRaceId)
    if Data.Player.DragRaceId ~= 0 and Data.Player.DragRaceId == dragRaceId then
        while Data.Player.RaceCountdown ~= 3 and Data.Player.StartingRace do
            PlaySound(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
            exports["mythic_notify"]:SendAlert("inform", Data.Player.RaceCountdown)
            Wait(1000)
            Data.Player.RaceCountdown = Data.Player.RaceCountdown + 1
        end
        Data.Player.RaceCountdown = 0
        Data.Player.StartingRace = false
        Data.Player.RaceStarted = true
        exports["mythic_notify"]:SendAlert("success", "RACE TO FIND OUT WHO ASKED!")
        PlaySound(-1, "GO", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    else
        exports["mythic_notify"]:SendAlert("error", "You have to be in a race!")
    end
end