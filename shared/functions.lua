-- Function to retrieve if it has already been stolen
-- You may need to modify this based on other factors such as your garage script
---@param netId number
---@return boolean, boolean -- stolen, reserved
function GetCatalyticState(netId)
    local vehDoesExist = IsDuplicityVersion() and true or NetworkDoesEntityExistWithNetworkId(netId)
    local vehHandler = vehDoesExist and NetworkGetEntityFromNetworkId(netId) or nil
    if (not vehHandler) then return true, true end -- true will prevent the player from stealing it, in case the vehicle does not exist for some reason

    local plate = GetVehicleNumberPlateText(vehHandler)
    local hasBeenStolen = GlobalState["stolenCatalytics"][plate] ~= nil
    local isReserved = GlobalState["reservedCatalytics"][plate] ~= nil

    return hasBeenStolen, isReserved
end

---@param notifyStr string
---@param formatting table?
function Notify(notifyStr, formatting)
    Z.Notify(T(notifyStr, formatting))
end

function FormatCurrency(value)
    return T("currency", {value})
end