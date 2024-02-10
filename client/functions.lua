-- Add any other conditions you may want to check for
---@return number | nil, vector3 | nil
function GetClosestVehicle()
    local vehicles = Z.GetVehicles()
    local ply = PlayerPedId()
    local plyPos = GetEntityCoords(ply)

    for _, vehHandler in pairs(vehicles) do
        local min, max = GetModelDimensions(GetEntityModel(vehHandler))
        local bottomOfVehicle = GetOffsetFromEntityInWorldCoords(vehHandler, 0.0, 0.0, min.z + 0.1)
        local dst = #((plyPos - vec3(0, 0, 0.985)) - bottomOfVehicle)
        local midToSideDst = max.x
        local canReach = dst < (midToSideDst * 1.3)
        local isEngineOff = GetIsVehicleEngineRunning(vehHandler) == false

        if (canReach and isEngineOff) then
            return vehHandler, bottomOfVehicle
        end
    end

    return nil
end

function ResetBusy()
    LocalPlayer.state:set("zyke_catalytic:Busy", false, true)
end

function SetBusy()
    LocalPlayer.state:set("zyke_catalytic:Busy", true, true)
end

---@return boolean
function IsBusy()
    return LocalPlayer.state["zyke_catalytic:Busy"] == true
end

local headingFinderPed = nil
---@param pos vector3
function FaceCoords(pos)
    local ply = PlayerPedId()
    local pedModel = GetHashKey("a_m_m_farmer_01")
    Z.LoadModel(pedModel)

    headingFinderPed = CreatePed(4, pedModel, pos.x, pos.y, pos.z, 0.0, false, true)
    SetEntityInvincible(headingFinderPed, true)
    SetBlockingOfNonTemporaryEvents(headingFinderPed, true)
    SetEntityCollision(headingFinderPed, false, false)
    FreezeEntityPosition(headingFinderPed, true)
    SetEntityVisible(headingFinderPed, false, false)
    SetModelAsNoLongerNeeded(pedModel)

    while (not IsPedFacingPed(ply, headingFinderPed, 15.0)) do
        TaskTurnPedToFaceEntity(ply, headingFinderPed, 500)

        Wait(100)
    end

    DeleteEntity(headingFinderPed)
end

local dict, anim = "amb@world_human_vehicle_mechanic@male@base", "base"
local function isPerformingAnimation()
    return IsEntityPlayingAnim(PlayerPedId(), dict, anim, 3)
end

