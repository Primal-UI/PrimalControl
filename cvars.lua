-- TODO. There really should be two sets of CVars: those that are important for the UI to behave correctly and those
-- that are just my preferences.

local addonName, addon = ...
setfenv(1, addon)

--[[--------------------------------------------------------------------------------------------------------------------
wowprogramming.com/docs/cvars
wow.gamepedia.com/Console_variables
wowprogramming.com/utils/xmlbrowser/test/SharedXML/GraphicsQualityLevels.lua
GetDefaultVideoQualityOption("cvar", [, qualityLevel] [, defaultValue] [, isRaid])
wow.gamepedia.com/Console_variables/Complete_list (hopelessly outdated, 4.0.3a)
www.ownedcore.com/forums/world-of-warcraft/world-of-warcraft-bots-programs/wow-memory-editing/496760-cvar-list-build-x86
-19034-tips.html
--]]--------------------------------------------------------------------------------------------------------------------

function addon:setCVars()
  _G.assert(not _G.InCombatLockdown())
  print("CVars set to non-default values but not listed:")
  for _, cVar in _G.pairs(allCVars) do
    -- TODO: check if the CVar exists first? Probably unnecessary; causing a Lua error is fine in that case.
    if not cVars[cVar] and not otherCVars[cVar] and _G.GetCVar(cVar) ~= _G.GetCVarDefault(cVar) then
      print(cVar, _G.GetCVar(cVar))
    end
  end
  print("CVars set to default values explicitly:")
  for cVar, value in _G.pairs(cVars) do
    if value == _G.GetCVarDefault(cVar) then
      print(cVar, value)
    end
      _G.SetCVar(cVar, value)
  end
  -- These CVars are set to their default values.
  for cVar, _ in _G.ipairs(otherCVars) do
    _G.SetCVar(cVar, _G.GetCVarDefault(cVar))
  end
end

-- TODO: set these: synchronizeBindings, synchronizeChatFrames, synchronizeConfig, synchronizeMacros,
-- synchronizeSettings. And these: bnWhisperMode, whisperMode?

