local ADDON_NAME, ns = ...
local L = ns.L

-- ============================================================
-- Addon singleton
-- ============================================================
local GearGuard = {}
GearGuard.name = ADDON_NAME
GearGuard.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
GearGuard.enabled = true
ns.GearGuard = GearGuard

-- ============================================================
-- Module registry
-- ============================================================
local modules = {}

function GearGuard:RegisterModule(name, module)
    modules[name] = module
end

function GearGuard:GetModule(name)
    return modules[name]
end

-- ============================================================
-- Event bus
-- ============================================================
local eventFrame = CreateFrame("Frame")
local eventHandlers = {}

function GearGuard:RegisterEvent(event, callback)
    if not eventHandlers[event] then
        eventHandlers[event] = {}
        eventFrame:RegisterEvent(event)
    end
    table.insert(eventHandlers[event], callback)
end

function GearGuard:UnregisterEvent(event)
    eventHandlers[event] = nil
    eventFrame:UnregisterEvent(event)
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    local handlers = eventHandlers[event]
    if handlers then
        for _, callback in ipairs(handlers) do
            callback(event, ...)
        end
    end
end)

-- ============================================================
-- Equipment set item cache
-- ============================================================
-- protectedItems[itemID] = { setName1, setName2, ... }
local protectedItems = {}
ns.protectedItems = protectedItems

local function RebuildCache()
    wipe(protectedItems)

    local setIDs = C_EquipmentSet.GetEquipmentSetIDs()
    for _, setID in ipairs(setIDs) do
        local name = C_EquipmentSet.GetEquipmentSetInfo(setID)
        local itemIDs = C_EquipmentSet.GetItemIDs(setID)

        if itemIDs then
            for _, itemID in pairs(itemIDs) do
                if itemID and itemID > 0 then
                    if not protectedItems[itemID] then
                        protectedItems[itemID] = {}
                    end
                    -- Avoid duplicate set names
                    local found = false
                    for _, n in ipairs(protectedItems[itemID]) do
                        if n == name then found = true; break end
                    end
                    if not found then
                        table.insert(protectedItems[itemID], name)
                    end
                end
            end
        end
    end
end

ns.RebuildCache = RebuildCache

function ns.IsProtected(itemID)
    return itemID and protectedItems[itemID] ~= nil
end

function ns.GetSetNames(itemID)
    local sets = protectedItems[itemID]
    if sets then
        return table.concat(sets, ", ")
    end
    return ""
end

-- ============================================================
-- Initialization
-- ============================================================
GearGuard:RegisterEvent("PLAYER_LOGIN", function()
    RebuildCache()
    print(L["ADDON_LOADED"])
end)

GearGuard:RegisterEvent("EQUIPMENT_SETS_CHANGED", function()
    RebuildCache()
    -- Notify Highlight module to refresh
    local highlight = GearGuard:GetModule("Highlight")
    if highlight and highlight.UpdateAllBags then
        highlight:UpdateAllBags()
    end
end)

GearGuard:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function()
    RebuildCache()
    local highlight = GearGuard:GetModule("Highlight")
    if highlight and highlight.UpdateAllBags then
        highlight:UpdateAllBags()
    end
end)

-- ============================================================
-- Slash commands
-- ============================================================
SLASH_GEARGUARD1 = "/gg"
SlashCmdList["GEARGUARD"] = function(msg)
    msg = strtrim(msg):lower()

    if msg == "help" then
        print(L["SLASH_HELP"])
    else
        -- Toggle highlights
        GearGuard.enabled = not GearGuard.enabled
        if GearGuard.enabled then
            print(L["HIGHLIGHT_ON"])
        else
            print(L["HIGHLIGHT_OFF"])
        end
        local highlight = GearGuard:GetModule("Highlight")
        if highlight and highlight.UpdateAllBags then
            highlight:UpdateAllBags()
        end
    end
end