---@param item string -- Item used
---@return boolean -- success
function AttemptStealing(item, vehicle)
    SetBusy()

    local min, max = GetModelDimensions(GetEntityModel(vehicle))
    local bottomOfVehicle = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 0.0, min.z + 0.1)
    local canStartStealing = vehicle ~= nil
    if (not canStartStealing or not vehicle or not bottomOfVehicle) then return false, Notify("noVehicleNearby") end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local hasBeenStolen, isReserved = GetCatalyticState(netId)
    local textPos = bottomOfVehicle + vec(0, 0, 0.3)
    if (hasBeenStolen) then return false, Notify("alreadyStolen") end
    if (isReserved) then return false, Notify("alreadyReserved") end

    TriggerServerEvent("zyke_catalytic:Reserve", netId)

    local ply = PlayerPedId()
    local plyPos = GetEntityCoords(ply)

    local leftOfVehicle = GetOffsetFromEntityInWorldCoords(vehicle, -5.0, 0.0, 0.0)
    local rightOfVehicle = GetOffsetFromEntityInWorldCoords(vehicle, 5.0, 0.0, 0.0)
    local isOnRightSide = #(plyPos - rightOfVehicle) < #(plyPos - leftOfVehicle)
    local pos = isOnRightSide and rightOfVehicle or leftOfVehicle

    Z.DisableKeys("zyke_catalytic:Stealing", true)
    FaceCoords(pos)
    Wait(100)

    Z.LoadDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 1, 0, false, false, false)
    while (not isPerformingAnimation()) do Wait(0) end

    Z.DisableKeys("zyke_catalytic:Stealing", false)
    local loadingTextStr = T("loadingText")
    local cancelStr = T("cancel", {Config.Settings.miniGame.cancelKey})
    local waitTimer = GetGameTimer() + (Config.Settings.intervals.findingCatalytic * 1000)
    while (GetGameTimer() < waitTimer) do
        Draw3DText(textPos, loadingTextStr, 0.4)
        DrawMissionText(cancelStr, 0.96, 0.5)

        local isCancelling = IsControlJustPressed(0, Keys[Config.Settings.miniGame.cancelKey].keyCode) or not isPerformingAnimation()

        if (isCancelling) then
            ClearPedTasks(ply)
            return false, TriggerServerEvent("zyke_catalytic:Cancel", netId)
        end

        Wait(0)
    end

    HandleAlert(vehicle)

    local success, reason = Minigame(vehicle, textPos, item)
    if (not success) then
        TriggerServerEvent("zyke_catalytic:Cancel", netId)

        Notify(reason or "failedMinigame")

        -- Perform any action for failing the minigame, such as alerting police, just keep the return statement at the end

        return false, ClearPedTasks(ply)
    end

    Z.ProgressBar({
        name = "finishMinigameProgressBar",
        duration = Config.Settings.intervals.finishMinigameProgressBar * 1000,
        label = T("finishMinigameProgressBar")
    })

    local response = Z.Callback("zyke_catalytic:StealCatalyticConverter", false, {
        item = item,
        netId = netId,
        vehicleClass = GetVehicleClass(vehicle),
        modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    })

    if (response.reason) then return false, Notify(response.reason) end

    ResetBusy()
    ClearPedTasks(ply)

    ForceVehicleEngineAudio(vehicle, Config.Settings.vehicleSound)

    return true
end