cVars = {
  ----------------------------------------------------------------------------------------------------------------------
  -- Global CVars; these appear in WTF/Config.wtf ----------------------------------------------------------------------
  gxTripleBuffer = "0",
  gxFixLag = "1",
  gxCursor = "1",
  maxFPS = "0",
  maxfpsbk = "30",
  DesktopGamma = "1",
  useUiScale = "0",
  hdPlayerModels = "0",
  -- "View Distance" drop down -----------------------------------------------------------------------------------------
  farclip = "600", -- "Fair" preset
  wmoLodDist = "200", -- Don't know what this does. Using "Low" preset
  terrainLodDist = "200", -- 0 disables it. Terrain further than terrainLodDist looks fine when terrainTextureLod is 0.
                          -- 200 seems to be minumum.
  terrainTextureLod = 0, -- 1 makes terrain further than terrainLodDist look REALLY bad; default is 0.
  ----------------------------------------------------------------------------------------------------------------------
  -- "Ground Clutter" drop down ----------------------------------------------------------------------------------------
  groundEffectDist = "50", -- "Low" preset
  groundEffectDensity = "16",
  ----------------------------------------------------------------------------------------------------------------------
  environmentDetail = "75", -- "Fair" preset for "Environment Detail" drop down.
  -- "Particle Density" drop down --------------------------------------------------------------------------------------
  particleDensity = "20", -- "Low" preset is 10, "Good" is 50.
  weatherDensity = "0", -- "Low" preset.
  ----------------------------------------------------------------------------------------------------------------------
  ssao = "0", -- "SSAO" drop down. Disabled (default).
  -- "Shadow Quality" drop down --------------------------------------------------------------------------------------
  shadowMode = "3", -- "High" preset.
  shadowTextureSize = "1024", -- Default. "Low" and "Fair" preset. Only other option is 2048.
  ----------------------------------------------------------------------------------------------------------------------
  -- "Texture Resolution" drop down ------------------------------------------------------------------------------------
  terrainMipLevel = "1", -- Default is 0.
  componentTextureLevel = "0", -- 1 (default) or 2 make character textures look ugly. Can't be set to 2 with the GUI.
  worldBaseMip = "0", -- Default. Highest texture resolution.
  ----------------------------------------------------------------------------------------------------------------------
  projectedTextures = "1", -- "Projected Textures" drop down. What does this do exacly?
  textureFilteringMode = "4", -- 8x Anisotropic
  -- "Liquid Detail" drop down -----------------------------------------------------------------------------------------
  waterDetail = "1", -- "Fair" preset
  reflectionMode = "0", -- "Fair" preset
  rippleDetail = "0", -- Not set by "Fair" and "Low"?
  ----------------------------------------------------------------------------------------------------------------------
  sunshafts = "0", -- "Sunshafts" drop down.
  refraction = "0", -- Default is 0. Removed from GUI?
  SSAOBlur = "0", -- wow.gamepedia.com/CVar_ssaoblur
  Sound_NumChannels = "64",
  Sound_EnableMusic = "0",
  Sound_EnableAmbience = "0",
  Sound_EnablePetBattleMusic = "0",
  Sound_EnablePetSounds = "0",
  Sound_EnableErrorSpeech = "0",
  Sound_EnableDSPEffects = "0",
  Sound_EnableSoundWhenGameIsInBG = "1",
  Sound_MasterVolume = "0.12",
  Sound_SFXVolume = "0.16",
  Sound_DialogVolume = "0.16",
  FootstepSounds = "0",
  threatPlaySounds = "0",
  repositionfrequency = "0", -- wow.gamepedia.com/CVar_repositionfrequency
  screenshotFormat = "jpg", -- Should this support PNG. I don't think it does. Maybe on Macs?
  screenshotQuality = "9",
  checkAddonVersion = "0",
  movieSubtitle = "1",
  gxDisableStencil = "1",
  groundEffectFade = "7",
  ffxGlow = "0",
  showfootprintparticles = "0",
  graphicsQuality = "1",
  engineSurvey = "1", -- What's this? Default is "0"...
  DepthBasedOpacity = "0",
  OutlineEngineMode = "1",
  lightMode = "0",
  RAIDsettingsEnabled = "0",

  ----------------------------------------------------------------------------------------------------------------------
  -- Account-wide CVars; these appear in WTF/Account/<AccountName>/config-cache.wtf ------------------------------------
  deselectOnClick = "1",
  autoDismountFlying = "1",
  interactOnLeftClick = "0",
  showTargetOfTarget = "0",
  spellActivationOverlayOpacity = "0",
  reducedLagTolerance = "1",
  maxSpellStartRecoveryOffset = "150",
  rotateMinimap = "1",
  scriptErrors = "1",
  screenEdgeFlash = "0",
  displayFreeBagSlots = "0",
  autoQuestWatch = "0",
  profanityFilter = "0",
  spamFilter = "0",
  chatBubbles = "0",
  chatBubblesParty = "0",
  removeChatDelay = "1",
  guildShowOffline = "0",
  guildMemberNotify = "0",
  chatStyle = "classic",
  wholeChatWindowClickable = "0",
  conversationMode = "inline",
  showTimestamps = "%H:%M ",
  secureAbilityToggle = "0",
  UnitNamePlayerGuild = "0",
  UnitNamePlayerPVPTitle = "0",
  UnitNameEnemyGuardianName = "1",
  UnitNameEnemyTotemName = "1",
  UnitNameFriendlyPetName = "0",
  UnitNameGuildTitle = "0",
  CombatDamageStyle = "1", -- "Base Mode" item from the display mode dropdown ("Floating Combat Text" panel).  Default
                           -- value.  The description says that the other value has extremely poor performance.
  CombatHealingAbsorbSelf = "0",
  enableCombatText = "0",
  fctReactives = "0",
  fctLowManaHealth = "0",
  fctSpellMechanics = "0", -- "Effects" checkbox in the "Floating Combat Text" panel.  Default value.  "Snared" spam is
                           -- annoying.
  fctSpellMechanicsOther = "0", -- "Show for other players' targets" checkbox.  Default value.
  playerStatusText = "1",
  targetStatusText = "1",
  statusTextDisplay = "PERCENT",
  showToastWindow = "0",
  cameraPitchMoveSpeed = "135",
  cameraYawMoveSpeed = "270",
  cameraYawSmoothSpeed = "270",
  cameraSmoothStyle = "0",
  cameraPivot = "0",
  cameraDistanceMax = "35",
  cameraDistanceMaxFactor = "1",
  UberTooltips = "0",
  showTutorials = "0",
  showNPETutorials = "0",
  Outline = "3",

  ----------------------------------------------------------------------------------------------------------------------
  -- Character-specific CVars; these appear in WTF/Account/<AccountName>/<RealmName>/CharacterName>/config-cache.wtf ---
  autoLootDefault = "1",
  autoSelfCast = "0",
  stopAutoAttackOnTargetChange = "0",
  displaySpellActivationOverlays = "0",
  lossOfControl = "0",
  lossOfControlFull = "0",
  lossOfControlInterrupt = "0",
  lossOfControlSilence = "0",
  lossOfControlDisarm = "0",
  lossOfControlRoot = "0",
  minimapZoom = "3",
  lockedWorldMap = "0",
  mapFade = "0",
  showPartyPets = "0",
  showArenaEnemyFrames = "0",
  showArenaEnemyCastbar = "0",
  showArenaEnemyPets = "0",
  consolidateBuffs = "0",
  nameplateShowEnemies = "1",
  nameplateShowEnemyGuardians = "1", -- Shadow Reflection
  nameplateShowEnemyMinus = "0",
  nameplateShowFriendlyPets = "0",
  nameplateShowFriendlyGuardians = "0",
  nameplateShowFriendlyTotems = "0",
  ShowClassColorInNameplate = "1",
  characterFrameCollapsed = "0",
  activeCUFProfile = "Primary",
  lastVoidStorageTutorial = "3",
  lastGarrisonMissionTutorial = "8",
  showVKeyCastbarSpellName = "1",

  ----------------------------------------------------------------------------------------------------------------------
  -- Other CVars; I'm not sure where these would be saved but all of them are set to their default values --------------
  ActionButtonUseKeyDown = "1",
  shadowCull = "1",
  shadowInstancing = "1",
  shadowScissor = "1",
  Sound_EnableSoftwareHRTF = "0",
  Sound_EnableSFX = "1",
  Sound_EnableEmoteSounds = "1",
  Sound_EnableReverb = "0",
  Sound_ListenerAtCharacter = "1",
  enableMouseSpeed = "0",
  scriptProfile = "0",

  --------------------------------------------------------------------------------------------------------------------
  -- Removed CVars; I think these were removed, but am not sure --------------------------------------------------------
  --Sound_OutputQuality = "2",
  --mapQuestDifficulty = "1",
  --enterWorld = "1",
  --useWeatherShaders = "0",
  --mapShadows
}

