Config = Config or {}

Config.Settings = {
    language = "en",
    vehicleSound = "TORNADO6", -- Vehicle sound when your catalytic converter has beeen stolen
    keyToStart = "LEFTMOUSE", -- Press this inside of the polyzone
    drawPolyzone = true, -- true/false, draws a polyzone where you can start stealing
    miniGame = {
        totalClicks = 1,
        -- totalClicks = 1,
        timePerKey = 10.2,
        scrambleKeys = true, -- Scramble key order each time you click a key
        cancelKey = "X",
        keys = {
            -- {key = "Q", keyCode = 44},
            -- {key = "W", keyCode = 32},
            {key = "E", keyCode = 38},
            -- {key = "A", keyCode = 34},
            -- {key = "S", keyCode = 8},
            -- {key = "D", keyCode = 9},
        },
    },
    alert = {
        jobs = {"police", "police2"},
        alertChance = 30, -- Chance in percentage, set to 0 to disable
        vehicleAlarm = true, -- true/false, enables the vehicle alarm when you start stealing
        blipTime = 60, -- Time in seconds for the blip to be visible
    },
    grinderItems = {
        ["angle_grinder"] = {
            timeMultiplier = 1.0,
            totalClicksMultiplier = 1.0,
            model = "tr_prop_tr_grinder_01a",
            offsets = {x = 0.12, y = 0.09, z = -0.02},
            rotation = {x = 25.0, y = 0.0, z = 0.0},
        },
        ["advanced_angle_grinder"] = {
            timeMultiplier = 1.2, -- 20% more time
            totalClicksMultiplier = 0.8, -- 20% less clicks
            model = "xm3_prop_xm3_grinder_02a",
            offsets = {x = 0.12, y = 0.09, z = -0.02},
            rotation = {x = 25.0, y = 0.0, z = 0.0},
        },
    },
    -- List of items that you can sell to the buyer, you can add any item in here that exists on your server
    availableToSell = {
        {name ="small_catalytic_converter", price = 230},
        {name ="medium_catalytic_converter", price = 260},
        {name ="large_catalytic_converter", price = 300},
        {name ="gigantic_catalytic_converter", price = 350},
    },
    itemsForVehicleTypes = {
        -- Set to "none" to disable stealing for that vehicle class
        "small_catalytic_converter", -- Compacts
        "medium_catalytic_converter", -- Sedans
        "medium_catalytic_converter", -- SUVs
        "medium_catalytic_converter", -- Coupes
        "medium_catalytic_converter", -- Muscle
        "medium_catalytic_converter", -- Sports Classics
        "medium_catalytic_converter", -- Sports
        "medium_catalytic_converter", -- Super
        "small_catalytic_converter", -- Motorcycles
        "medium_catalytic_converter", -- Off-road
        "large_catalytic_converter", -- Industrial
        "medium_catalytic_converter", -- Utility
        "medium_catalytic_converter", -- Vans
        "none", -- Cycles
        "medium_catalytic_converter", -- Boats
        "large_catalytic_converter", -- Helicopters
        "gigantic_catalytic_converter", -- Planes
        "large_catalytic_converter", -- Service
        "medium_catalytic_converter", -- Emergency
        "large_catalytic_converter", -- Military
        "large_catalytic_converter", -- Commercial
        "none", -- Trains
        "none" -- Open Wheel
    },
    buyer = {
        enabled = true,
        name = "Robert",
        model = "mp_m_waremech_01",
        pos = vec4(-1151.4918212891, -1992.7900390625, 13.160345077515, 47.0944480896),
        anim = {dict = "WORLD_HUMAN_LEANING", name = ""}, -- Leave name as an empty string or nil to run a scenario
        dealTime = 0, -- Time in seconds to wait for the deal to be completed
        playerAnim = {dict = "misscarsteal3", name = "racer_argue_01_a"}, -- Same as anim above, but plays for your ped when you are negotiating
        talkKey = "E", -- Only used if you don't have a target menu
        blip = {
            enabled = true,
            sprite = 739,
            color = 5,
            scale = 0.8,
        }
    },
    intervals = {
        -- A list of extra intervals, made for easy configuration
        -- In seconds
        findingCatalytic = 0,
        finishMinigameProgressBar = 0,
    },
    desiredParts = {
        deals = 4,
        timeBetween = 3600, -- In seconds
        priceMultiplier = {2.0, 5.0}, -- Random value between these two for each deal
        vehicles = {
            -- All vehicles in this list can spawn around the city
            {
                model = "adder",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1205022868912742460/adder.png?ex=65d6dc00&is=65c46700&hm=e8051b5f297156b41c789162adf6b9a2cb377f73f371a50259cdd59cbbef5287&",
            },
            {
                model = "surge",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1205023029529415690/surge.png?ex=65d6dc26&is=65c46726&hm=aef8044bfc668c4c8f6a9a7bb4b0afdbfa4bda1efa92622458fadbb70c851651&",
            },
            {
                model = "sabregt",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1205023556161900575/sabregt.png?ex=65d6dca4&is=65c467a4&hm=389ab465a6b24cc00fad31bb4910ca3745763f42caa048be20d32d436e7a5c3e&",
            },
            {
                model = "penumbra",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1205023110030557224/penumbra.png?ex=65d6dc39&is=65c46739&hm=4fb027bd59011cdc504e627b13bec7e52aa1707b2cdde326b787196f7636c703&",
            },
            {
                model = "asterope",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1205023174090035210/asterope.png?ex=65d6dc48&is=65c46748&hm=7af0355d32229ee86e66e9d84427aed3352a8cf308dc21a4402ffafd282035c1&",
            },
            {
                model = "huntley",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1205023311399100457/huntley-s.png?ex=65d6dc69&is=65c46769&hm=913864a126a0ba698fc8354385a7c58e6d4aadfab7897437fd870a668343e7b8&",
            },
            {
                model = "surano",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1205022653052882954/surano.png?ex=65d6dbcc&is=65c466cc&hm=fb9a926efaae821a0e78eb3cf9f74c5fa04f8ddef1c250e8d773db9327252177&",
            },
        }
    }
}