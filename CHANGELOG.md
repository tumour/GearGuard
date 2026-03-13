# Changelog

## [1.0.1] - 2026-03-14

### Fixed
- Fixed taint issue causing "action blocked" errors (Hearthstone, item usage, etc.)
- Replaced direct `C_Container.UseContainerItem` override with safe `hooksecurefunc` post-hook
- Sell protection now uses auto-buyback approach instead of blocking the sale

### Changed
- Confirmation dialog now offers to buyback the item after it's sold (instead of blocking the sale)
- Dialog auto-closes after 15 seconds if no action taken

## [1.0.0] - 2026-03-14

### Added
- Bag highlights for items belonging to Equipment Sets (orange-red border + shield icon)
- Sell protection at vendors with confirmation popup
- Tooltip info showing which equipment set(s) an item belongs to
- Slash commands: `/gg` (toggle highlights), `/gg help`
- Localization: English (enUS) and Russian (ruRU)