-- We set these to their default values.
otherCVars = {
  ----------------------------------------------------------------------------------------------------------------------
  -- Global CVars; these appear in WTF/Config.wtf ----------------------------------------------------------------------
  Sound_MusicVolume = true,
  Sound_AmbienceVolume = true,
  ChatMusicVolume = true,
  ChatSoundVolume = true,
  ChatAmbienceVolume = true,
  Gamma = true,
  RAIDgraphicsQuality = true,
  RAIDsettingsInit = true,
  RAIDfarclip = true,
  RAIDWaterDetail = true,
  RAIDSSAOBlur = true,
  RAIDterrainLodDist = true,
  RAIDwmoLodDist = true,
  RAIDtextureFilteringMode = true,
  RAIDprojectedTextures = true,
  RAIDenvironmentDetail = true,
  RAIDreflectionMode = true,
  RAIDrippleDetail = true,
  RAIDparticleDensity = true,
  RAIDrefraction = true,
  RAIDcomponentTextureLevel = true,
  RAIDOutlineEngineMode = true,
  RAIDparticleMTDensity = true,
  RAIDLightMode = true,
  RAIDweatherDensity = true,
  RAIDDepthBasedOpacity = true,
  RAIDgroundEffectDist = true,
  RAIDshadowMode = true,
  RAIDterrainMipLevel = true,
  RAIDgroundEffectDensity = true,
  RAIDgroundEffectFade = true,
  RAIDshadowTextureSize = true,
  RAIDSSAO = true,
  RAIDsunShafts = true,
  RAIDterrainTextureLod = true,
  RAIDworldBaseMip = true,

  MSAAAlphaTest = true,
  RenderScale = true,
  VoiceActivationSensitivity = true,
  uiScale = true,

  -- Other CVars; I'm not sure where these would appear ----------------------------------------------------------------
  mouseSpeed = true,
}

-- vim: tw=120 sts=2 sw=2 et
