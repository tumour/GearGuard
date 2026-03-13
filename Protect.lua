local ADDON_NAME, ns = ...
local L = ns.L
local GearGuard = ns.GearGuard

-- ============================================================
-- Protect module — auto-buyback equipment set items sold at vendor
-- Uses hooksecurefunc to avoid tainting secure functions
-- ============================================================
local Protect = {}
GearGuard:RegisterModule("Protect", Protect)

local merchantOpen = false

-- ============================================================
-- Track merchant window state
-- ============================================================
GearGuard:RegisterEvent("MERCHANT_SHOW", function()
    merchantOpen = true
end)

GearGuard:RegisterEvent("MERCHANT_CLOSED", function()
    merchantOpen = false
end)

-- ============================================================
-- Buyback confirmation dialog
-- ============================================================
StaticPopupDialogs["GEARGUARD_SOLD_PROTECTED"] = {
    text = "%s",
    button1 = L["CONFIRM_YES"],
    button2 = L["CONFIRM_NO"],
    OnAccept = function(self, data)
        if data and data.buybackIndex and merchantOpen then
            BuybackItem(data.buybackIndex)
        end
    end,
    timeout = 15,
    whileDead = false,
    hideOnEscape = true,
    preferredIndex = 3,
    showAlert = true,
}

-- ============================================================
-- Post-hook: detect when a protected item is sold
-- Runs AFTER UseContainerItem — no taint
-- ============================================================
hooksecurefunc(C_Container, "UseContainerItem", function(bag, slot)
    if not merchantOpen then return end

    -- The item is already sold at this point
    -- Check the last buyback slot (most recently sold)
    local numBuyback = GetNumBuybackItems()
    if numBuyback == 0 then return end

    local link = GetBuybackItemLink(numBuyback)
    if not link then return end

    local itemID = GetItemInfoInstant(link)
    if not itemID or not ns.IsProtected(itemID) then return end

    -- Item is from an equipment set — offer buyback
    local setNames = ns.GetSetNames(itemID)
    local text = format(L["CONFIRM_SELL_TEXT"], link, setNames)

    local dialog = StaticPopup_Show("GEARGUARD_SOLD_PROTECTED", text)
    if dialog then
        dialog.data = { buybackIndex = numBuyback }
    end
end)
