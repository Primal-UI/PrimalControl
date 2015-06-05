-- PrimalControl is used to install PrimalUI or reset specific components of PrimalUI.  It enables addons and contains
-- and can apply addon settings (SavedVariables, SavedVariablesPerCharacter), frame positions, chat settings and console
-- variables (CVars).
--
-- The main advantage this addon provides is an automated way to setup PrimalUI while not having to replace any contents
-- of the WTF directory, as well as an easy way to reset aspects of the UI and reapply default addon settings.
--
---- TODO --------------------------------------------------------------------------------------------------------------
-- Populate action bars? Load macros? Add the ability to reset individual addons specifically.
-- Redesign the panel for loading only some addon settings.

local addonName, addon = ...
addon._G = _G
_G[addonName] = addon
setfenv(1, addon)

----[[
print = function(...)
  _G.print("|cffff7d0a" .. addonName .. "|r:", ...)
end
--]]

local AceGUI = _G.LibStub("AceGUI-3.0")

local onGroupSelected, drawMainPanel, drawAddonPanel
local tabs = {{ value = "main", text = "Main" }, { value = "addons", text = "AddOns"}}

function addon:openPanel()
  if panel then return end

  -- This is apparently not the way to close the GameMenuFrame.  All the panels that won't open while it's shown still
  -- won't open after calling this.
  --_G.GameMenuFrame:Hide()

  -- See ToggleGameMenu() in wowprogramming.com/utils/xmlbrowser/test/FrameXML/UIParent.lua.
  if _G.GameMenuFrame:IsShown() then
    _G.PlaySound("igMainMenuQuit")
    _G.HideUIPanel(_G.GameMenuFrame)
  end

  panel = AceGUI:Create("Frame")
  panel:SetTitle("|cffff7d0aPrimalUI|r Control")
  panel:SetCallback("OnClose", function(self) AceGUI:Release(self); panel = nil end)
  panel:SetLayout("Fill")
  panel:SetWidth(448)

  local tabGroup = AceGUI:Create("TabGroup")
  tabGroup:SetTabs(tabs)
  tabGroup:SetLayout("Fill")
  tabGroup:SetCallback("OnGroupSelected", onGroupSelected)
  tabGroup:SelectTab("main")

  --tabGroup:SetFullWidth(true)
  --tabGroup:SetFullHeight(true)

  panel:AddChild(tabGroup)
end

function onGroupSelected(container, event, group)
  container:ReleaseChildren()
  if group == "main" then
    drawMainPanel(container)
  elseif group == "addons" then
    drawAddonPanel(container)
  end
end

