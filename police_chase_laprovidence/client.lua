local policeVehicle = nil
local policeDriver = nil
local policeBlip = nil
local chaseInProgress = false
local startTime = nil
local difficultySettings = {
    easy = {speed = 50.0, power = 15.0, style = 787083},
    medium = {speed = 70.0, power = 30.0, style = 787083},
    hard = {speed = 160.0, power = 120.0, style = 787083}
}

-- Utility function to load a model
local function LoadModel(modelHash)
    RequestModel(modelHash)
    local timeout = 5000 -- 5-second timeout
    while not HasModelLoaded(modelHash) and timeout > 0 do
        Wait(100)
        timeout = timeout - 100
    end
    return HasModelLoaded(modelHash)
end

-- Function to spawn the police car
function SpawnPoliceCar()
    if policeVehicle then return false end -- Prevent multi-spawn
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local spawnOffset = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -15.0, 0.0)

    -- Load the car model
    local vehicleModel = GetHashKey("police3")
    if not LoadModel(vehicleModel) then
        ShowMessageInGame("~r~Error: Failed to load car model")
        return false
    end

    -- Spawn the vehicle with visual effects
    policeVehicle = CreateVehicle(vehicleModel, spawnOffset.x, spawnOffset.y, spawnOffset.z, 
        GetEntityHeading(playerPed), true, false)
    StartParticleFxNonLoopedAtCoord("scr_carsteal4_wheel_burnout", spawnOffset.x, spawnOffset.y, spawnOffset.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
    
    if not DoesEntityExist(policeVehicle) then
        ShowMessageInGame("~r~Error: Failed to spawn the car")
        return false
    end

    -- Load and spawn the driver
    local driverModel = GetHashKey("s_m_y_cop_01")
    if not LoadModel(driverModel) then
        DeleteVehicle(policeVehicle)
        policeVehicle = nil
        return false
    end

    policeDriver = CreatePedInsideVehicle(policeVehicle, 26, driverModel, -1, true, false)
    
    -- Configure vehicle and driver
    SetVehicleModKit(policeVehicle, 0)
    SetVehicleMod(policeVehicle, 11, 3, false) -- Engine upgrade
    SetVehicleMod(policeVehicle, 13, 2, false) -- Transmission upgrade
    SetVehicleSiren(policeVehicle, true)
    SetVehicleLights(policeVehicle, 2)
    SetVehicleColours(policeVehicle, 0, 111) -- Black and white police style
    SetVehicleExtra(policeVehicle, 1, true) -- Add extras if available
    
    SetPedCombatAttributes(policeDriver, 3, false) -- Prevent combat
    SetPedFleeAttributes(policeDriver, 0, true) -- Prevent fleeing
    SetBlockingOfNonTemporaryEvents(policeDriver, true)
    SetPedArmour(policeDriver, 100) -- Armor for durability
    SetPedConfigFlag(policeDriver, 281, true) -- Enable police radio
    SetDriverAbility(policeDriver, 1.0) -- Max driving skill
    SetDriverAggressiveness(policeDriver, 1.0) -- Max aggression

    -- Configure blip
    policeBlip = AddBlipForEntity(policeVehicle)
    SetBlipSprite(policeBlip, 56) -- Police car icon
    SetBlipColour(policeBlip, 38) -- Blue
    SetBlipScale(policeBlip, 1.0)
    SetBlipFlashes(policeBlip, true) -- Flashing for urgency
    
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) -- Startup sound
    ShowMessageInGame("~g~Police approaching! Chase starts in 3 seconds...")
    Citizen.Wait(1000)
    ShowMessageInGame("~g~3...")
    Citizen.Wait(1000)
    ShowMessageInGame("~y~2...")
    Citizen.Wait(1000)
    ShowMessageInGame("~r~1... ~g~Run!")
    return true
end

