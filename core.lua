-- PrimalControl is used to install PrimalUI or reset specific components of PrimalUI.  It enables addons and contains
-- and can apply addon settings (SavedVariables, SavedVariablesPerCharacter), frame positions, chat settings and console
-- variables (CVars).
--
-- The main advantage this addon provides is an automated way to setup PrimalUI while not having to replace any contents
-- of the WTF directory, as well as an easy way to reset aspects of the UI and reapply default addon settings.
--
-- TODO: Populate action bars? Load macros? Add the ability to reset individual addons specifically.

local addonName, addon = ...
addon._G = _G
_G[addonName] = addon
setfenv(1, addon)

debug = true

if debug then
  print = function(...)
    _G.print("|cffff7d0a" .. addonName .. "|r:", ...)
  end
else
  print = function() end
end

local AceGUI = _G.LibStub("AceGUI-3.0")

--[[--------------------------------------------------------------------------------------------------------------------
wowprogramming.com/docs/api_categories#cvar
--]]--------------------------------------------------------------------------------------------------------------------

primalAddons = {

}

-- Third-party addons that we will enable and (if necessary) configure by setting SavedVariables.
addons = {
  "Bartender4",
  "Bugger",
  "!BugGrabber",
  "Chatter",
  "DamnUnitSounds",
  "DuelCountdown",
  "MapCoords",
  "MikScrollingBattleText",
  "MinimapRange",
  "MSBTOptions",
  "OmniBar",
  --"OmniBar_Options",
  "OmniCC",
  --"OmniCC_Config",
  "OPie",
  "SafeQueue",
  "SellJunk",
  "TellMeWhen",
  --"TellMeWhen_Options",
  "TidyPlates",
  "TidyPlatesHub",
  "TidyPlatesWidgets",
  "TidyPlates_Neon",
  "WeakAuras",
  --"WeakAurasModelPaths",
  --"WeakAurasOptions",
  --"WeakAurasTutorials",
}

local eventHandler = _G.CreateFrame("Frame")
eventHandler:SetScript("OnEvent", function(_, event, ...)
  return addon[event](addon, ...)
end)

function addon:configureAddons()

end

panel = nil

function addon:openPanel()
  if panel then return end

  -- This is apparently really not the way to close the GameMenuFrame. All the panels that won't open while it's shown
  -- still won't open after calling this.
  --_G.GameMenuFrame:Hide()

  -- See ToggleGameMenu() in wowprogramming.com/utils/xmlbrowser/test/FrameXML/UIParent.lua.
  if _G.GameMenuFrame:IsShown() then
    _G.PlaySound("igMainMenuQuit")
    _G.HideUIPanel(_G.GameMenuFrame)
  end

  panel = AceGUI:Create("Frame")
  panel:SetTitle("|cffff7d0aPrimalUI|r Control")
  panel:SetCallback("OnClose", function(self) AceGUI:Release(self); panel = nil end)
  panel:SetLayout("Flow")
  panel:SetWidth(448)

  ----------------------------------------------------------------------------------------------------------------------
  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("Set some console variables to my preferred values. This is recommended but changes a lot of default" ..
    " UI settings (including graphics quality). You might want to revisit the default UI options after doing this.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(0.3)
  panel:AddChild(spacer)

  local cVarButton = AceGUI:Create("Button")
  cVarButton:SetText("Set CVars")
  cVarButton:SetRelativeWidth(0.4)
  cVarButton:SetCallback("OnClick", function(self)
    addon:setCVars()
  end)
  panel:AddChild(cVarButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(0.3)
  panel:AddChild(spacer)
  ----------------------------------------------------------------------------------------------------------------------

  ----------------------------------------------------------------------------------------------------------------------
  local heading = AceGUI:Create("Heading")
  heading:SetFullWidth(true)
  panel:AddChild(heading)

  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("Configure the chat windows. Recommended.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(0.3)
  panel:AddChild(spacer)

  local chatButton = AceGUI:Create("Button")
  chatButton:SetText("Setup Chat")
  chatButton:SetRelativeWidth(0.4)
  chatButton:SetCallback("OnClick", function(self)
    addon:setupChat()
  end)
  panel:AddChild(chatButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(0.3)
  panel:AddChild(spacer)
  ----------------------------------------------------------------------------------------------------------------------

  ----------------------------------------------------------------------------------------------------------------------
  local heading = AceGUI:Create("Heading")
  heading:SetFullWidth(true)
  panel:AddChild(heading)

  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("This will load the included SavedVariables for all AddOns that are part of PrimalUI.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(0.3)
  panel:AddChild(spacer)

  local savedVariablesButton = AceGUI:Create("Button")
  savedVariablesButton:SetText("Setup AddOns")
  savedVariablesButton:SetRelativeWidth(0.4)
  savedVariablesButton:SetCallback("OnClick", function(self)
    addon:setupChat()
  end)
  panel:AddChild(savedVariablesButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(0.3)
  panel:AddChild(spacer)
  ----------------------------------------------------------------------------------------------------------------------

  ----------------------------------------------------------------------------------------------------------------------
  local heading = AceGUI:Create("Heading")
  heading:SetFullWidth(true)
  --heading:SetText("Reload UI")
  panel:AddChild(heading)

  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("Some changes won't take effect until reloading the UI.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(0.3)
  panel:AddChild(spacer)

  local reloadButton = AceGUI:Create("Button")
  reloadButton:SetText("Reload UI")
  reloadButton:SetRelativeWidth(0.4)
  reloadButton:SetCallback("OnClick", function(self)
    _G.ReloadUI()
  end)
  panel:AddChild(reloadButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(0.3)
  panel:AddChild(spacer)
  ----------------------------------------------------------------------------------------------------------------------
end

function addon:ADDON_LOADED(name)
  if name ~= addonName then return end

  eventHandler:UnregisterEvent("ADDON_LOADED")

  self.ADDON_LOADED = nil
end

eventHandler:RegisterEvent("ADDON_LOADED")

-- vim: tw=120 sts=2 sw=2 et
