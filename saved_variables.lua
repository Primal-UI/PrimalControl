local addonName, addon = ...
setfenv(1, addon)

-- We will enable these addons and configure some of them.
addons = {
  "!BugGrabber",
  "Bartender4",
  "Blizzard_BattlefieldMinimap",
  "Bugger",
  "Chatter",
  --"DamnUnitSounds",
  --"DuelCountdown",
  "MapCoords",
  "MikScrollingBattleText",
  "MinimapRange",
  --"MSBTOptions",
  "OmniBar",
  --"OmniBar_Options",
  "OmniCC",
  --"OmniCC_Config",
  "OPie",
  "SafeQueue",
  "SellJunk",
  "SexyMap",
  "TellMeWhen",
  --"TellMeWhen_Options",
  "TidyPlates",
  "TidyPlatesHub",
  "TidyPlatesWidgets",
  --"TidyPlates_Neon", -- Doesn't have SavedVariables.
  "WeakAuras",
  --"WeakAurasModelPaths",
  --"WeakAurasOptions",
  --"WeakAurasTutorials",
}

setupFunctions = {}

function addon.configureAddon(addon)
  local loaded, reason = _G.IsAddOnLoaded(addon)

  if not loaded then
    print("Trying to load \"" .. addon .. '"')
    loaded, reason = _G.LoadAddOn(addon)
    if not loaded and reason == "DISABLED" then
      print("Enabling \"" .. addon .. '"')
      _G.EnableAddOn(addon)
      -- We could still call LoadAddOn() even when the addon isn't load-on-demand and this doesn't usually seem to
      -- report that loading failed.  IsAddOnLoadOnDemand() also returns true.  I'm not sure whether or not this is a
      -- good idea.
      if _G.IsAddOnLoadOnDemand(addon) then
        loaded, reason = _G.LoadAddOn(addon)
      end
    end
  end

  if loaded then
    if setupFunctions[addon] then
      print("Configuring \"" .. addon .. '"')
      setupFunctions[addon]()
    end
  else
    print("Couldn't load \"" .. addon .. "\": " .. reason)
  end
end

function addon.configureAllAddons()
  for i = 1, #addons do
    configureAddon(addons[i])
  end
  print("Some AddOn settings aren't applied until reloading the UI.")
end

setupFunctions["Blizzard_BattlefieldMinimap"] = function()
  _G.assert(_G.IsAddOnLoaded("Blizzard_BattlefieldMinimap"))

  _G.BattlefieldMinimapOptions = BattlefieldMinimapOptions

  -- This is necessary to get Blizzard_BattlefieldMinimap to save our new BattlefieldMinimapOptions table.  It will use
  -- this position to overwrite BattlefieldMinimapOptions.position.x (and y) on PLAYER_LOGOUT.  The alternative to this
  -- would be to make sure our table is used on PLAYER_LOGOUT but after (!) Blizzard_BattlefieldMinimap responded to the
  -- event, so that's a bit hacky as well...
  _G.BattlefieldMinimapTab:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", _G.BattlefieldMinimapOptions.position.x,
    _G.BattlefieldMinimapOptions.position.y)
end