-- Main chase function
function StartChase(difficulty)
    if not DoesEntityExist(policeVehicle) or not DoesEntityExist(policeDriver) then
        ShowMessageInGame("~r~Error: Vehicle or driver not found")
        return
    end

    chaseInProgress = true
    startTime = GetGameTimer()
    local settings = difficultySettings[difficulty]

    -- Apply difficulty settings
    SetDriveTaskDrivingStyle(policeDriver, settings.style)
    SetVehicleEnginePowerMultiplier(policeVehicle, settings.power)

    -- Add sound and visual effects
    Citizen.CreateThread(function()
        while chaseInProgress do
            Citizen.Wait(5000) -- Every 5 seconds
            if math.random() < 0.3 then -- 30% chance
                PlaySoundFromEntity(-1, "SIRENS_AIRHORN", policeVehicle, "DLC_WMSIRENS_SOUNDSET", 0, 0)
                StartParticleFxLoopedOnEntity("exp_air_molotov", policeVehicle, 0.0, 1.0, 0.5, 0.0, 0.0, 0.0, 0.5, false, false, false)
                ShowMessageInGame("~r~The police are intensifying the chase!")
            end
        end
    end)

    Citizen.CreateThread(function()
        while chaseInProgress do
            Citizen.Wait(50)
            
            if not DoesEntityExist(policeVehicle) or not DoesEntityExist(policeDriver) then
                chaseInProgress = false
                break
            end

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local policeCoords = GetEntityCoords(policeVehicle)
            local distance = #(playerCoords - policeCoords)

            -- Smarter pursuit with catch-up logic
            local targetSpeed = settings.speed
            if distance > 50.0 then
                targetSpeed = targetSpeed * 1.2 -- 20% speed boost if too far
            end
            TaskVehicleDriveToCoord(policeDriver, policeVehicle, 
                playerCoords.x, playerCoords.y, playerCoords.z, -- More precise targeting
                targetSpeed, 1.0, GetEntityModel(policeVehicle), 
                settings.style, 1.0, true)

            -- Random radio event
            if math.random() < 0.05 then -- 5% chance per tick
                ShowMessageInGame("~y~Police radio crackles: 'Suspect in sight!'")
                PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
            end

            -- End conditions with tighter escape range
            if distance < 5.0 and IsPlayerInVehicle() then
                local playerHeading = GetEntityHeading(GetVehiclePedIsIn(playerPed))
                local policeHeading = GetEntityHeading(policeVehicle)
                
                if math.abs(playerHeading - policeHeading) < 90.0 then
                    EndChase("~r~You've been caught by the police! Sirens blaring...")
                    return
                end
            elseif distance > 200.0 then -- Reduced from 300 to 200
                EndChase("~g~You’ve escaped the police! Silence falls...")
                return
            elseif (GetGameTimer() - startTime) > 120000 then -- 2 minutes max
                EndChase("~y~The police give up... for now.")
                return
            end

            -- Tension visual effect
            if distance < 20.0 then
                SetTimecycleModifier("NG_filmic03") -- Cinematic filter
                Citizen.Wait(100)
                ClearTimecycleModifier()
            end
        end
    end)
end

-- Function to end the chase
function EndChase(message)
    chaseInProgress = false
    ShowMessageInGame(message)
    PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true)
    Citizen.Wait(2000)
    ResetChase()
end

-- Check if player is in a vehicle
function IsPlayerInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

-- Reset everything
function ResetChase()
    if policeVehicle then
        DeleteEntity(policeVehicle)
        DeleteEntity(policeDriver)
        RemoveBlip(policeBlip)
        policeVehicle = nil
        policeDriver = nil
        policeBlip = nil
        chaseInProgress = false
        ClearTimecycleModifier() -- Reset visual effects
    end
end

-- Commands
RegisterCommand("chase", function(source, args)
    local difficulty = args[1] and args[1]:lower() or "medium"
    
    if not difficultySettings[difficulty] then
        ShowMessageInGame("~y~Usage: /chase [easy|medium|hard]")
        return
    end

    if SpawnPoliceCar() then
        StartChase(difficulty)
        ShowMessageInGame("~b~Chase started in " .. difficulty .. " mode! Hold on tight!")
    end
end, false)

RegisterCommand("reset", ResetChase, false)

-- In-game message function
function ShowMessageInGame(message)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, true, 5000)
end