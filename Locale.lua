local ADDON_NAME, ns = ...

-- Default locale (enUS) with __index fallback
local L = setmetatable({}, {
    __index = function(t, key)
        return key
    end,
})
ns.L = L

-- ============================================================
-- enUS (default)
-- ============================================================
L["ADDON_LOADED"]       = "|cff00ff00GearGuard|r loaded. Type |cfffff569/gg|r for help."
L["ADDON_TITLE"]        = "GearGuard"

L["SLASH_HELP"]         = "|cff00ff00GearGuard|r commands:\n"
                        .. "  |cfffff569/gg|r — toggle highlights\n"
                        .. "  |cfffff569/gg help|r — show this help"

L["HIGHLIGHT_ON"]       = "|cff00ff00GearGuard|r highlights |cff00ff00enabled|r."
L["HIGHLIGHT_OFF"]      = "|cff00ff00GearGuard|r highlights |cffff0000disabled|r."

L["CONFIRM_SELL_TEXT"]   = "Are you sure you want to sell:\n\n%s\n\nThis item is part of equipment set(s):\n|cffff8000%s|r"
L["CONFIRM_YES"]         = "Sell"
L["CONFIRM_NO"]          = "Cancel"

L["TOOLTIP_EQUIPMENT_SET"] = "Equipment set: |cffff8000%s|r"

-- ============================================================
-- ruRU
-- ============================================================
if GetLocale() == "ruRU" then
    L["ADDON_LOADED"]       = "|cff00ff00GearGuard|r загружен. Введите |cfffff569/gg|r для справки."

    L["SLASH_HELP"]         = "|cff00ff00GearGuard|r команды:\n"
                            .. "  |cfffff569/gg|r — вкл/выкл подсветку\n"
                            .. "  |cfffff569/gg help|r — показать справку"

    L["HIGHLIGHT_ON"]       = "|cff00ff00GearGuard|r подсветка |cff00ff00включена|r."
    L["HIGHLIGHT_OFF"]      = "|cff00ff00GearGuard|r подсветка |cffff0000выключена|r."

    L["CONFIRM_SELL_TEXT"]   = "Вы уверены, что хотите продать:\n\n%s\n\nЭтот предмет входит в набор(ы) экипировки:\n|cffff8000%s|r"
    L["CONFIRM_YES"]         = "Продать"
    L["CONFIRM_NO"]          = "Отмена"

    L["TOOLTIP_EQUIPMENT_SET"] = "Набор экипировки: |cffff8000%s|r"
end