---@param vehHandler number
---@param item string -- Item used
---@param displayPos vector3
---@return boolean, string? -- success, reason
function Minigame(vehHandler, displayPos, item)
    if (not isPerformingAnimation()) then return false, "cancelledMinigame" end

    local settings = Config.Settings.miniGame
    local lastPressedTime = GetGameTimer()
    local timePerKey = (settings.timePerKey * 1000) * Config.Settings.grinderItems[item].timeMultiplier
    local totalClicks = settings.totalClicks * Config.Settings.grinderItems[item].totalClicksMultiplier
    local formattedKeys = nil
    local keyToClick = nil
    local availableKeys = Z.CopyTable(settings.keys)

    local function scrambleKeys()
        local newKeys = {}

        while (#availableKeys > 0) do
            local randIndex = math.random(1, #availableKeys)
            local keyData = table.remove(availableKeys, randIndex)
            table.insert(newKeys, keyData)
        end

        availableKeys = newKeys
    end

    -- Generating the key to click & display string
    ---@return string, string
    local function generateClick()
        scrambleKeys()

        local randKey = nil
        local str = ""

        if (#availableKeys > 1) then
            repeat
                randKey = availableKeys[math.random(1, #availableKeys)].key
            until (randKey ~= keyToClick)
        else
            -- If you for some reason only have one key, probably for testing
            randKey = availableKeys[1].key
        end

        for _, keyData in pairs(availableKeys) do
            local isRandKey = keyData.key == randKey
            local color = isRandKey and "~r~" or "~w~"
            str = str .. color .. keyData.key .. "~s~"
        end

        return str, randKey
    end

    -- Handling your clicks
    local function handleClick(key)
        if (key ~= keyToClick) then
            lastPressedTime = GetGameTimer()
            return false
        end

        lastPressedTime = GetGameTimer()
        totalClicks = totalClicks - 1
        if (totalClicks <= 0) then return true end

        formattedKeys, keyToClick = generateClick()

        return true
    end

    -- Initialize
    formattedKeys, keyToClick = generateClick()

    local cancelStr = T("cancel", {settings.cancelKey})
    while (totalClicks > 0) do
        -- Extras
        local isEngineOff = GetIsVehicleEngineRunning(vehHandler) == false
        if (not isEngineOff) then return false, "engineIsOn" end

        -- Timer and key presses
        local now = GetGameTimer()
        local timeSinceLastPressed = now - lastPressedTime
        local timeLeft = timePerKey - timeSinceLastPressed

        for index, keyData in pairs(availableKeys) do
            DisableControlAction(0, keyData.keyCode, true)
            if (IsDisabledControlJustPressed(0, keyData.keyCode)) then
                local state = handleClick(keyData.key)
                if (not state) then return false, "failedMinigame" end
            end
        end

        local displayStr = T("keysToPress", {formattedKeys}) .. "\n" .. T("timeLeft", {math.floor(timeLeft / 100) / 10})
        Draw3DText(displayPos, displayStr, 0.4)
        DrawMissionText(cancelStr, 0.96, 0.5)

        if (IsControlJustPressed(0, Keys["X"].keyCode)) then
            return false, "cancelledMinigame"
        end

        if (timeLeft < 0) then return false end
        Wait(1)
    end

    return true
end

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if (headingFinderPed) then DeleteEntity(headingFinderPed) end

    ResetBusy()
end)

---@return table
function GetValidVehiclesForParticles()
    local vehicles = {}
    local ply = PlayerPedId()
    local plyPos = GetEntityCoords(ply)

    for _, vehHandler in pairs(Z.GetVehicles()) do
        local pos = GetEntityCoords(vehHandler)
        local dst = #(plyPos - pos)

        if (dst < 100) then
            local isEngineOn = GetIsVehicleEngineRunning(vehHandler)
            local plate = GetVehicleNumberPlateText(vehHandler)
            local hasBeenStolen = GlobalState["stolenCatalytics"][plate] ~= nil

            if (isEngineOn and hasBeenStolen) then
                vehicles[#vehicles+1] = vehHandler
            end
        end
    end

    return vehicles
end

function TalkToBuyer()
    if (IsBusy()) then return Notify("busy") end

    local items = GetSellableItemsFromPlayer()
    local contextId = "zyke_catalytic:sell"
    local options = {}

    if (#items > 0) then
        for _, itemData in pairs(items) do
            local itemLabel = itemData.label
            local itemPrice = itemData.price
            local itemAmount = itemData.amount
            local totalPrice = itemPrice * itemAmount

            local description = T("sellItemDesc")
            description = description:format(itemAmount, itemLabel, FormatCurrency(totalPrice)) -- Add all basic info
            description = description .. "\n\n" .. T("sellItemPriceEach", {FormatCurrency(itemPrice)}) -- Add what each goes gofr at the bottom

            options[#options+1] = {
                title = T("sellItemLabel", {itemLabel}),
                description = description,
                icon = "comments-dollar",
                onSelect = function()
                    local response = SellItem(itemData.name)
                    ResetBusy()

                    if (response and response.state == true) then
                        Notify("successfulSell", {itemAmount, itemLabel, FormatCurrency(totalPrice)})
                    else
                        Notify(response?.reason)
                    end
                end,
            }
        end
    else
        options[#options+1] = {
            title = T("nothingToSell"),
            disabled = true,
            icon = "fas fa-ban"
        }
    end

    -- Adding in the desired parts

    local desiredPartsSett = Config.Settings.desiredParts
    local timeUntilNew = (CachedData.desiredParts.lastGenerated + desiredPartsSett.timeBetween - GlobalState["OsTime"])
    local timeFormat = timeUntilNew < 60 and "s" or "m"
    local formattedTime = timeFormat == "s" and timeUntilNew or math.floor(timeUntilNew / 60)

    local progress = (timeUntilNew / desiredPartsSett.timeBetween) * 100
    if (progress < 0) then
        progress = 0
    end

    local progressColor = "#F03E3E" -- Red
    if (progress > 66) then
        progressColor = "#40C057" -- Green
    elseif (progress > 33) then
        progressColor = "#FD7E14" -- Orange
    end

    options[#options+1] = {
        title = T("desiredParts", {formattedTime, timeFormat}),
        readOnly = true,
        progress = progress,
        colorScheme = progressColor,
        icon = "fas fa-sack-dollar"
    }

    if (#CachedData.desiredParts.parts > 0) then
        for _, part in pairs(CachedData.desiredParts.parts) do
            local percentageToMax = ((part.priceMultiplier - 1) / (desiredPartsSett.priceMultiplier[2] - 1)) * 100
            local catData = GetCatalyticPriceFromModel(part.value)
            if (not catData) then return error("Could not find catalytic data for " .. part.value) end

            local finalPrice = math.floor(catData.price * part.priceMultiplier)

            options[#options+1] = {
                title = T("desiredItemLabel", {part.label}),
                description = T("desiredItemDesc", {part.label, FormatCurrency(finalPrice), part.priceMultiplier}),
                icon = "comments-dollar",
                progress = percentageToMax,
                colorScheme = "#FCC419",
                image = part.image,
                onSelect = function()
                    local catItem = catData.name
                    local desiredItem = Z.GetPlayerItemByName(catItem, nil, true, true, {model = string.upper(part.value)})
                    if (not desiredItem) then return Notify("noItemsToSell") end

                    local response = SellItem(catItem, part.value)
                    ResetBusy()

                    if (response and response.state == true) then
                        Notify("successfulSell", {1, T("desiredItemSellNoti", {part.label}), FormatCurrency(finalPrice)})
                    else
                        Notify(response?.reason)
                    end
                end
            }
        end
    else
        options[#options+1] = {
            title = T("nothingDesired"),
            icon = "fas fa-clock",
            disabled = true
        }
    end

    lib.registerContext({
        id = contextId,
        title = T("robertMenuLabel"),
        options = options,
    })

    lib.showContext(contextId)
end

---@return table
function GetSellableItemsFromPlayer()
    local playerItems = Z.GetPlayerItems()
    local items = {}

    for _, itemSettings in pairs(Config.Settings.availableToSell) do
        local itemData = Z.GetPlayerItemByName(itemSettings.name, playerItems, true)
        local amount = itemData?.amount or 0

        if (amount > 0) then
            local itemLabel = Z.GetItem(itemSettings.name).label

            items[#items+1] = {
                name = itemSettings.name,
                label = itemLabel,
                amount = amount,
                price = itemSettings.price,
            }
        end
    end

    return items
end

---@param name string
---@param desiredModel string? -- Name of the desired vehicle model
---@return table | boolean
function SellItem(name, desiredModel)
    lib.hideContext()
    SetBusy()

    local ply = PlayerPedId()
    FreezeEntityPosition(ply, true)

    local settings = Config.Settings.buyer
    if (settings?.playerAnim?.dict) then
        if (settings.playerAnim?.name == nil or settings.playerAnim?.name == "") then
            TaskStartScenarioInPlace(ply, settings.playerAnim.dict, 0, true)
        else
            if (not Z.LoadDict(settings.playerAnim.dict)) then return false end
            TaskPlayAnim(ply, settings.playerAnim.dict, settings.playerAnim.name, 8.0, 8.0, -1, 1, 0, false, false, false)
        end
    end

    local p = promise.new()
    CreateThread(function()
        Z.ProgressBar({
            name = "selling_to_buyer",
            duration = Config.Settings.buyer.dealTime * 1000,
            label = T("completingDeal"),
            onFinish = function()
                local response = Z.Callback("zyke_catalytic:SellItem", false, {
                    name = name,
                    desiredModel = desiredModel
                })

                p:resolve(response)
            end,
            onCancel = function()
                p:resolve({state = false, reason = "cancelled"})
            end,
            canCancel = true,
        })
    end)

    local res = Citizen.Await(p)
    FreezeEntityPosition(ply, false)
    ClearPedTasks(ply)

    return res
end

---@param item string
function EquipGrinder(item)
    ClearGrinderObject()

    -- Check if it the same grinder, then unequip, otherwise equip the new one
    if (CachedData.equipped.name == item) then
        CachedData.equipped = {}
        ResetBusy()
        return
    end

    local settings = Config.Settings.grinderItems[item]

    local isModelValid = IsModelValid(joaat(settings.model))
    if (not isModelValid) then ResetBusy() error("Angle grinder model does not exist: " .. settings.model) return end

    RequestModel(settings.model)
    while (not HasModelLoaded(settings.model)) do Wait(0) end

    local ply = PlayerPedId()
    local plyPos = GetEntityCoords(ply)
    local object = CreateObject(settings.model, plyPos.x, plyPos.y, plyPos.z, true, true, true)

    CachedData.equipped = {
        name = item,
        object = object,
    }

    AttachEntityToEntity(object, ply, GetPedBoneIndex(ply, 57005), settings.offsets.x, settings.offsets.y, settings.offsets.z, settings.rotation.x, settings.rotation.y, settings.rotation.z, true, true, false, true, 1, true)

    SetEntityAsMissionEntity(object, true, true)
    SetModelAsNoLongerNeeded(settings.model)
    SetEntityCollision(object, false, false)

    ResetBusy()
end

AddEventHandler("onResourceStop", function(resName)
    if (GetCurrentResourceName() ~= resName) then return end

    ClearGrinderObject()
end)

function ClearGrinderObject()
    local prevGrinder = CachedData.equipped
    if (prevGrinder.name) then
        if (prevGrinder.object and DoesEntityExist(prevGrinder.object)) then
            DeleteEntity(prevGrinder.object)
        end
    end
end

---@param coords vector3 | vector4 | table
---@param text string
---@param scale number?
---@param rgba table?
function Draw3DText(coords, text, scale, rgba)
    local _, x, y =World3dToScreen2d(coords.x, coords.y, coords.z)

    rgba = rgba or {}

    SetTextScale(scale or 0.3, scale or 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(rgba.r or 255, rgba.g or 255, rgba.b or 255, rgba.a or 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    DrawText(x, y)
end

---@param text string
---@param height number
---@param length number
function DrawMissionText(text, height, length)
	-- 0.96, 0.5 = bottom centered
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(length ~= nil and length or 0.5, height ~= nil and height or 0.96)
end

function DisplayHelpText(msg, thisFrame, beep, duration)
    AddTextEntry('zyke_catalytic', msg)

    if thisFrame then
        DisplayHelpTextThisFrame('zyke_catalytic', false)
    else
        if beep == nil then
            beep = true
        end
        BeginTextCommandDisplayHelp('zyke_catalytic')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end
end

function HandleAlert(vehicle)
    local settings = Config.Settings.alert
    if (settings.alertChance <= 0) then return end

    local isAlerting = math.random(1, 100) <= settings.alertChance
    if (not isAlerting) then return end

    local isVehicleAlarm = settings.vehicleAlarm
    if (isVehicleAlarm) then
        SetVehicleAlarm(vehicle, true)
        StartVehicleAlarm(vehicle)
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    TriggerServerEvent("zyke_catalytic:AlertPolice", netId, plate, model)
end

---@param modelName string
---@return table | nil
function GetCatalyticPriceFromModel(modelName)
    local vehClass = GetVehicleClassFromName(modelName)
    local catName = Config.Settings.itemsForVehicleTypes[vehClass]

    for _, catData in pairs(Config.Settings.availableToSell) do
        if (catData.name == catName) then
            return catData
        end
    end

    return nil
end