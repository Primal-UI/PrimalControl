local addonName, addon = ...
-- Don't change the environment. The pasted file should be executed in the global one.

if not _G.IsAddOnLoaded("Blizzard_BattlefieldMinimap") then
   _G.LoadAddOn("Blizzard_BattlefieldMinimap")
end

_G.assert(_G.IsAddOnLoaded("Blizzard_BattlefieldMinimap"))

-- Contents of automatically generated file Blizzard_BattlefieldMinimap.lua follow -------------------------------------
------------------------------------------------------------------------------------------------------------------------
BattlefieldMinimapOptions = {
	["locked"] = true,
	["opacity"] = 0.5,
	["position"] = {
		["x"] = 1740,
		["y"] = 291,
	},
	["showPlayers"] = true,
}
------------------------------------------------------------------------------------------------------------------------

-- This is necessary to get Blizzard_BattlefieldMinimap to save our new BattlefieldMinimapOptions table. It will use
-- this position to overwrite BattlefieldMinimapOptions.position.x (and y) on PLAYER_LOGOUT. The alternative to this
-- would be to make sure our table is used on PLAYER_LOGOUT but after (!) Blizzard_BattlefieldMinimap responded to the
-- event, so that's a bit hacky as well...
_G.BattlefieldMinimapTab:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", _G.BattlefieldMinimapOptions.position.x,
    _G.BattlefieldMinimapOptions.position.y)

-- vim: tw=120 sts=2 sw=2 et