function drawMainPanel(container)
  container:SetLayout("Fill")
  local panel = AceGUI:Create("ScrollFrame")
  panel:SetLayout("Flow")
  container:AddChild(panel)

  local heading = AceGUI:Create("Heading")
  heading:SetText("Main Panel")
  heading:SetFullWidth(true)
  panel:AddChild(heading)

  --[-[-----------------------------------------------------------------------------------------------------------------
  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("1. Set some console variables to my preferred values. This changes a lot of default UI settings " ..
    "(including graphics quality). You might want to revisit the default UI options after doing this. Recommended.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)

  local cVarButton = AceGUI:Create("Button")
  cVarButton:SetText("Set CVars")
  cVarButton:SetRelativeWidth(.4)
  cVarButton:SetCallback("OnClick", function(self)
    addon:setCVars()
  end)
  panel:AddChild(cVarButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)
  --]]------------------------------------------------------------------------------------------------------------------

  --[-[-----------------------------------------------------------------------------------------------------------------
  local heading = AceGUI:Create("Heading")
  heading:SetFullWidth(true)
  panel:AddChild(heading)

  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("2. Configure the chat windows.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)

  local chatButton = AceGUI:Create("Button")
  chatButton:SetText("Setup Chat")
  chatButton:SetRelativeWidth(.4)
  chatButton:SetCallback("OnClick", function(self)
    addon:setupChat()
  end)
  panel:AddChild(chatButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)
  --]]------------------------------------------------------------------------------------------------------------------

  --[-[-----------------------------------------------------------------------------------------------------------------
  local heading = AceGUI:Create("Heading")
  heading:SetFullWidth(true)
  panel:AddChild(heading)

  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("3. Enable all AddOns that are part of PrimalUI. Most of them won't be loaded until reloading the UI.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)

  local savedVariablesButton = AceGUI:Create("Button")
  savedVariablesButton:SetText("Enable AddOns")
  savedVariablesButton:SetRelativeWidth(.4)
  savedVariablesButton:SetCallback("OnClick", enableAllAddons)
  panel:AddChild(savedVariablesButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)
  --]]------------------------------------------------------------------------------------------------------------------

  --[-[-----------------------------------------------------------------------------------------------------------------
  local heading = AceGUI:Create("Heading")
  heading:SetFullWidth(true)
  panel:AddChild(heading)

  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("4. Load the included settings for all loaded AddOns that are part of PrimalUI.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)

  local savedVariablesButton = AceGUI:Create("Button")
  savedVariablesButton:SetText("Setup AddOns")
  savedVariablesButton:SetRelativeWidth(.4)
  savedVariablesButton:SetCallback("OnClick", configureAllAddons)
  panel:AddChild(savedVariablesButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)
  --]]------------------------------------------------------------------------------------------------------------------

  --[-[-----------------------------------------------------------------------------------------------------------------
  local heading = AceGUI:Create("Heading")
  heading:SetFullWidth(true)
  panel:AddChild(heading)

  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("Most changes won't take effect until reloading the UI.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)

  local reloadButton = AceGUI:Create("Button")
  reloadButton:SetText("Reload UI")
  reloadButton:SetRelativeWidth(.4)
  reloadButton:SetCallback("OnClick", function(self)
    _G.ReloadUI()
  end)
  panel:AddChild(reloadButton)

  local spacer = AceGUI:Create("Label")
  spacer:SetRelativeWidth(.3)
  panel:AddChild(spacer)
  ----------------------------------------------------------------------------------------------------------------------
end

function drawAddonPanel(container)
  container:SetLayout("Fill")
  local panel = AceGUI:Create("ScrollFrame")
  panel:SetLayout("Flow")
  container:AddChild(panel)

  local heading = AceGUI:Create("Heading")
  heading:SetText("AddOn Panel")
  heading:SetFullWidth(true)
  panel:AddChild(heading)

  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText("You can cherry-pick AddOns that you want to setup or reset. Clicking one of these buttons will " ..
                "load the default configuration for that AddOn. You typically have to reload the UI for the new " ..
                "settings to take effect.")
  label:SetFontObject(_G.GameFontNormalLeft)
  panel:AddChild(label)

  --[=[
  local dropdown = AceGUI:Create("Dropdown")
  dropdown:SetMultiselect(true)
  dropdown:SetList(addons)
  for i = 1, #addons do
    if setupFunctions[addons[i]] then
      dropdown:SetItemValue(i, true)
    else
      dropdown:SetItemDisabled(i, true)
    end
  end
  dropdown:SetRelativeWidth(.6)
  dropdown:SetCallback("OnValueChanged", function(self, key, checked)
    --[[...]]
  end)
  panel:AddChild(dropdown)

  local button = AceGUI:Create("Button")
  button:SetText("Setup AddOns")
  button:SetRelativeWidth(.4)
  button:SetCallback("OnClick", function(self)
    for i = 1, #addons do
      -- ...
    end
  end)
  panel:AddChild(button)
  --]=]

  for i = 1, #addons do
    if setupFunctions[addons[i]] then
      local button = AceGUI:Create("Button")
      button:SetText(addons[i])
      button:SetRelativeWidth(.5)
      button:SetCallback("OnClick", function(self)
        configureAddon(addons[i])
      end)
      panel:AddChild(button)
    end
  end
end

onPlayerLogout = {}

local eventHandler = _G.CreateFrame("Frame")
eventHandler:SetScript("OnEvent", function(_, event, ...)
  return addon[event](addon, ...)
end)

function addon:ADDON_LOADED(name)
  if name ~= addonName then return end

  eventHandler:UnregisterEvent("ADDON_LOADED")

  eventHandler:RegisterEvent("PLAYER_LOGOUT")

  self.ADDON_LOADED = nil
end

function addon:PLAYER_LOGOUT()
  for i = 1, #onPlayerLogout do
    onPlayerLogout[i]()
  end
end

eventHandler:RegisterEvent("ADDON_LOADED")

-- vim: tw=120 sts=2 sw=2 et
