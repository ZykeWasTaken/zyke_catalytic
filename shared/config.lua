Config = Config or {}

Config.Settings = {
    language = "en",
    vehicleSound = "TORNADO6",
    keyToStart = "LEFTMOUSE",
    drawPolyzone = true,
    repairJobs = {"mechanic", "mechanic2"},
    miniGame = {
        totalClicks = 15,
        timePerKey = 1.8,
        scrambleKeys = true,
        cancelKey = "X",
        keys = {"Q", "W", "E", "A", "S", "D"},
    },
    alert = {
        jobs = {"police", "police2"},
        alertChance = 30,
        vehicleAlarm = true,
        blipTime = 60, -- s
        delay = {min = 15, max = 45}, -- s
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
            timeMultiplier = 1.2,
            totalClicksMultiplier = 0.8,
            model = "xm3_prop_xm3_grinder_02a",
            offsets = {x = 0.12, y = 0.09, z = -0.02},
            rotation = {x = 25.0, y = 0.0, z = 0.0},
        },
    },
    availableToSell = {
        {name ="small_catalytic_converter", price = 230},
        {name ="medium_catalytic_converter", price = 260},
        {name ="large_catalytic_converter", price = 300},
        {name ="gigantic_catalytic_converter", price = 350},
    },
    itemsForVehicleTypes = {
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
        pos = vec4(-1151.49, -1992.79, 13.16, 47.09),
        anim = {dict = "WORLD_HUMAN_LEANING", name = nil},
        dealTime = 10, -- s
        playerAnim = {dict = "misscarsteal3", name = "racer_argue_01_a"},
        talkKey = "E", -- Only used if you don't have a target menu
        blip = {
            enabled = true,
            sprite = 739,
            color = 5,
            scale = 0.8,
        }
    },
    intervals = {
        findingCatalytic = 10,
        finishMinigameProgressBar = 10,
    },
    desiredParts = {
        deals = 4,
        timeBetween = 3600, -- s
        priceMultiplier = {2.0, 5.0},
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
            {
                model = "radi",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1206044520681312307/radi.png?ex=65da937c&is=65c81e7c&hm=15ef7a2ef2198e84986bb05e2871e744972c19c22b79a9e73021f4c81ebe165f&",
            },
            {
                model = "minivan",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1206045569496383518/minivan.png?ex=65da9477&is=65c81f77&hm=33c759b91d3ebc63ea037a2eb58de141fab2edc631f785a1a42c8b21ac8eef6e&"
            },
            {
                model = "granger",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1206045796932255764/granger.png?ex=65da94ad&is=65c81fad&hm=2592dc66b2e126a4df5a8b783216a25342d4ca7e7d145852fe36260dd8381e7e&",
            },
            {
                model = "stratum",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1206046002855936100/stratum.png?ex=65da94de&is=65c81fde&hm=18cbe217533b76ef69cbee57fb95d6e58a462e721c71e8288f1039295d8caea8&",
            },
            {
                model = "bjxl",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1206046243252600883/bjxl.png?ex=65da9517&is=65c82017&hm=5211a0a8fa4a7bb80ca754725b89bc463ede3a8ab1a1921ab245534a96bd9edf&",
            },
            {
                model = "bfinjection",
                img = "https://cdn.discordapp.com/attachments/930979289011195924/1206046604390563861/bfinjection.png?ex=65da956d&is=65c8206d&hm=557796e54a5a0a4e47ba847f0fbb41965507876c1b56e4b619100bdeb1fb94e3&",
            }
        }
    }
}