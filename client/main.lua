while (not HasInitializedTranslations) do Wait(50) end

Keys = Z.GetKeys()
TargetMenu = Z.GetTarget()

CachedData = {
    equipped = {
        --[[
            name = "angle_grinder",
            object = 0,
        ]]
    },
    desiredParts = {
        lastGenerated = 0,
        parts = {}
    }
}

--
-- Loop for creating smoke particles on vehicles
--

local partDict = "core"
local particle = "ent_ray_ch2_farm_smoke_dble"
CreateThread(function()
    RequestNamedPtfxAsset(partDict)
    while (not HasNamedPtfxAssetLoaded(partDict)) do Wait(0) end

    local getClosestVehiclesTimer = 0
    local closeVehicles = {}
    while (true) do
        local particles = {}
        local sleep = 500

        if (GetGameTimer() > getClosestVehiclesTimer) then
            getClosestVehiclesTimer = GetGameTimer() + 500
            closeVehicles = GetValidVehiclesForParticles()
        end

        if (#closeVehicles > 0) then sleep = 200 end
        for _, vehicleHandler in pairs(closeVehicles) do
            local exhausts = {
                "exhaust",
            }

            UseParticleFxAssetNextCall(partDict)
            for _, exhaustName in pairs(exhausts) do
                local boneIndex = GetEntityBoneIndexByName(vehicleHandler, exhaustName)
                local exhaustPos = GetWorldPositionOfEntityBone(vehicleHandler, boneIndex)

                particles[#particles+1] = StartParticleFxLoopedAtCoord(particle, exhaustPos.x, exhaustPos.y, exhaustPos.z, 0.0, 0.0, 0.0, 0.6, false, false, false, false)
            end
        end

        Wait(sleep)
        if (#particles > 0) then
            for i = #particles, 1, -1 do
                StopParticleFxLooped(particles[i], false)
                particles[i] = nil
            end
        end
    end
end)

--
-- Creating & handling buyer
--

CreateThread(function()
    local settings = Config.Settings.buyer
    if (settings.enabled ~= true) then return end
    if (not Z.LoadModel(settings.model)) then return end

    local buyerHandler = CreatePed(4, settings.model, settings.pos.x, settings.pos.y, settings.pos.z - 0.985, settings.pos.w, false, true)
    SetEntityInvincible(buyerHandler, true)
    SetBlockingOfNonTemporaryEvents(buyerHandler, true)
    FreezeEntityPosition(buyerHandler, true)
    SetModelAsNoLongerNeeded(settings.model)

    if (settings?.anim?.dict) then
        if (settings.anim?.name == nil or settings.anim?.name == "") then
            TaskStartScenarioInPlace(buyerHandler, settings.anim.dict, 0, true)
        else
            if (not Z.LoadDict(settings.anim.dict)) then return end
            TaskPlayAnim(buyerHandler, settings.anim.dict, settings.anim.name, 8.0, 8.0, -1, 1, 0, false, false, false)
        end
    end

    if (settings?.blip?.enabled == true) then
        local blip = AddBlipForCoord(settings.pos.x, settings.pos.y, settings.pos.z)
        SetBlipSprite(blip, settings.blip.sprite)
        SetBlipScale(blip, settings.blip.scale)
        SetBlipColour(blip, settings.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(settings.name)
        EndTextCommandSetBlipName(blip)
    end

    local targetId = nil
    if (TargetMenu) then
        targetId = Z.AddTargetEntity(buyerHandler, {
            options = {
                {
                    num = 1,
                    name = "talkToBuyer",
                    label = T("talkToBuyerTarget", {settings.name}),
                    icon = "fas fa-comment",
                    action = function()
                        TalkToBuyer()
                    end,
                    onSelect = function()
                        TalkToBuyer()
                    end,
                    distance = 1.5
                }
            },
            distance = 1.5
        })
    else
        -- If you don't use a traget menu, use a loop with a standard E press
        CreateThread(function()
            local talkStr = T("talkToBuyerKeyPress", {settings.talkKey, settings.name})
            local talkPos = GetOffsetFromEntityInWorldCoords(buyerHandler, 0.0, 0.5, 0.0)

            while (true) do
                local sleep = 1000
                local ply = PlayerPedId()
                local plyPos = GetEntityCoords(ply)
                local dst = #(plyPos - talkPos)

                if (dst < 10) then
                    if (IsBusy()) then sleep = 500 goto endOfLoop end

                    sleep = 1

                    if (dst < 2) then
                        local maxScale = 0.3
                        local scale = maxScale - (dst * (maxScale / 2))

                        Draw3DText(vec3(talkPos.x, talkPos.y, talkPos.z), talkStr, scale)

                        if (dst < 0.75) then
                            if (IsControlJustReleased(0, Keys[settings.talkKey].keyCode)) then
                                TalkToBuyer()
                            end
                        end
                    end
                end

                ::endOfLoop::
                Wait(sleep)
            end
        end)
    end

    AddEventHandler("onResourceStop", function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then return end

        DeleteEntity(buyerHandler)

        if (targetId) then
            Z.RemoveTarget(targetId)
        end
    end)
end)

--
-- Managing the vehicle zones
--

CreateThread(function()
    local closestVehicles = {}
    local canPolyzone = {}
    local polyzonedVehicles = {}

    local intervals = {
        ["fetchClosestVehicles"] = {last = 0, delay = 2500, func = function()
            local ply = PlayerPedId()
            local plyPos = GetEntityCoords(ply)

            closestVehicles = {}

            local vehicles = GetGamePool("CVehicle")
            for _, vehicle in pairs(vehicles) do
                local isClose = #(plyPos - GetEntityCoords(vehicle)) < 100
                if (not isClose) then goto endOfLoop end

                local plate = GetVehicleNumberPlateText(vehicle)
                local hasNetId = NetworkGetEntityIsNetworked(vehicle)
                -- Check for reserved later, otherwise the vehicle will not be able to appear for the longer delay this function has
                local canSteal = GlobalState["stolenCatalytics"][plate] == nil and hasNetId
                if (not canSteal) then goto endOfLoop end

                local netId = NetworkGetNetworkIdFromEntity(vehicle)
                local isElectric = GetVehicleHandlingInt(vehicle, "CHandlingData", "nInitialDriveGears") == 1 or GetVehicleHandlingInt(vehicle, "CHandlingData", "fOilVolume") <= 0.0
                if (isElectric) then goto endOfLoop end

                closestVehicles[#closestVehicles+1] = {
                    netId = netId,
                    vehicle = vehicle,
                    plate = plate,
                }

                ::endOfLoop::
            end
        end},
        ["managePolyzones"] = {last = 0, delay = 250, func = function()
            -- First, clear out the old ones
            for plate in pairs(polyzonedVehicles) do
                local shouldRemove = canPolyzone[plate] == nil

                if (shouldRemove) then
                    polyzonedVehicles[plate].polyzoneLeft:destroy()
                    polyzonedVehicles[plate].polyzoneRight:destroy()
                    polyzonedVehicles[plate] = nil
                end
            end

            -- Loop through canPolyzone and polyzonedVehicles, remove the polyzone from vehicles that are no longer in canPolyzone and add new ones that are now in canPolyzone
            for plate, vehicleData in pairs(canPolyzone) do
                local alreadyPolyzoned = polyzonedVehicles[plate] ~= nil
                local alreadyReserved = GlobalState["reservedCatalytics"][plate] ~= nil
                if (alreadyPolyzoned or alreadyReserved) then goto endOfLoop end

                local min, max = GetModelDimensions(GetEntityModel(vehicleData.vehicle))
                local xOffset = max.x + 0.15
                local length = (max.y - min.y) / 4

                local leftOfVehicle = GetOffsetFromEntityInWorldCoords(vehicleData.vehicle, -xOffset, 0.0, 0.0)
                local rightOfVehicle = GetOffsetFromEntityInWorldCoords(vehicleData.vehicle, xOffset, 0.0, 0.0)
                local bottomOfVehicle = GetOffsetFromEntityInWorldCoords(vehicleData.vehicle, 0.0, 0.0, min.z)

                polyzonedVehicles[plate] = vehicleData
                polyzonedVehicles[plate].polyzoneLeft = BoxZone:Create(leftOfVehicle, 0.5, length, {
                    name = "zyke_catalytic:polyzoneLeft",
                    heading = vehicleData.heading - 90.0,
                    debugColors = {walls = {0, 255, 0}},
                    minZ = bottomOfVehicle.z,
                    maxZ = bottomOfVehicle.z + 0.3,
                    scale = {1.0, 1.0, 1.0},
                })

                polyzonedVehicles[plate].polyzoneRight = BoxZone:Create(rightOfVehicle, 0.5, length, {
                    name = "zyke_catalytic:polyzoneRight",
                    heading = vehicleData.heading - 90.0,
                    debugColors = {walls = {0, 255, 0}},
                    minZ = bottomOfVehicle.z,
                    maxZ = bottomOfVehicle.z + 0.3,
                    scale = {1.0, 1.0, 1.0},
                })

                ::endOfLoop::
            end
        end}
    }

    local startStealingStr = T("startStealing", {Keys[Config.Settings.keyToStart].name})
    while (true) do
        local sleep = 500
        local ply = PlayerPedId()
        local isInVehicle = IsPedInAnyVehicle(ply, false)
        local shouldDisplay = CachedData.equipped.name ~= nil and not isInVehicle

        if (shouldDisplay) then
            local plyPos = GetEntityCoords(ply)

            sleep = 1
            canPolyzone = {}
            for _, vehicleData in pairs(closestVehicles) do
                local vehicle = vehicleData.vehicle
                local canPolyzoneVehicle = false

                -- Various checkers to see if you can polyzone the vehicle
                local isClose = #(plyPos - GetEntityCoords(vehicle)) < 5
                local isNotStolen = GlobalState["stolenCatalytics"][vehicleData.plate] == nil and GlobalState["reservedCatalytics"][vehicleData.plate] == nil
                local isNotPolyzoned = canPolyzone[vehicleData.plate] == nil
                local isNotMoving = GetEntitySpeed(vehicle) < 0.1
                local isNotRunning = not GetIsVehicleEngineRunning(vehicle)
                if (isClose and isNotStolen and isNotPolyzoned and isNotMoving and isNotRunning) then canPolyzoneVehicle = true end

                if (canPolyzoneVehicle) then
                    local plate = vehicleData.plate
                    local netId = vehicleData.netId
                    local pos = GetEntityCoords(vehicle)
                    local heading = GetEntityHeading(vehicle)

                    canPolyzone[plate] = {
                        netId = netId,
                        vehicle = vehicle,
                        pos = pos,
                        heading = heading,
                    }
                end
            end

            for plate, data in pairs(polyzonedVehicles) do
                if (data.polyzoneLeft and data.polyzoneRight) then
                    if (Config.Settings.drawPolyzone) then
                        data.polyzoneLeft:draw()
                        data.polyzoneRight:draw()
                    end

                    local insideLeft = data.polyzoneLeft:isPointInside(plyPos - vec3(0, 0, 0.9))
                    local insideRight = data.polyzoneRight:isPointInside(plyPos - vec3(0, 0, 0.9))
                    if (insideLeft or insideRight) then
                        DisplayHelpText(startStealingStr)
                        DisableControlAction(0, Keys[Config.Settings.keyToStart].keyCode, true)

                        if (IsDisabledControlJustPressed(0, Keys[Config.Settings.keyToStart].keyCode)) then
                            local state = AttemptStealing(CachedData.equipped.name, data.vehicle)

                            if (state == true) then
                                canPolyzone[plate] = nil
                                polyzonedVehicles[plate] = nil
                            end
                        end
                    end
                end
            end
        else
            canPolyzone = {}
        end

        for _, intervalData in pairs(intervals) do
            if (GetGameTimer() > intervalData.last + intervalData.delay) then
                intervalData.last = GetGameTimer()
                intervalData.func()
            end
        end

        Wait(sleep)
    end
end)