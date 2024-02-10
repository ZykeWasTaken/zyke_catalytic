CachedData = {}
CachedData.desiredParts = {
    lastGenerated = 0, -- os.time()
    parts = {
        --[[
            label = "Adder",
            value = "adder",
            priceMultiplier = 2.8
        ]]
    }
}

GlobalState["stolenCatalytics"] = {}
GlobalState["reservedCatalytics"] = {}

for item in pairs(Config.Settings.grinderItems) do
    Z.CreateUseableItem(item, function(source)
        local isBusy = Player(source).state["zyke_catalytic:Busy"] == true
        if (isBusy) then Notify("busy") return end

        -- Set as false in the client if anything goes wrong or finishes the action
        Player(source).state:set("zyke_catalytic:Busy", true, true)
        Wait(1)

        TriggerClientEvent("zyke_catalytic:UseItem", source, item)
    end)
end

--
-- Timers
--

CreateThread(function()
    while (true) do
        Wait(1000)

        if (CachedData.desiredParts.lastGenerated + Config.Settings.desiredParts.timeBetween < os.time()) then
            GenerateDesiredCatalytics()
        end
    end
end)