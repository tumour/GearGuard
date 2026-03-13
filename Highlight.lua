local ADDON_NAME, ns = ...
local L = ns.L
local GearGuard = ns.GearGuard

-- ============================================================
-- Highlight module — overlays on bag items from equipment sets
-- ============================================================
local Highlight = {}
GearGuard:RegisterModule("Highlight", Highlight)

-- Cache of overlay frames keyed by "bag:slot"
local overlays = {}

-- ============================================================
-- Overlay creation
-- ============================================================
local function GetOrCreateOverlay(button, bag, slot)
    local key = bag .. ":" .. slot
    if overlays[key] then
        overlays[key]:SetParent(button)
        overlays[key]:SetAllPoints(button)
        return overlays[key]
    end

    local overlay = CreateFrame("Frame", nil, button, "BackdropTemplate")
    overlay:SetAllPoints(button)
    overlay:SetFrameLevel(button:GetFrameLevel() + 2)

    -- Red-orange border
    overlay:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    overlay:SetBackdropBorderColor(1, 0.3, 0, 0.9) -- orange-red

    -- Small icon indicator in top-right corner
    local icon = overlay:CreateTexture(nil, "OVERLAY")
    icon:SetTexture("Interface\\Icons\\INV_Shield_11")
    icon:SetSize(12, 12)
    icon:SetPoint("TOPRIGHT", overlay, "TOPRIGHT", -1, -1)
    overlay.icon = icon

    overlays[key] = overlay
    return overlay
end

-- ============================================================
-- Update a single bag slot
-- ============================================================
local function UpdateSlot(button, bag, slot)
    local key = bag .. ":" .. slot
    local overlay = overlays[key]

    if not GearGuard.enabled then
        if overlay then overlay:Hide() end
        return
    end

    local info = C_Container.GetContainerItemInfo(bag, slot)
    if info and info.itemID and ns.IsProtected(info.itemID) then
        overlay = GetOrCreateOverlay(button, bag, slot)
        overlay:Show()
    else
        if overlay then overlay:Hide() end
    end
end

-- ============================================================
-- Scan all bag slots
-- ============================================================
function Highlight:UpdateAllBags()
    -- Hide all existing overlays first
    for _, overlay in pairs(overlays) do
        overlay:Hide()
    end

    if not GearGuard.enabled then return end

    for bag = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemButton = Highlight:GetItemButton(bag, slot)
            if itemButton then
                UpdateSlot(itemButton, bag, slot)
            end
        end
    end
end

-- ============================================================
-- Find the item button for a bag/slot
-- ============================================================
function Highlight:GetItemButton(bag, slot)
    -- Modern Retail bag frames (ContainerFrameCombinedBags or individual)
    -- Try combined bags first (if player uses "Combined Bags" view)
    if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsShown() then
        local items = ContainerFrameCombinedBags.Items
        if items then
            for _, itemButton in ipairs(items) do
                if itemButton:GetBagID() == bag and itemButton:GetID() == slot then
                    return itemButton
                end
            end
        end
    end

    -- Individual bag frames
    local containerFrame = _G["ContainerFrame" .. (bag + 1)]
    if containerFrame and containerFrame:IsShown() then
        local items = containerFrame.Items
        if items then
            for _, itemButton in ipairs(items) do
                if itemButton:GetID() == slot then
                    return itemButton
                end
            end
        end
    end

    return nil
end

-- ============================================================
-- Hook into bag updates
-- ============================================================
GearGuard:RegisterEvent("BAG_UPDATE", function(event, bagID)
    if bagID and bagID >= 0 and bagID <= 4 then
        C_Timer.After(0.05, function()
            Highlight:UpdateAllBags()
        end)
    end
end)

-- Hook container frame open/close to refresh overlays
if ContainerFrameCombinedBags then
    hooksecurefunc(ContainerFrameCombinedBags, "Show", function()
        C_Timer.After(0.1, function()
            Highlight:UpdateAllBags()
        end)
    end)
end

-- Hook individual container frames
for i = 1, 5 do
    local frame = _G["ContainerFrame" .. i]
    if frame then
        hooksecurefunc(frame, "Show", function()
            C_Timer.After(0.1, function()
                Highlight:UpdateAllBags()
            end)
        end)
    end
end

-- Refresh when bags are opened
GearGuard:RegisterEvent("BAG_OPEN", function()
    C_Timer.After(0.1, function()
        Highlight:UpdateAllBags()
    end)
end)

-- ============================================================
-- Tooltip hook — show equipment set info on hover
-- ============================================================
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if not GearGuard.enabled then return end
    if not data or not data.id then return end

    local itemID = data.id
    if ns.IsProtected(itemID) then
        local setNames = ns.GetSetNames(itemID)
        tooltip:AddLine(format(L["TOOLTIP_EQUIPMENT_SET"], setNames), 1, 0.5, 0)
    end
end)
