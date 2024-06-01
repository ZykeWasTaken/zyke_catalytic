Z.CreateCallback("zyke_catalytic:SellItem", function(source, cb, data)
    local itemName = data.name

    local playerItem = Z.GetPlayerItemByName(source, itemName, false, data.desiredModel and true, data.desiredModel and {
        model = string.upper(data.desiredModel)
    })?[1]

    if (not playerItem) then return cb({state = false, reason = "noItem"}) end

    local itemSettings = Z.Find(Config.Settings.availableToSell, function(item)
        return item.name == itemName
    end)

    if (not itemSettings) then return cb({state = false, reason = "noItemSettings"}) end

    local amount = playerItem.amount or 0
    if (amount <= 0) then return cb({state = false, reason = "noItemAmount"}) end

    local desiredMultiplier = 1.0
    if (data.desiredModel) then
        local offerIdx
        for idx, offerData in pairs(CachedData.desiredParts.parts) do
            if (offerData.value == data.desiredModel) then
                desiredMultiplier = offerData.priceMultiplier
                offerIdx = idx
                break
            end
        end

        if (not offerIdx) then return cb({state = false, reason = "offerGone"}) end
        CachedData.desiredParts.parts[offerIdx] = nil

        TriggerClientEvent("zyke_catalytic:SyncDesiredParts", -1, CachedData.desiredParts)
    end

    local total = amount * itemSettings.price * desiredMultiplier
    Z.RemoveItem(source, itemName, amount, data.desiredModel and playerItem.metadata)
    Z.AddMoney(source, "cash", total)

    return cb({state = true})
end)

Z.CreateCallback("zyke_catalytic:StealCatalyticConverter", function(source, cb, data)
    local vehicle = NetworkGetEntityFromNetworkId(data.netId)
    if (not vehicle) then return cb({state = false, reason = "noVehicleFound"}) end

    local hasBeenStolen, _ = GetCatalyticState(data.netId)
    if (hasBeenStolen) then return cb({state = false, reason = "alreadyStolen"}) end

    local vehPlate = GetVehicleNumberPlateText(vehicle)
    local reserver = GlobalState["reservedCatalytics"][vehPlate]
    local reservedByInvoker = reserver == source
    if (not reservedByInvoker) then return cb({state = false, reason = "alreadyReserved"}) end

    SetAsStolen(data.netId, source)
    SetAsReserved(data.netId, nil)

    local item = Config.Settings.itemsForVehicleTypes[data.vehicleClass]
    local itemLabel = Z.GetItem(item).label

    Z.AddItem(source, item, 1, {
        description = T("metadataLabel", {string.lower(data.modelName):gsub("^%l", string.upper)}),
        model = data.modelName
    })
    Notify("successfulSteal", {itemLabel})

    Wait(50)

    return cb({state = true})
end)

RegisterNetEvent("zyke_catalytic:Cancel", function(netId)
    SetAsReserved(netId, nil)
end)

RegisterNetEvent("zyke_catalytic:Reserve", function(netId)
    local hasBeenStolen, isReserved = GetCatalyticState(netId)
    if (hasBeenStolen or isReserved) then
        print("Warning: Possible exploit attempt by %s " .. source)

        return
    end

    SetAsReserved(netId, source)

    -- Cleanup after 60 seconds, used if the player disconnects or something
    -- Will automatically stop the loop if the vehicle is no longer reserved
    CreateThread(function()
        local plate = GetVehicleNumberPlateText(NetworkGetEntityFromNetworkId(netId))
        local start = os.time()
        while (GlobalState["reservedCatalytics"][plate] == source) do
            Wait(1000)

            if (os.time() - start >= 60) then
                SetAsReserved(netId, nil)
                break
            end
        end
    end)
end)

-- Grab netId by using the NetworkGetNetworkIdFromEntity native
-- https://docs.fivem.net/natives/?_0xA11700682F3AD45C
---@param netId number
RegisterNetEvent("zyke_catalytic:Repair", function(netId)
    if (#Config.Settings.repairJobs > 0) then
        local plyJob = Z.GetJob(source)
        local hasJob = false
        for _, jobName in pairs(Config.Settings.repairJobs) do
            if (plyJob.name == jobName) then
                hasJob = true
                break
            end
        end

        if (not hasJob) then return end
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if (not vehicle) then return end

    local ply = GetPlayerPed(source)
    local vehiclePos = GetEntityCoords(vehicle)
    local plyPos = GetEntityCoords(ply)
    local dst = #(vehiclePos - plyPos)
    if (dst > 5) then return end

    local hasBeenStolen, isReserved = GetCatalyticState(netId)
    if (not hasBeenStolen or isReserved) then return end

    -- Triggers a client-sided event to reset the vehicle sound
    TriggerClientEvent("zyke_catalytic:ResetVehicleSound", source, netId)

    SetAsStolen(netId, nil)
end)

RegisterNetEvent("zyke_catalytic:AlertPolice", function(netId, plate, model)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if (not vehicle) then return end

    local reservedBy = GlobalState["reservedCatalytics"][plate]
    local isReservedByInvoker = reservedBy == source
    if (not isReservedByInvoker) then return end

    local vehiclePos = GetEntityCoords(vehicle)

    local playersOnJob = Z.GetPlayersOnJob(Config.Settings.alert.jobs, true)
    if (#playersOnJob <= 0) then return end

    for _, playerId in pairs(playersOnJob) do
        TriggerClientEvent("zyke_catalytic:HandleAlert", playerId, netId, vehiclePos, plate, model)
    end
end)

RegisterNetEvent("zyke_lib:OnCharacterSelect", function(player)
    local source = Z.GetSource(player)
    if (not source) then return end

    TriggerClientEvent("zyke_catalytic:SyncDesiredParts", source, CachedData.desiredParts)
end)