setupFunctions["OmniCC"] = function()
   _G.assert(_G.OmniCC4Config and OmniCC4Config)
   onPlayerLogout[#onPlayerLogout + 1] = function()
      _G.OmniCC4Config = OmniCC4Config
   end
end

setupFunctions["SexyMap"] = function()
   _G.assert(_G.SexyMap2DB and SexyMap2DB)
   onPlayerLogout[#onPlayerLogout + 1] = function()
      -- SexyMap doesn't do anything on PLAYER_LOGOUT so this should work.  I.e., there should be no risk of SexyMap
      -- overwriting these changes to SexyMap2DB.
      local char = (_G.UnitName("player") .. "-" .. _G.GetRealmName())
      _G.SexyMap2DB["global"] = SexyMap2DB["global"]
      _G.SexyMap2DB[char] = "global"
   end
end

-- Blizzard_BattlefieldMinimap.lua -------------------------------------------------------------------------------------
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

-- SavedVariables/OmniCC.lua -------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
OmniCC4Config = {
	["engine"] = "AniUpdater",
	["groups"] = {
		{
			["id"] = "TellMeWhen",
			["rules"] = {
				"TellMeWhen", -- [1]
			},
			["enabled"] = true,
		}, -- [1]
		{
			["id"] = "WeakAuras",
			["rules"] = {
				"WeakAuras", -- [1]
			},
			["enabled"] = true,
		}, -- [2]
		{
			["id"] = "OmniBar",
			["rules"] = {
				"OmniBar", -- [1]
			},
			["enabled"] = true,
		}, -- [3]
		--[[
		{
			["id"] = "Ignore",
			["rules"] = {
				"LossOfControl", -- [1]
				"TotemFrame", -- [2]
			},
			["enabled"] = true,
		}, -- [4]
		]]
	},
	["groupSettings"] = {
		["base"] = {
			["enabled"] = false,
			["fontFace"] = "Interface\\AddOns\\PrimalMedia\\fonts\\UbuntuMono-B.ttf",
			["effect"] = "none",
			["minDuration"] = 2,
			["minEffectDuration"] = 0,
			["minSize"] = 0,
			["spiralOpacity"] = 1,
			["yOff"] = 2,
			["xOff"] = 0,
			["tenthsDuration"] = 0,
			["fontOutline"] = "OUTLINE",
			["anchor"] = "BOTTOM",
			["mmSSDuration"] = 0,
			["scaleText"] = false,
			["fontSize"] = 14,
			["styles"] = {
				["soon"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 1,
				},
				["seconds"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 1,
				},
				["hours"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["charging"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["minutes"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["controlled"] = {
				},
			},
		},
		["WeakAuras"] = {
			["enabled"] = true,
			["fontFace"] = "Interface\\AddOns\\PrimalMedia\\fonts\\UbuntuMono-B.ttf",
			["effect"] = "none",
			["scaleText"] = false,
			["mmSSDuration"] = 0,
			["anchor"] = "BOTTOM",
			["spiralOpacity"] = 0,
			["minDuration"] = 2,
			["xOff"] = 0,
			["tenthsDuration"] = 0,
			["fontOutline"] = "OUTLINE",
			["minSize"] = 0,
			["minEffectDuration"] = 0,
			["yOff"] = 2,
			["fontSize"] = 14,
			["styles"] = {
				["minutes"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["soon"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 1,
				},
				["hours"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["charging"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["seconds"] = {
					["scale"] = 1,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 1,
				},
				["controlled"] = {
				},
			},
		},
		["OmniBar"] = {
			["enabled"] = true,
			["fontFace"] = "Interface\\AddOns\\PrimalMedia\\fonts\\UbuntuMono-B.ttf",
			["effect"] = "none",
			["scaleText"] = false,
			["mmSSDuration"] = 0,
			["anchor"] = "BOTTOM",
			["spiralOpacity"] = 0,
			["minDuration"] = 2,
			["xOff"] = 0,
			["tenthsDuration"] = 0,
			["fontOutline"] = "OUTLINE",
			["minSize"] = 0,
			["minEffectDuration"] = 0,
			["yOff"] = 1,
			["fontSize"] = 14,
			["styles"] = {
				["minutes"] = {
					["scale"] = 1.25,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["soon"] = {
					["scale"] = 1.25,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 1,
				},
				["hours"] = {
					["scale"] = 1.25,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["charging"] = {
					["scale"] = 1.25,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["seconds"] = {
					["scale"] = 1.25,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 1,
				},
				["controlled"] = {
				},
			},
		},
		["TellMeWhen"] = {
			["enabled"] = true,
			["fontFace"] = "Interface\\AddOns\\PrimalMedia\\fonts\\UbuntuMono-B.ttf",
			["effect"] = "none",
			["scaleText"] = false,
			["mmSSDuration"] = 0,
			["anchor"] = "BOTTOM",
			["spiralOpacity"] = 1,
			["minDuration"] = 2,
			["xOff"] = 0,
			["tenthsDuration"] = 0,
			["fontOutline"] = "OUTLINE",
			["minSize"] = 0,
			["minEffectDuration"] = 0,
			["yOff"] = 2,
			["fontSize"] = 14,
			["styles"] = {
				["minutes"] = {
					["scale"] = 0.9375, -- 30 / 32
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["soon"] = {
					["scale"] = 0.9375,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 1,
				},
				["hours"] = {
					["scale"] = 0.9375,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["charging"] = {
					["scale"] = 0.9375,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 0,
				},
				["seconds"] = {
					["scale"] = 0.9375,
					["r"] = 1,
					["g"] = 1,
					["b"] = 1,
					["a"] = 1,
				},
				["controlled"] = {
				},
			},
		},
	},
	["version"] = "6.0.9",
}
------------------------------------------------------------------------------------------------------------------------

-- SavedVariables/SexyMap.lua (incomplete) -----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
SexyMap2DB = {
	["global"] = {
		["core"] = {
			["clamp"] = false,
			["scale"] = 1,
			["autoZoom"] = 0,
			["northTag"] = false,
			["point"] = "BOTTOM",
			["y"] = 8,
			["x"] = 0,
			["lock"] = true,
			["relpoint"] = "BOTTOM",
			["shape"] = "Interface\\AddOns\\PrimalMedia\\minimap\\shapes\\ninja_kitty_blank.tga",
			["rightClickToConfig"] = false,
		},
		["ping"] = {
			["showPing"] = false,
			["showAt"] = "chat",
		},
		["coordinates"] = {
			["enabled"] = false,
			["locked"] = false,
			["font"] = "Ubuntu Mono Bold",
			["fontSize"] = 11,
			["fontColor"] = {
			},
			["borderColor"] = {
				["a"] = 0,
				["r"] = 0,
				["g"] = 0,
				["b"] = 0,
			},
			["backgroundColor"] = {
				["a"] = 0,
				["r"] = 0,
				["g"] = 0,
				["b"] = 0,
			},
		},
		["buttons"] = {
			["lockDragging"] = false,
			["allowDragging"] = true,
			["radius"] = 2,
			["TEMP"] = true,
			["TEMP2"] = true,
			["controlVisibility"] = true,
			["visibilitySettings"] = {
				["MiniMapChallengeMode"] = "hover",
				["MiniMapRecordingButton"] = "never",
				["QueueStatusMinimapButton"] = "hover",
				["MiniMapVoiceChatFrame"] = "hover",
				["MinimapZoneTextButton"] = "hover",
				["GameTimeFrame"] = "never",
				["MiniMapWorldMapButton"] = "never",
				["MinimapZoomOut"] = "never",
				["TimeManagerClockButton"] = "hover",
				["MiniMapMailFrame"] = "hover",
				["MiniMapInstanceDifficulty"] = "hover",
				["MiniMapTracking"] = "hover",
				["GarrisonLandingPageMinimapButton"] = "hover",
				["GuildInstanceDifficulty"] = "hover",
				["MinimapZoomIn"] = "never",
			},
			["dragPositions"] = {
				["MiniMapInstanceDifficulty"] = 46.7098241952883,
				["MiniMapMailFrame"] = 7.24451265654936,
				["GameTimeFrame"] = 35.2934180541471,
				["LibDBIcon10_Bugger"] = 39.2321162731999,
				["GarrisonLandingPageMinimapButton"] = 132.917444085811,
				["MiniMapTracking"] = -32.9977015767032,
				["GuildInstanceDifficulty"] = 16.525804750825,
				["QueueStatusMinimapButton"] = 198.886088256962,
			},
		},
		["hudmap"] = {
			["scale"] = 1.4,
			["hudColor"] = {
			},
			["alpha"] = 0.7,
			["textColor"] = {
				["a"] = 1,
				["r"] = 0.5,
				["g"] = 1,
				["b"] = 0.5,
			},
		},
		["zonetext"] = {
			["bgColor"] = {
				["a"] = 0,
				["r"] = 0,
				["g"] = 0,
				["b"] = 0,
			},
			["font"] = "Ubuntu Medium",
			["fontColor"] = {
				["a"] = 1,
				["b"] = 1,
				["g"] = 1,
				["r"] = 1,
			},
			["borderColor"] = {
				["a"] = 0,
				["r"] = 0,
				["g"] = 0,
				["b"] = 0,
			},
			["xOffset"] = 0,
			["yOffset"] = -140,
			["fontsize"] = 11,
			["width"] = 50,
		},
		["clock"] = {
			["xOffset"] = 0,
			["fontsize"] = 11,
			["yOffset"] = 140,
			["bgColor"] = {
				["a"] = 0,
				["r"] = 0,
				["g"] = 0,
				["b"] = 0,
			},
			["font"] = "Ubuntu Mono Bold",
			["fontColor"] = {
				["a"] = 1,
				["r"] = 1,
				["g"] = 1,
				["b"] = 1,
			},
			["borderColor"] = {
				["a"] = 0,
				["r"] = 0,
				["g"] = 0,
				["b"] = 0,
			},
		},
		["borders"] = {
			["applyPreset"] = false,
			["borders"] = {
			},
			["backdrop"] = {
				["show"] = true,
				["textureColor"] = {
					["a"] = 1,
					["b"] = 1,
					["g"] = 1,
					["r"] = 1,
				},
				["settings"] = {
					["insets"] = {
						["top"] = 0,
						["right"] = 0,
						["left"] = 0,
						["bottom"] = 0,
					},
					["bgFile"] = "Interface\\AddOns\\PrimalMedia\\minimap\\shapes\\ninja_kitty_black.tga",
					["edgeSize"] = 6,
					["tile"] = false,
				},
				["borderColor"] = {
				},
				["scale"] = 1,
			},
			["hideBlizzard"] = true,
		},
		["movers"] = {
			["enabled"] = false,
			["lock"] = false,
			["framePositions"] = {
			},
		},
	},
}
------------------------------------------------------------------------------------------------------------------------

-- vim: tw=120 ts=4 sts=2 sw=2 et
