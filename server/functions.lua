-- Function to set the catalytic convert as stolen for the vehicle
-- May need to modify this based on your garage script
---@param netId number
---@param value number | nil -- playerId or nil to remove
function SetAsStolen(netId, value)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local plate = GetVehicleNumberPlateText(vehicle)

    local prev = Z.CopyTable(GlobalState["stolenCatalytics"])
    prev[plate] = value

    GlobalState["stolenCatalytics"] = prev
end

-- Allows you to reserve a vehicle, so that no one else can start trying to steal it when you are already doing it
---@param netId number
---@param value number | nil -- playerId or nil to remove
function SetAsReserved(netId, value)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local plate = GetVehicleNumberPlateText(vehicle)

    local prev = Z.CopyTable(GlobalState["reservedCatalytics"])
    prev[plate] = value

    GlobalState["reservedCatalytics"] = prev
end

-- Trigger this export when someone switches plates on their vehicles to keep track of the reserved/stolen catalytics
---@param oldPlate string
---@param newPlate string
function SwapPlates(oldPlate, newPlate)
    -- Reserved
    if (GlobalState["reservedCatalytics"][oldPlate]) then
        local playerId = GlobalState["reservedCatalytics"][oldPlate]
        GlobalState["reservedCatalytics"][newPlate] = playerId
        GlobalState["reservedCatalytics"][oldPlate] = nil
    end

    -- Stolen
    if (GlobalState["stolenCatalytics"][oldPlate]) then
        local playerId = GlobalState["stolenCatalytics"][oldPlate]
        GlobalState["stolenCatalytics"][newPlate] = playerId
        GlobalState["stolenCatalytics"][oldPlate] = nil
    end
end

exports("SwapPlates", SwapPlates)

-- Example:
-- exports["zyke_catalytic"]:SwapPlates("ABC123", "JD28DA")

function GenerateDesiredCatalytics()
    local settings = Config.Settings.desiredParts
    local totalDeals = settings.deals <= #settings.vehicles and settings.deals or #settings.vehicles
    local availableVehs = Z.CopyTable(settings.vehicles)
    local genDeals = {}

    for i = 1, totalDeals do
        local randVehIdx = math.random(1, #availableVehs)
        local randVeh = availableVehs[randVehIdx]
        table.remove(availableVehs, randVehIdx)

        local val1 = settings.priceMultiplier[1] * 10
        local val2 = settings.priceMultiplier[2] * 10
        local priceMulti = math.random(val1, val2) / 10

        genDeals[#genDeals+1] = {
            label = randVeh.model:gsub("^%l", string.upper),
            value = randVeh.model,
            priceMultiplier = priceMulti,
            image = randVeh.img
        }
    end

    table.sort(genDeals, function(a, b)
        return a.priceMultiplier > b.priceMultiplier
    end)

    CachedData.desiredParts.parts = genDeals
    CachedData.desiredParts.lastGenerated = os.time()

    TriggerClientEvent("zyke_catalytic:SyncDesiredParts", -1, CachedData.desiredParts)
end