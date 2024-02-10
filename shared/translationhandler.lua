-- File to handle translations, do not touch anything
Translations = {}
HasInitializedTranslations = false

---@param key string
---@param formatting table<string | number>?
---@return string | table -- Table if it is for a notification, and it will contain msg & type
function T(key, formatting)
    return TranslationsHandler.Translate(key, formatting)
end

CreateThread(function()
    local translations
    local lang = Config.Settings.language or "en"

    repeat
        translations = Translations[lang]
        Wait(25)
    until translations ~= nil

    TranslationsHandler.InitializeTranslation(translations)
    HasInitializedTranslations = true
end)