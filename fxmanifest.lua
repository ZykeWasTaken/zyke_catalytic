fx_version "cerulean"
game "gta5"
lua54 "yes"
version "1.0.0"
author "realzyke"

shared_scripts {
    "@ox_lib/init.lua",
    "@zyke_lib/imports.lua",

    "shared/config.lua",
    "shared/translationhandler.lua",
    "shared/functions.lua",

    "locales/*",
}

server_scripts {
    "server/main.lua",
    "server/functions.lua",
    "server/eventhandler.lua",
}

client_scripts {
    "@PolyZone/client.lua",
    "@PolyZone/BoxZone.lua",

    "client/main.lua",
    "client/eventhandler.lua",
    "client/functions.lua",
}

dependencies {
    "zyke_lib",
    "ox_lib",
    "PolyZone",
}