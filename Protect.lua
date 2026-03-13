local ADDON_NAME, ns = ...
local L = ns.L
local GearGuard = ns.GearGuard

-- ============================================================
-- Protect module — block selling equipment set items at vendor
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
-- Confirmation dialog
-- ============================================================
StaticPopupDialogs["GEARGUARD_CONFIRM_SELL"] = {
    text = "%s",
    button1 = L["CONFIRM_YES"],
    button2 = L["CONFIRM_NO"],
    OnAccept = function(self, data)
        if data and data.bag and data.slot then
            -- Temporarily unhook to avoid recursion
            Protect.selling = true
            C_Container.UseContainerItem(data.bag, data.slot)
            Protect.selling = false
        end
    end,
    timeout = 0,
    whileDead = false,
    hideOnEscape = true,
    preferredIndex = 3,
    showAlert = true,
}

-- ============================================================
-- Hook UseContainerItem to intercept sells
-- ============================================================
local originalUseContainerItem = C_Container.UseContainerItem

C_Container.UseContainerItem = function(bag, slot, ...)
    -- Skip if we're in the confirmed sell flow
    if Protect.selling then
        return originalUseContainerItem(bag, slot, ...)
    end

    -- Only intercept when merchant is open
    if not merchantOpen then
        return originalUseContainerItem(bag, slot, ...)
    end

    -- Check if the item is protected
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info and info.itemID and ns.IsProtected(info.itemID) then
        local itemLink = C_Container.GetContainerItemLink(bag, slot)
        local setNames = ns.GetSetNames(info.itemID)
        local text = format(L["CONFIRM_SELL_TEXT"], itemLink or "?", setNames)

        local dialog = StaticPopup_Show("GEARGUARD_CONFIRM_SELL", text)
        if dialog then
            dialog.data = { bag = bag, slot = slot }
        end
        return -- Block the sell
    end

    -- Not protected — sell normally
    return originalUseContainerItem(bag, slot, ...)
end
