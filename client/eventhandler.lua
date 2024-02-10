RegisterNetEvent("zyke_catalytic:UseItem", function(item)
    EquipGrinder(item)
end)

-- Anti-sketchy stuff
RegisterNetEvent("zyke_lib:OnCharacterLogout", function()
    ResetBusy()
end)

local blips = {}
---@param netId number
---@param pos vector3
---@param plate string
---@param model string
RegisterNetEvent("zyke_catalytic:HandleAlert", function(netId, pos, plate, model)
    if (blips[netId]) then return end -- If the blip already exists for some reason

    local formattedModelName = string.lower(model):gsub("^%l", string.upper)
    Notify("policeAlert", {formattedModelName, plate})

    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(T("vehicleTheft"))
    EndTextCommandSetBlipName(blip)

    blips[netId] = blip
    Wait(Config.Settings.alert.blipTime * 1000)
    RemoveBlip(blip)
    blips[netId] = nil
end)

-- Catch inventory changes and make sure you still have the grinder you are using
-- If you no longer have the grinder, trigger the equip function as it toggles the grinder
RegisterNetEvent("zyke_lib:InventoryUpdated", function()
    Wait(100) -- Wait to make sure everything is updated properly before checking

    if (CachedData.equipped.name ~= nil) then
        local hasItem = Z.HasItem(CachedData.equipped.name, 1)

        if (not hasItem) then
            EquipGrinder(CachedData.equipped.name)
        end
    end
end)

RegisterNetEvent("zyke_catalytic:ResetVehicleSound", function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if (not vehicle) then return end

    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    if (not model) then return end

    ForceVehicleEngineAudio(vehicle, model)
end)

RegisterNetEvent("zyke_catalytic:SyncDesiredParts", function(desiredParts)
    CachedData.desiredParts = desiredParts

    -- If in the sell menu, re-open it
    local menuId = lib.getOpenContextMenu()
    if (menuId == "zyke_catalytic:sell") then
        ResetBusy()
        TalkToBuyer()
    end
end)