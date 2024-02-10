Translations["en"] = {
    ["busy"] = {msg = "You are already busy.", type = "error"},
    ["noVehicleNearby"] = {msg = "There is no valid vehicle nearby.", type = "error"},
    ["alreadyStolen"] = {msg = "Someone has already stolen the catalytic converter from this vehicle", type = "error"},
    ["alreadyReserved"] = {msg = "Someone is already stealing this catalytic converter.", type = "error"},
    ["failedMinigame"] = {msg = "You failed to remove the catalytic converter, focus up!", type = "error"},
    ["engineIsOn"] = {msg = "The engine is on, you can't work during these conditions.", type = "error"},
    ["successfulSteal"] = {msg = "You successfully cut off a %s!", type = "success"},
    ["cancelledMinigame"] = {msg = "Cancelled.", type = "success"},
    ["noItemsToSell"] = {msg = "Stop wasting my time, come back when you got my parts.", type = "primary"},
    ["somethingWentWrong"] = {msg = "Something went wrong, please try again.", type = "error"},
    ["successfulSell"] = {msg = "You sold %sx %s for %s.", type = "success"},
    ["policeAlert"] = {msg = "Active break-in on a %s with plate %s.", type = "info"}, -- %s = model, %s = plate -- TODO: THIS IS NOT WORKING!
    ["noItemAmount"] = {msg = "You don't have this item.", type = "error"},
    ["offerGone"] = {msg = "This offer can no longer be found.", type = "error"},

    -- Misc
    ["currency"] = "$%s",
    ["startStealing"] = "%s Start Stealing", -- %s = key
    ["loadingText"] = "Trying to find the catalytic converter...",
    ["cancel"] = "[%s] Cancel", -- %s = key
    ["talkToBuyerTarget"] = "Talk to %s", -- %s = buyer's name
    ["talkToBuyerKeyPress"] = "~g~[%s]~w~ Talk to %s", -- %s = key, %s = buyer's name
    ["completingDeal"] = "Negotiating Deal...",
    ["vehicleTheft"] = "Active Vehicle Theft",
    ["finishMinigameProgressBar"] = "Yanking off the catalytic converter...",
    ["metadataLabel"] = "Model - %s", -- %s = model name

    -- Robert menu
    ["robertMenuLabel"] = "What do you want to sell?",
    ["sellItemLabel"] = "Sell %s?",
    ["sellItemDesc"] = "Press to sell %sx %s for %s.",
    ["sellItemPriceEach"] = "Each: %s",
    ["desiredItemSellNoti"] = "%s Catalytic Converter",
    ["desiredItemLabel"] = "Sell %s Catalytic Converter?",
    ["desiredItemDesc"] = "Press to sell 1x %s Catalytic Converter for %s (%sx)", -- %s = catalytic name, %s = catalytic price, %s = price multiplier
    ["nothingToSell"] = "You don't have anything to sell.",
    ["desiredParts"] = "Desired Parts - Refreshes in %s%s", -- %s = time, %s = time format
    ["nothingDesired"] = "Robert is not urgent for any other parts.",

    -- Minigame
    ["keysToPress"] = "- [%s] -",
    ["timeLeft"] = "Time Left: %ss",
}