local addonName, addon = ...
setfenv(1, addon)

local tradeChatFrame = _G.ChatFrame7

local chatCache
--local chatCacheTable = _G.setmetatable({}, { __index = function(table, key) table[key] = {}; return table[key] end})
local chatCacheTable = {}
if debug then
  _G.chatCacheTable = chatCacheTable
end

-- These are often preceded by a blank line but not always.
local sectionHeadings = {
  CHANNELS = true,
  COLORS   = true,
  WINDOW   = true,
  MESSAGES = true,
}

local function parseChatCache()
  -- The chain of keys used to index into the chatCacheTable to find the subtable currently used for insertion.
  local keyChain = {}
  local subTable = chatCacheTable

  for line in _G.string.gmatch(chatCache, "[^\r\n]+") do -- lua-users.org/wiki/StringRecipes
    _G.assert(line ~= "")
    if line == "END" then
      _G.assert(#keyChain > 0)
      subTable = chatCacheTable
      keyChain[#keyChain] = nil
      for _, key in _G.ipairs(keyChain) do
        subTable = subTable[key]
      end
    else
      local i, j = _G.string.find(line, "%S+")
      _G.assert(i == 1)
      local attribute = _G.string.sub(line, i, j)
      if sectionHeadings[attribute] then
        subTable[line] = {}
        subTable = subTable[line]
        keyChain[#keyChain + 1] = line
      else
        line = _G.string.sub(line, j + 2) -- Skip the space
        subTable[attribute] = line
      end
    end
  end
end

-- This function is meant to make WoW save the values from chatCache in chat-cache.txt when logging out.  It's not
-- intended to make everything look right before reloading the UI (and currently doesn't either).  TODO: set CVars that
-- are integral to the chat configuration.
function addon:setupChat()
  parseChatCache()

  ----------------------------------------------------------------------------------------------------------------------
  -- In general, whether it is possible to join or leave a server channel, depends on what zone the player is currently
  -- in. Specifically, we can't join the Trade channel, unless the player is in a zone where Trade Chat is available
  -- (capital cities, Shattrath, Dalaran, garrisons, etc.).  This makes it impossible to fully reset the channels a
  -- player has joined in some cases.  Moreover, GetChannelList() and EnumerateServerChannels() (and ListChannels())
  -- omit unavailable channels from their return values, even though the information that the player joined them is not
  -- discarded.  The index of an unavailable channel will remain reserved and the game will automatically join that
  -- channel again once it becomes available.  GetChannelName() doesn't return useful information about inactive
  -- channels either.

  -- Keys in joinedChannels aren't necessarily consecutive!
  --[[
  local joinedChannels = {}
  (function(...) -- Such varargs :D
    for i = 1, _G.select("#", ...), 2 do
      local index, channelName = _G.select(i, ...), _G.select(i + 1, ...)
      joinedChannels[index] = channelName
    end
  end)(_G.GetChannelList())
  --]]

  -- This is what EnumerateServerChannels() returns in a capital as I'm writing this. Hard coded since that function
  -- doesn't work depending on where the player is...
  local serverChannels = {
    "General",
    "Trade",
    "LocalDefense",
    --"WorldDefense", -- Nobody is ever in this channel... also, wasn't LookingForGroup normally at index 4?
    "LookingForGroup",
    --"BigfootWorldChannel", -- Can't join this channel. What the hell is this anyway?
    --"MeetingStone", -- Ditto.
  }

  do local i, j = 1, _G.GetNumDisplayChannels()
    while i <= j do
      local _, header, collapsed = _G.GetChannelDisplayInfo(i)
      if header and collapsed then -- It's actually not a chat channel. Wtf?
        _G.ExpandChannelHeader(i)
        j = _G.GetNumDisplayChannels()
      end
      i = i + 1
    end
  end

  -- All the headers in the Chat Channels pane (wow.gamepedia.com/Chat_Channels) should be expanded now.  This is
  -- actually required to get information about all channels using GetChannelDisplayInfo(), which is the only way I'm
  -- aware of to get information about inactive channels.  I'm serious.

  -- Leaving inactive channles doesn't work but calling LeaveChannelByName() on them doesn't break anything either.
  for i = 1, _G.GetNumDisplayChannels() do
    local name, header, _, channelNumber, _, active, category = _G.GetChannelDisplayInfo(i)
    if not header then
      if category == "CHANNEL_CATEGORY_CUSTOM" then
        if serverChannels[channelNumber] then -- Need this index.  Free it.
          print("leaving channel " .. channelNumber .. ": " .. name)
          _G.LeaveChannelByName(name)
        end
      elseif category == "CHANNEL_CATEGORY_GROUP " then
        -- TODO?
      elseif category == "CHANNEL_CATEGORY_WORLD" then
        if name ~= serverChannels[channelNumber] then -- Wrong index.
          -- The only way to change indices is leaving channels and joining them again in a different order.
          print("trying to leave channel " .. channelNumber .. ": " .. name)
          _G.LeaveChannelByName(name)
        end
      end
    end
  end

  _G.C_Timer.After(1, function()
    for i = 1, #serverChannels do
      _G.JoinPermanentChannel(serverChannels[i], nil, tradeChatFrame:GetID())
      _G.ChatFrame_AddChannel(tradeChatFrame, serverChannels[i])
    end
  end)

  -- This part of the API (wowprogramming.com/docs/api_categories#channel) is actually so weird.  I bet noone touched
  -- it since Vanilla and it's still exacly the same.
  -- wowprogramming.com/docs/api/GetChannelList
  -- wowprogramming.com/docs/api/EnumerateServerChannels
  ----------------------------------------------------------------------------------------------------------------------

  --[[
  CHANNELS
  laksdjflkj 1 1
  help 1 5
  END
  ]]
  for channelName, channelInfo in _G.pairs(chatCacheTable.CHANNELS) do
    -- TODO.
  end

  -- I have no idea what to do with the value of chatCacheTable.ZONECHANNELS. TODO?

  for messageGroup, info in _G.pairs(chatCacheTable.COLORS) do
    _G.assert(_G.type(info) == "string")
    local r, g, b, classColored = _G.string.match(info, "([0-9]+) ([0-9]+) ([0-9]+) ([YN]+)")
    _G.assert(classColored == "Y" or classColored == "N")
    _G.ChangeChatColor(messageGroup, _G.tonumber(r) / 255, _G.tonumber(g) / 255, _G.tonumber(b) / 255)
    -- Defined in FrameXML/ChatConfigFrame.lua (wowprogramming.com/utils/xmlbrowser/test/FrameXML/ChatConfigFrame.lua).
    _G.ToggleChatColorNamesByClassGroup(classColored == "Y" and true or false, messageGroup)
  end

  for key, info in _G.pairs(chatCacheTable) do
    local chatFrameId = _G.tonumber(_G.string.match(key, "^WINDOW (%d%d?)$"))
    if chatFrameId then
      local chatFrame = _G["ChatFrame" .. chatFrameId]
      local chatTab   = _G["ChatFrame".. chatFrameId .. "Tab"]

      _G.assert(chatFrame and chatTab)
      print("configuring ChatFrame" .. chatFrameId .. (info.NAME and (": \"" .. info.NAME .. "\"") or ""))

      -- TODO: FCF_ResetChatWindows()? Clear chat windows?

      if info.SHOWN == "0" then
        if info.DOCKED == "0" then
          _G.FCF_Close(chatFrame)
        end
      else -- TODO: check if this chat frame is selected.
        -- Code equivalent to a small excerpt from FCF_OpenNewWindow().  The other stuff done in that function should
        -- already be handled when applying other settings.  TODO: there's probably at least an UPDATE_CHAT_WINDOWS or
        -- UPDATE_FLOATING_CHAT_WINDOWS event as well though so some code to do the same stuff as
        -- FloatingChatFrame_OnEvent() might be needed.
        chatFrame:Show()
        chatTab:Show()
        _G.SetChatWindowShown(chatFrameId, true) -- wowprogramming.com/docs/api/SetChatWindowShown
      end

      _G.FCF_SetWindowName(chatFrame, info.NAME) -- This won't break if info.NAME is nil.
      _G.FCF_SetChatWindowFontSize(nil, chatFrame, _G.tonumber(info.SIZE)) -- Chatter seems to overwrite whatever font
                                                                           -- size the default UI saves.

      -- stackoverflow.com/a/19269176/1980378
      local r, g, b, a = _G.string.match(info.COLOR, "([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)")
      r, g, b, a = _G.tonumber(r) / 255, _G.tonumber(g) / 255, _G.tonumber(b) / 255, _G.tonumber(a) / 255
      --[[
      local function tonumber(...)
        if (...) ~= nil then
          return _G.tonumber((...)), tonumber(_G.select(2, ...))
        else
          return
        end
      end
      local r, g, b, a = tonumber(_G.string.match(info.COLOR, "([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+)"))
      ]]
      _G.assert(r and g and b and a)
      _G.FCF_SetWindowColor(chatFrame, r, g, b)
      _G.FCF_SetWindowAlpha(chatFrame, a)

      local locked = _G.tonumber(info.LOCKED)
      _G.FCF_SetLocked(chatFrame, (locked == 1) and true or false) -- wowprogramming.com/docs/api/SetChatWindowLocked

      -- It's normally not really possible for docked chat frames (there can only by one dock) to have different
      -- interactable settings.  This doesn't explicitly prevent it.
      _G.FCF_SetUninteractable(chatFrame, info.UNINTERACTABLE == "1")
      -- Calls wowprogramming.com/docs/api/SetChatWindowUninteractable

      -- I think the frame will be docked at this position; e.g., if index is 3, its tab will be the third tab.
      local index = _G.tonumber(info.DOCKED)
      if index == 0 then
        _G.FCF_UnDockFrame(chatFrame)
      else
        -- Chat frames that aren't docked count as being selected.  This is in line with Blizzard code (this assignement
        -- basically is Blizzard code).  On the other hand, all this will do is make FCF_DockFrame() select the frame
        -- that's being docked and that only really seems to make sense when the frame is docked manually by a user
        -- dragging it.  Maybe using FCF_GetCurrentChatFrameID() would be better.  Whatever.
        local selected = not chatFrame.isDocked or chatFrame == _G.FCFDock_GetSelectedWindow(_G.GENERAL_CHAT_DOCK)
        _G.FCF_DockFrame(chatFrame, index, selected)
      end
      -- Both call wowprogramming.com/docs/api/SetChatWindowDocked (FCF_DockFrame() indirectly and several times)

      -- TODO: remember to also apply these settings to Chatter if it's set to handle chat frame positioning
      -- (synchronizeChatFrames disabled).
      if not chatFrame.isDocked or chatFrame == _G.GENERAL_CHAT_DOCK.primary then
        local chatFrameChanged = false
        if info.POSITION then
          local point, xOffset, yOffset = _G.string.match(info.POSITION, "([^ ]+) ([^ ]+) ([^ ]+)")
          xOffset, yOffset = _G.tonumber(xOffset), _G.tonumber(yOffset)
          chatFrame:ClearAllPoints()
          chatFrame:SetPoint(point, _G.UIParent, point, xOffset, yOffset)
          chatFrameChanged = true
        end
        if info.DIMENSIONS then
          local width, height = _G.string.match(info.DIMENSIONS, "([^ ]+) ([^ ]+)")
          width, height = _G.tonumber(width), _G.tonumber(height)
          chatFrame:SetSize(width, height)
          chatFrameChanged = true
        end
        if chatFrameChanged then
          _G.FCF_SavePositionAndDimensions(chatFrame)
        end
      end

      ------------------------------------------------------------------------------------------------------------------
      -- These four lines are all over FrameXML/FloatingChatFrame.lua used exacly like this whenever a chat frame is
      -- reset.
      _G.ChatFrame_RemoveAllMessageGroups(chatFrame)
      _G.ChatFrame_RemoveAllChannels(chatFrame)
      _G.ChatFrame_ReceiveAllPrivateMessages(chatFrame)
      _G.ChatFrame_ReceiveAllBNConversations(chatFrame)

      -- ChatFrame_AddMessageGroup vs. ChatFrame_AddSingleMessageType().  What's the deal? Which one should we use?
      --
      -- ChatFrame_AddMessageGroup expects its "group" parameter to be an index into the global ChatTypeGroup table
      -- (defined in FrameXML/ChatFrame.lua).  That table maps those to arrays of mostly CHAT_MSG_X events.
      --
      -- ChatFrame_AddSingleMessageType() expects to be passed an event which belongs to a group in the ChatTypeGroup
      -- table in its "messageType" parameter.  It adds that group to the chat frame but only registers it for the
      -- single event passed.
      for value, _ in _G.pairs(info.MESSAGES) do
        -- What exacly can value be? It seems to typically be an index into ChatTypeGroup.
        _G.assert(not _G.ChatTypeGroupInverted[value])
        if _G.ChatTypeGroup[value] then
          if not _G.ChatTypeInfo[value] then
            --print("Warning: " .. value .. " has entry in ChatTypeGroup but not in ChatTypeInfo.")
          end
          _G.ChatFrame_AddMessageGroup(chatFrame, value)
        else
          -- This is apparently more than the Blizzard UI does when reading chat-cache.txt.  I can't prevent
          -- BN_WHISPER_INFORM and BN_WHISPER_PLAYER_OFFLINE from appearing in the MESSAGES section for WINDOW 1 in the
          -- actual chat-cache.txt, but it doesn't cause their respective message groups (BN_WHISPER and SYSTEM) to be
          -- added to ChatFrame1.  Commenting this code out for now.
          --[[
          local group = _G.ChatTypeGroupInverted["CHAT_MSG_" .. value]
          if group then
            print("Warning: " .. value .. " isn't a known message group. Adding CHAT_MSG_" .. value .. " " ..
                  "message type instead.")
            _G.ChatFrame_AddSingleMessageType(chatFrame, "CHAT_MSG_" .. value)
          else
            print("Warning: " .. value .. " isn't a known message group.")
            -- This would have no effect: ChatFrame_AddMessageGroup(chatFrame, value).  That function returns if
            -- ChatTypeGroup[value] is nil.
          end
          --if _G.ChatTypeInfo[value] then
            -- ...
          --end
          --]]
        end
      end
      -- wowprogramming.com/docs/api_types#chatMsgType (this description seems to be inaccurate, though)
      ------------------------------------------------------------------------------------------------------------------

      --[[
      CHANNELS
      laksdjflkj
      help
      END
      ]]
      for channelName, _ in _G.pairs(info.CHANNELS) do
        -- TODO.
      end

      -- TODO: info.ZONECHANNELS

      -- TODO: FCF_SetTabPosition() somewhere?

      -- TODO: we should probably run FloatingChatFrame_Update() now? FloatingChatFrame_OnEvent() would do that in
      -- response to UPDATE_CHAT_WINDOWS or UPDATE_FLOATING_CHAT_WINDOWS.
    end
  end
end
-- wowprogramming.com/docs/api_categories#chat
-- wowprogramming.com/utils/xmlbrowser/test/FrameXML/FloatingChatFrame.lua

-- Contents of automatically generated file chat-cache.txt -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
chatCache = [[
VERSION 5

ADDEDVERSION 19

CHANNELS
END

ZONECHANNELS 35651587

COLORS

SYSTEM 255 255 0 N
SAY 255 255 255 Y
PARTY 170 170 255 Y
RAID 255 127 0 Y
GUILD 64 255 64 Y
OFFICER 64 192 64 Y
YELL 255 64 64 Y
WHISPER 255 128 255 Y
WHISPER_FOREIGN 255 128 255 N
WHISPER_INFORM 255 128 255 Y
EMOTE 255 128 64 Y
TEXT_EMOTE 255 128 64 Y
MONSTER_SAY 255 255 159 N
MONSTER_PARTY 170 170 255 Y
MONSTER_YELL 255 64 64 N
MONSTER_WHISPER 255 181 235 N
MONSTER_EMOTE 255 128 64 N
CHANNEL 255 192 192 N
CHANNEL_JOIN 192 128 128 N
CHANNEL_LEAVE 192 128 128 N
CHANNEL_LIST 192 128 128 N
CHANNEL_NOTICE 192 192 192 N
CHANNEL_NOTICE_USER 192 192 192 N
AFK 255 128 255 Y
DND 255 128 255 Y
IGNORED 255 0 0 N
SKILL 85 85 255 N
LOOT 0 170 0 N
MONEY 255 255 0 N
OPENING 128 128 255 N
TRADESKILLS 255 255 255 N
PET_INFO 128 128 255 N
COMBAT_MISC_INFO 128 128 255 N
COMBAT_XP_GAIN 111 111 255 N
COMBAT_HONOR_GAIN 224 202 10 N
COMBAT_FACTION_CHANGE 128 128 255 N
BG_SYSTEM_NEUTRAL 255 120 10 N
BG_SYSTEM_ALLIANCE 0 174 239 N
BG_SYSTEM_HORDE 255 0 0 N
RAID_LEADER 255 72 9 Y
RAID_WARNING 255 72 0 Y
RAID_BOSS_EMOTE 255 221 0 N
RAID_BOSS_WHISPER 255 221 0 N
FILTERED 255 0 0 N
RESTRICTED 255 0 0 N
BATTLENET 255 255 255 N
ACHIEVEMENT 255 255 0 Y
GUILD_ACHIEVEMENT 64 255 64 Y
ARENA_POINTS 255 255 255 N
PARTY_LEADER 118 200 255 Y
TARGETICONS 255 255 0 N
BN_WHISPER 0 255 246 N
BN_WHISPER_INFORM 0 255 246 N
BN_CONVERSATION 0 177 240 N
BN_CONVERSATION_NOTICE 0 177 240 N
BN_CONVERSATION_LIST 0 177 240 N
BN_INLINE_TOAST_ALERT 130 197 255 N
BN_INLINE_TOAST_BROADCAST 130 197 255 N
BN_INLINE_TOAST_BROADCAST_INFORM 130 197 255 N
BN_INLINE_TOAST_CONVERSATION 130 197 255 N
BN_WHISPER_PLAYER_OFFLINE 255 255 0 N
COMBAT_GUILD_XP_GAIN 111 111 255 N
CURRENCY 0 170 0 N
QUEST_BOSS_EMOTE 255 128 64 N
PET_BATTLE_COMBAT_LOG 231 222 171 N
PET_BATTLE_INFO 225 222 93 N
INSTANCE_CHAT 255 127 0 Y
INSTANCE_CHAT_LEADER 255 72 9 Y
CHANNEL1 255 192 192 Y
CHANNEL2 255 192 192 Y
CHANNEL3 255 192 192 Y
CHANNEL4 255 192 192 Y
CHANNEL5 255 192 192 Y
CHANNEL6 255 192 192 Y
CHANNEL7 255 192 192 Y
CHANNEL8 255 192 192 Y
CHANNEL9 255 192 192 Y
CHANNEL10 255 192 192 Y
END

WINDOW 1
NAME ChatFrame1
SIZE 14
COLOR 0 0 0 0
LOCKED 1
UNINTERACTABLE 0
DOCKED 1
SHOWN 0
POSITION BOTTOMLEFT 2.000000 7.000000
DIMENSIONS 461.000000 197.000000

MESSAGES
BN_WHISPER_INFORM
BN_WHISPER_PLAYER_OFFLINE
END

CHANNELS
END

ZONECHANNELS 0

END

WINDOW 2
NAME Combat Log
SIZE 14
COLOR 0 0 0 0
LOCKED 1
UNINTERACTABLE 0
DOCKED 2
SHOWN 0
POSITION BOTTOMLEFT 2.000000 7.000000
DIMENSIONS 461.000000 197.000000

MESSAGES
OPENING
PET_INFO
COMBAT_MISC_INFO
END

CHANNELS
END

ZONECHANNELS 0

END

WINDOW 3
NAME Sink
SIZE 14
COLOR 0 0 0 0
LOCKED 1
UNINTERACTABLE 0
DOCKED 0
SHOWN 1
POSITION BOTTOMRIGHT -2.000000 7.000000
DIMENSIONS 461.000000 113.000000

MESSAGES
SYSTEM
MONSTER_SAY
MONSTER_YELL
MONSTER_EMOTE
MONSTER_WHISPER
MONSTER_BOSS_EMOTE
MONSTER_BOSS_WHISPER
ERRORS
AFK
DND
IGNORED
COMBAT_FACTION_CHANGE
SKILL
LOOT
MONEY
CHANNEL
ACHIEVEMENT
GUILD_ACHIEVEMENT
TARGETICONS
BN_INLINE_TOAST_ALERT
CURRENCY
PET_BATTLE_COMBAT_LOG
PET_BATTLE_INFO
OPENING
PET_INFO
COMBAT_XP_GAIN
COMBAT_HONOR_GAIN
COMBAT_MISC_INFO
COMBAT_GUILD_XP_GAIN
END

CHANNELS
END

ZONECHANNELS 0

END

WINDOW 4
SIZE 14
COLOR 0 0 0 0
LOCKED 0
UNINTERACTABLE 0
DOCKED 0
SHOWN 0

MESSAGES
END

CHANNELS
END

ZONECHANNELS 0

END

WINDOW 5
SIZE 14
COLOR 0 0 0 0
LOCKED 0
UNINTERACTABLE 0
DOCKED 0
SHOWN 0

MESSAGES
END

CHANNELS
END

ZONECHANNELS 0

END

WINDOW 6
NAME Chat
SIZE 14
COLOR 0 0 0 0
LOCKED 1
UNINTERACTABLE 0
DOCKED 5
SHOWN 1
POSITION BOTTOMLEFT 2.000000 7.000000
DIMENSIONS 461.000000 197.000000

MESSAGES
SAY
EMOTE
WHISPER
PARTY
PARTY_LEADER
RAID
RAID_LEADER
RAID_WARNING
GUILD
OFFICER
BN_WHISPER
BN_CONVERSATION
INSTANCE_CHAT
INSTANCE_CHAT_LEADER
END

CHANNELS
END

ZONECHANNELS 0

END

WINDOW 7
NAME Trade
SIZE 14
COLOR 0 0 0 0
LOCKED 1
UNINTERACTABLE 0
DOCKED 4
SHOWN 0
POSITION BOTTOMLEFT 2.000000 7.000000
DIMENSIONS 461.000000 197.000000

MESSAGES
YELL
END

CHANNELS
LookingForGroup
END

ZONECHANNELS 35651587

END

WINDOW 8
SIZE 14
COLOR 0 0 0 0
LOCKED 0
UNINTERACTABLE 0
DOCKED 0
SHOWN 0

MESSAGES
END

CHANNELS
END

ZONECHANNELS 0

END

WINDOW 9
SIZE 14
COLOR 0 0 0 0
LOCKED 1
UNINTERACTABLE 0
DOCKED 0
SHOWN 0
MESSAGES
END

CHANNELS
END

ZONECHANNELS 0

END

WINDOW 10
SIZE 14
COLOR 0 0 0 0
LOCKED 1
UNINTERACTABLE 0
DOCKED 0
SHOWN 0
MESSAGES
END

CHANNELS
END

ZONECHANNELS 0

END
]]
-- There was a SYSTEM_NOMENU entry in the original file.  I removed it.  I think it was an old message group that
-- doesn't exist anymore, but isn't removed from chat-cache.txt automatically.
--
-- An entry like "SAY 255 255 255 Y" in the COLORS section means that chat messages of the SAY message type should have
-- the color white ("255 255 255" RBG triplet) and the name of the player sending the message should be class colored
-- ("Y").
------------------------------------------------------------------------------------------------------------------------

-- vim: tw=120 sts=2 sw=2 et
