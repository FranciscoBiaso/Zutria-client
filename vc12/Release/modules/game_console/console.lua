SpeakTypesSettings = {
  none = {},
  say = { speakType = MessageModes.MSG_PLAYER_TALK, color = '#ffffff' },
  whisper = { speakType = MessageModes.MSG_PLAYER_WHISPER, color = '#FFFF00' },
  yell = { speakType = MessageModes.MSG_PLAYER_YELL, color = '#FFFF00' },
  broadcast = { speakType = MessageModes.MSG_BROADCAST, color = '#F55E5E' },
  privateFrom = { speakType = MessageModes.MSG_PLAYER_PRIVATE_FROM, color = '#5FF7F7', private = true },
  privatePlayerToPlayer = { speakType = MessageModes.MSG_PLAYER_PRIVATE_TO, color = '#9F9DFD', private = true },
  monsterSay = { speakType = MessageModes.MSG_MONSTER_TALK, color = '#FE6500', hideInConsole = true},
  monsterYell = { speakType = MessageModes.MSG_MONSTER_YELL, color = '#FE6500', hideInConsole = true},
}

SpeakTypes = {
  [MessageModes.MSG_PLAYER_TALK] = SpeakTypesSettings.say,
  [MessageModes.MSG_PLAYER_WHISPER] = SpeakTypesSettings.whisper,
  [MessageModes.MSG_PLAYER_YELL] = SpeakTypesSettings.yell,
  [MessageModes.MSG_BROADCAST] = SpeakTypesSettings.broadcast,
  [MessageModes.MSG_PLAYER_PRIVATE_FROM] = SpeakTypesSettings.privateFrom,
  [MessageModes.MSG_PLAYER_PRIVATE_TO] = SpeakTypesSettings.privatePlayerToPlayer,
  [MessageModes.MSG_MONSTER_TALK] = SpeakTypesSettings.monsterSay,
  [MessageModes.MSG_MONSTER_YELL] = SpeakTypesSettings.monsterYell,
}

SayModes = {
  [1] = { speakTypeDesc = 'whisper', icon = '/images/game/console/whisper' },
  [2] = { speakTypeDesc = 'say', icon = '/images/game/console/say' },
  [3] = { speakTypeDesc = 'yell', icon = '/images/game/console/yell' }
}

MAX_HISTORY = 500
MAX_LINES = 100
HELP_CHANNEL = 9

consolePanel = nil
consoleContentPanel = nil
consoleTabBar = nil
consoleTextEdit = nil
channels = nil
channelsWindow = nil
communicationWindow = nil
ownPrivateName = nil
messageHistory = {}
currentMessageIndex = 0
ignoreNpcMessages = false
defaultTab = nil
ignoredChannels = {}
intervalTimeBetweenMsgs = 0
statTalkingTime = 0


local breathReductionCount = 1.2
local breathRegenerationCount = 5
local breathRegenerationTimeStep = 500
local maxBreath = 200 -- seconds of breath
local currentBreath = maxBreath
local regenerating = false
local breathBar = nil

local communicationSettings = {
  useIgnoreList = true,
  useWhiteList = true,
  privateMessages = false,
  yelling = false,
  allowVIPs = false,
  ignoredPlayers = {},
  whitelistedPlayers = {}
}

function init()
  connect(g_game, {
    onTalk = onTalk,
    onChannelList = onChannelList,
    onOpenChannel = onOpenChannel,
    onOpenPrivateChannel = onOpenPrivateChannel,
    onOpenOwnPrivateChannel = onOpenOwnPrivateChannel,
    onCloseChannel = onCloseChannel,
    onGameStart = online,
    onGameEnd = offline
  })
  
  connect( LocalPlayer,{
    onBreathChange = onBreathChange,
    })

  consolePanel = g_ui.loadUI('console', modules.game_interface.getBottomPanel())
  consoleTextEdit = consolePanel:getChildById('consoleTextEdit')
  consoleContentPanel = consolePanel:getChildById('consoleContentPanel')
  consoleTabBar = consolePanel:getChildById('consoleTabBar')
  consoleTabBar:setContentWidget(consoleContentPanel)
  channels = {}

  local breathPanel = modules.game_interface.getBreathBarPanel()
  breathBar = g_ui.createWidget('BreathBar',breathPanel)
  breathBar:setValue(currentBreath,0,maxBreath)
  
  consolePanel.onKeyPress = function(self, keyCode, keyboardModifiers)
    if not (keyboardModifiers == KeyboardCtrlModifier and keyCode == KeyC) then return false end

    local tab = consoleTabBar:getCurrentTab()
    if not tab then return false end

    local selection = tab.tabPanel:getChildById('consoleBuffer').selectionText
    if not selection then return false end

    g_window.setClipboardText(selection)
    return true
  end

  g_keyboard.bindKeyPress('Shift+Up', function() navigateMessageHistory(1) end, consolePanel)
  g_keyboard.bindKeyPress('Shift+Down', function() navigateMessageHistory(-1) end, consolePanel)
  g_keyboard.bindKeyPress('Tab', function() consoleTabBar:selectNextTab() end, consolePanel)
  g_keyboard.bindKeyPress('Shift+Tab', function() consoleTabBar:selectPrevTab() end, consolePanel)
  g_keyboard.bindKeyDown('Enter', sendCurrentMessage, consolePanel)
  g_keyboard.bindKeyPress('Ctrl+X', function() consoleTextEdit:clearText() end, consolePanel)

  -- apply buttom functions after loaded
  consoleTabBar:setNavigation(consolePanel:getChildById('prevChannelButton'), consolePanel:getChildById('nextChannelButton'))
  consoleTabBar.onTabChange = onTabChange

  -- tibia like hotkeys
  g_keyboard.bindKeyDown('Ctrl+O', g_game.requestChannels)
  g_keyboard.bindKeyDown('Ctrl+E', removeCurrentTab)

  consoleToggleChat = consolePanel:getChildById('toggleChat')
  load()

  if g_game.isOnline() then
     online()     
  end
end

function clearSelection(consoleBuffer)
  for _,label in pairs(consoleBuffer:getChildren()) do
    label:clearSelection()
  end
  consoleBuffer.selectionText = nil
  consoleBuffer.selection = nil
end

function selectAll(consoleBuffer)
  clearSelection(consoleBuffer)
  if consoleBuffer:getChildCount() > 0 then
    local text = {}
    for _,label in pairs(consoleBuffer:getChildren()) do
      label:selectAll()
      table.insert(text, label:getSelection())
    end
    consoleBuffer.selectionText = table.concat(text, '\n')
    consoleBuffer.selection = { first = consoleBuffer:getChildIndex(consoleBuffer:getFirstChild()), last = consoleBuffer:getChildIndex(consoleBuffer:getLastChild()) }
  end
end

function toggleChat()
  if consoleToggleChat:isChecked() then
    disableChat()
  else
    enableChat()
  end
end

function enableChat()
  local gameInterface = modules.game_interface

  consoleTextEdit:setVisible(true)
  consoleTextEdit:setText("")

  g_keyboard.unbindKeyUp("Space")
  g_keyboard.unbindKeyUp("Enter")
  g_keyboard.unbindKeyUp("Escape")

  gameInterface.unbindWalkKey("W")
  gameInterface.unbindWalkKey("D")
  gameInterface.unbindWalkKey("S")
  gameInterface.unbindWalkKey("A")

  gameInterface.unbindWalkKey("E")
  gameInterface.unbindWalkKey("Q")
  gameInterface.unbindWalkKey("C")
  gameInterface.unbindWalkKey("Z")

  consoleToggleChat:setTooltip(tr("Disable chat mode, allow to walk using ASDW"))
end

function disableChat()
  local gameInterface = modules.game_interface

  consoleTextEdit:setVisible(false)
  consoleTextEdit:setText("")

  local quickFunc = function()
    if consoleToggleChat:isChecked() then
      consoleToggleChat:setChecked(false)
    end
    enableChat()
  end
  g_keyboard.bindKeyUp("Space", quickFunc)
  g_keyboard.bindKeyUp("Enter", quickFunc)
  g_keyboard.bindKeyUp("Escape", quickFunc)

  gameInterface.bindWalkKey("W", North)
  gameInterface.bindWalkKey("D", East)
  gameInterface.bindWalkKey("S", South)
  gameInterface.bindWalkKey("A", West)

  gameInterface.bindWalkKey("E", NorthEast)
  gameInterface.bindWalkKey("Q", NorthWest)
  gameInterface.bindWalkKey("C", SouthEast)
  gameInterface.bindWalkKey("Z", SouthWest)

  consoleToggleChat:setTooltip(tr("Enable chat mode"))
end

function terminate()
  save()
  disconnect(g_game, {
    onTalk = onTalk,
    onChannelList = onChannelList,
    onOpenChannel = onOpenChannel,
    onOpenPrivateChannel = onOpenPrivateChannel,
    onOpenOwnPrivateChannel = onOpenPrivateChannel,
    onCloseChannel = onCloseChannel,
    onGameStart = online,
    onGameEnd = offline
  })
  
  disconnect( LocalPlayer,{
    onBreathChange = onBreathChange,
    })

  if g_game.isOnline() then clear() end

  g_keyboard.unbindKeyDown('Ctrl+O')
  g_keyboard.unbindKeyDown('Ctrl+E')
  g_keyboard.unbindKeyDown('Ctrl+H')

  saveCommunicationSettings()

  if channelsWindow then
    channelsWindow:destroy()
  end

  if communicationWindow then
    communicationWindow:destroy()
  end
  
  breathBar:destroy()
  consoleTabBar = nil
  consoleContentPanel = nil
  consoleToggleChat = nil
  consoleTextEdit = nil

  consolePanel:destroy()
  consolePanel = nil
  ownPrivateName = nil

  Console = nil
end

function save()
  local settings = {}
  settings.messageHistory = messageHistory
  g_settings.setNode('game_console', settings)
end

function load()
  local settings = g_settings.getNode('game_console')
  if settings then
    messageHistory = settings.messageHistory or {}
  end
  loadCommunicationSettings()
end

function onTabChange(tabBar, tab)
  if tab == defaultTab then
    consolePanel:getChildById('closeChannelButton'):disable()
  else
    consolePanel:getChildById('closeChannelButton'):enable()
  end
end

function clear()
  -- save last open channels
  local lastChannelsOpen = g_settings.getNode('lastChannelsOpen') or {}
  local char = g_game.getCharacterName()
  local savedChannels = {}
  local set = false
  for channelId, channelName in pairs(channels) do
    if type(channelId) == 'number' then
      savedChannels[channelName] = channelId
      set = true
    end
  end
  if set then
    lastChannelsOpen[char] = savedChannels
  else
    lastChannelsOpen[char] = nil
  end
  g_settings.setNode('lastChannelsOpen', lastChannelsOpen)

  -- close channels
  for _, channelName in pairs(channels) do
    local tab = consoleTabBar:getTab(channelName)
    consoleTabBar:removeTab(tab)
  end
  channels = {}

  consoleTabBar:removeTab(defaultTab)
  defaultTab = nil  

  local npcTab = consoleTabBar:getTab('NPCs')
  if npcTab then
    consoleTabBar:removeTab(npcTab)
    npcTab = nil
  end

  consoleTextEdit:clearText()

  if channelsWindow then
    channelsWindow:destroy()
    channelsWindow = nil
  end
end

function clearChannel(consoleTabBar)
  consoleTabBar:getCurrentTab().tabPanel:getChildById('consoleBuffer'):destroyChildren()
end

function setTextEditText(text)
  consoleTextEdit:setText(text)
  consoleTextEdit:setCursorPos(-1)
end

function addTab(name, focus)
  local tab = getTab(name)
  if not tab then -- is channel already open
    tab = consoleTabBar:addTab(name, nil, processChannelTabMenu)
  end
  if focus then
    consoleTabBar:selectTab(tab)
  end
  return tab
end

function removeTab(tab)
  if type(tab) == 'string' then
    tab = consoleTabBar:getTab(tab)
  end

  if tab == defaultTab then
    return
  end

  if tab.channelId then
    -- notificate the server that we are leaving the channel
    for k, v in pairs(channels) do
      if (k == tab.channelId) then channels[k] = nil end
    end
    g_game.leaveChannel(tab.channelId)
  end

  consoleTabBar:removeTab(tab)
end

function removeCurrentTab()
  removeTab(consoleTabBar:getCurrentTab())
end

function getTab(name)
  return consoleTabBar:getTab(name)
end

function getChannelTab(channelId)
  local channel = channels[channelId]
  if channel then
    return getTab(channel)
  end
  return nil
end

function getCurrentTab()
  return consoleTabBar:getCurrentTab()
end

function addChannel(name, id)
  channels[id] = name
  local focus = not table.find(ignoredChannels, id)
  local tab = addTab(name, focus)
  tab.channelId = id
  return tab
end

function addPrivateChannel(receiver)
  channels[receiver] = receiver
  return addTab(receiver, true)
end

function addPrivateText(text, textColor, name, isPrivateCommand, creatureName)
  local privateTab = getTab(name)
  if not privateTab then return end
  addTabText(text, textColor, privateTab, creatureName)
end

function addText(text, textColor, tabName, creatureName)
  local tab = getTab(tabName)
  if tab ~= nil then
    addTabText(text, textColor, tab, creatureName)
  end
end

-- Return information about start, end in the string and the highlighted words
function getHighlightedText(text)
  local tmpData = {}

  repeat
    local tmp = {string.find(text, "{([^}]+)}", tmpData[#tmpData-1])}
    for _, v in pairs(tmp) do
      table.insert(tmpData, v)
    end
  until not(string.find(text, "{([^}]+)}", tmpData[#tmpData-1]))

  return tmpData
end

function addTabText(text, textColor, tab, creatureName)
  if not tab or tab.locked or not text or #text == 0 then return end

  if modules.client_options.getOption('showTimestampsInConsole') then
    text = os.date('%H:%M') .. ' ' .. text
  end

  local panel = consoleTabBar:getTabPanel(tab)
  local consoleBuffer = panel:getChildById('consoleBuffer')
  local label = g_ui.createWidget('ConsoleLabel', consoleBuffer)
  label:setId('consoleLabel' .. consoleBuffer:getChildCount())
  label:setText(text)
  label:setColor(textColor)
  consoleTabBar:blinkTab(tab)

  -- Overlay for consoleBuffer which shows highlighted words only

  label.name = creatureName
  consoleBuffer.onMouseRelease = function(self, mousePos, mouseButton)
    processMessageMenu(mousePos, mouseButton, nil, nil, nil, tab)
  end
  label.onMouseRelease = function(self, mousePos, mouseButton)
    processMessageMenu(mousePos, mouseButton, creatureName, text, self, tab)
  end
  label.onMousePress = function(self, mousePos, button)
    if button == MouseLeftButton then clearSelection(consoleBuffer) end
  end
  label.onDragEnter = function(self, mousePos)
    clearSelection(consoleBuffer)
    return true
  end
  label.onDragLeave = function(self, droppedWidget, mousePos)
    local text = {}
    for selectionChild = consoleBuffer.selection.first, consoleBuffer.selection.last do
      local label = self:getParent():getChildByIndex(selectionChild)
      table.insert(text, label:getSelection())
    end
    consoleBuffer.selectionText = table.concat(text, '\n')
    return true
  end
  label.onDragMove = function(self, mousePos, mouseMoved)
    local parent = self:getParent()
    local parentRect = parent:getPaddingRect()
    local selfIndex = parent:getChildIndex(self)
    local child = parent:getChildByPos(mousePos)

    -- find bonding children
    if not child then
      if mousePos.y < self:getY() then
        for index = selfIndex - 1, 1, -1 do
          local label = parent:getChildByIndex(index)
          if label:getY() + label:getHeight() > parentRect.y then
            if (mousePos.y >= label:getY() and mousePos.y <= label:getY() + label:getHeight()) or index == 1 then
              child = label
              break
            end
          else
            child = parent:getChildByIndex(index + 1)
            break
          end
        end
      elseif mousePos.y > self:getY() + self:getHeight() then
        for index = selfIndex + 1, parent:getChildCount(), 1 do
          local label = parent:getChildByIndex(index)
          if label:getY() < parentRect.y + parentRect.height then
            if (mousePos.y >= label:getY() and mousePos.y <= label:getY() + label:getHeight()) or index == parent:getChildCount() then
              child = label
              break
            end
          else
            child = parent:getChildByIndex(index - 1)
            break
          end
        end
      else
        child = self
      end
    end

    if not child then return false end

    local childIndex = parent:getChildIndex(child)

    -- remove old selection
    clearSelection(consoleBuffer)

    -- update self selection
    local textBegin = self:getTextPos(self:getLastClickPosition())
    local textPos = self:getTextPos(mousePos)
    self:setSelection(textBegin, textPos)

    consoleBuffer.selection = { first = math.min(selfIndex, childIndex), last = math.max(selfIndex, childIndex) }

    -- update siblings selection
    if child ~= self then
      for selectionChild = consoleBuffer.selection.first + 1, consoleBuffer.selection.last - 1 do
        parent:getChildByIndex(selectionChild):selectAll()
      end

      local textPos = child:getTextPos(mousePos)
      if childIndex > selfIndex then
        child:setSelection(0, textPos)
      else
        child:setSelection(string.len(child:getText()), textPos)
      end
    end
    
    return true
  end

  if consoleBuffer:getChildCount() > MAX_LINES then
    local child = consoleBuffer:getFirstChild()
    clearSelection(consoleBuffer)
    child:destroy()
  end
end

function removeTabLabelByName(tab, name)
  local panel = consoleTabBar:getTabPanel(tab)
  local consoleBuffer = panel:getChildById('consoleBuffer')
  for _,label in pairs(consoleBuffer:getChildren()) do
    if label.name == name then
      label:destroy()
    end
  end
end

function processChannelTabMenu(tab, mousePos, mouseButton)
  local menu = g_ui.createWidget('PopupMenu')
  menu:setGameMenu(true)

  channelName = tab:getText()
  if tab ~= defaultTab then
    menu:addOption(tr('Close'), function() removeTab(channelName) end)
    --menu:addOption(tr('Show Server Messages'), function() --[[TODO]] end)
    menu:addSeparator()
  end

  if consoleTabBar:getCurrentTab() == tab then
    menu:addOption(tr('Clear Messages'), function() clearChannel(consoleTabBar) end)
    menu:addOption(tr('Save Messages'), function()
      local panel = consoleTabBar:getTabPanel(tab)
      local consoleBuffer = panel:getChildById('consoleBuffer')
      local lines = {}
      for _,label in pairs(consoleBuffer:getChildren()) do
        table.insert(lines, label:getText())
      end

      local filename = channelName .. '.txt'
      local filepath = '/' .. filename

      -- extra information at the beginning
      table.insert(lines, 1, os.date('\nChannel saved at %a %b %d %H:%M:%S %Y'))

      if g_resources.fileExists(filepath) then
        table.insert(lines, 1, protectedcall(g_resources.readFileContents, filepath) or '')
      end

      g_resources.writeFileContents(filepath, table.concat(lines, '\n'))
      modules.game_textmessage.displayStatusMessage(tr('Channel appended to %s', filename))
    end)
  end

  menu:display(mousePos)
end

function processMessageMenu(mousePos, mouseButton, creatureName, text, label, tab)
  if mouseButton == MouseRightButton then
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    if creatureName and #creatureName > 0 then
      if creatureName ~= g_game.getCharacterName() then
        menu:addOption(tr('Message to ' .. creatureName), function () g_game.openPrivateChannel(creatureName) end)
        if not g_game.getLocalPlayer():hasVip(creatureName) then
          menu:addOption(tr('Add to VIP list'), function () g_game.addVip(creatureName) end)
        end
        if modules.game_console.getOwnPrivateTab() then
          menu:addSeparator()
          menu:addOption(tr('Invite to private chat'), function() g_game.inviteToOwnChannel(creatureName) end)
          menu:addOption(tr('Exclude from private chat'), function() g_game.excludeFromOwnChannel(creatureName) end)
        end
        if isIgnored(creatureName) then
          menu:addOption(tr('Unignore') .. ' ' .. creatureName, function() removeIgnoredPlayer(creatureName) end)
        else
          menu:addOption(tr('Ignore') .. ' ' .. creatureName, function() addIgnoredPlayer(creatureName) end)
        end
        menu:addSeparator()
      end

      menu:addOption(tr('Copy name'), function () g_window.setClipboardText(creatureName) end)
    end
    local selection = tab.tabPanel:getChildById('consoleBuffer').selectionText
    if selection and #selection > 0 then
      menu:addOption(tr('Copy'), function() g_window.setClipboardText(selection) end, '(Ctrl+C)')
    end
    if text then
      menu:addOption(tr('Copy message'), function() g_window.setClipboardText(text) end)
    end
    menu:addOption(tr('Select all'), function() selectAll(tab.tabPanel:getChildById('consoleBuffer')) end)   
    menu:display(mousePos)
  end
end

function sendCurrentMessage()  
  local message = consoleTextEdit:getText()
  if currentBreath < breathReductionCount * #message then return end

  if #message == 0 then return end
  consoleTextEdit:clearText()

  -- send message
  sendMessage(message)
end

function sendMessage(message, tab)
  if #message == 0 then return end

  local tab = tab or getCurrentTab()
  if not tab then return end
  
  -- add new command to history
  if #messageHistory == 0 or messageHistory[#messageHistory] ~= message then
    table.insert(messageHistory, message)
    if #messageHistory > MAX_HISTORY then
      table.remove(messageHistory, 1)
    end
  end

  local tabName = tab:getText()
  if tab == defaultTab then
    g_game.talk(message)  
  else
    g_game.talkPrivate(MessageModes.MSG_PLAYER_PRIVATE_FROM, tabName, message)
    local player = g_game.getLocalPlayer()
    message = applyMessagePrefixies(g_game.getCharacterName(), player:getLevel(), message)    
    addPrivateText(message, '#00ff00', tabname, false, g_game.getCharacterName())
  end
end

function sayModeChange(sayMode)
  local buttom = consolePanel:getChildById('sayModeButton')
  if sayMode == nil then
    sayMode = buttom.sayMode + 1
  end

  if sayMode > #SayModes then sayMode = 1 end

  buttom:setIcon(SayModes[sayMode].icon)
  buttom.sayMode = sayMode
end

function getOwnPrivateTab()
  if not ownPrivateName then return end
  return getTab(ownPrivateName)
end

function navigateMessageHistory(step)
  local numCommands = #messageHistory
  if numCommands > 0 then
    currentMessageIndex = math.min(math.max(currentMessageIndex + step, 0), numCommands)
    if currentMessageIndex > 0 then
      local command = messageHistory[numCommands - currentMessageIndex + 1]
      setTextEditText(command)
    else
      consoleTextEdit:clearText()
    end
  end
end

function applyMessagePrefixies(name, level, message)
  if name then
    if modules.client_options.getOption('showLevelsInConsole') and level > 0 then
      message = name .. ' [' .. level .. ']: ' .. message
    else
      message = name .. ': ' .. message
    end
  end
  return message
end

function calculateVisibleTime(text)
  return math.max(#text * 100, 3000)
end

function breathRegeneration(cuBreath)
  if cuBreath < maxBreath then  
      regenerating = true
      if cuBreath >= 0.8 * maxBreath then
        cuBreath = cuBreath + breathRegenerationCount - breathRegenerationCount * 0.4
      elseif cuBreath >= 0.6 * maxBreath then
        cuBreath = cuBreath + breathRegenerationCount - breathRegenerationCount * 0.5
      elseif cuBreath >= 0.4 * maxBreath then
        cuBreath = cuBreath + breathRegenerationCount - breathRegenerationCount * 0.6
      elseif cuBreath >= 0.2 * maxBreath then
        cuBreath = cuBreath + breathRegenerationCount - breathRegenerationCount * 0.7
      elseif cuBreath >= 0 * maxBreath then
         cuBreath = cuBreath + breathRegenerationCount - breathRegenerationCount * 0.8
      end
      currentBreath = cuBreath
      breathBar:setValue(currentBreath,0,maxBreath)
      scheduleEvent(function() breathRegeneration(currentBreath) end, breathRegenerationTimeStep)
  else
    cuBreath = maxBreath
    regenerating = false
  end
end

function breathReduction(messageCount)
  if currentBreath > 0 then  
    currentBreath = currentBreath - breathReductionCount * messageCount
  end  
  
  if currentBreath <= 0 then
    currentBreath = 1
    return 
  end
  
  breathBar:setValue(currentBreath,0,maxBreath)
end

function onTalk(name, level, mode, message, channelId, creaturePos)
  intervalTimeBetweenMsgs = os.clock() - statTalkingTime
  statTalkingTime = os.clock()  
  
  if mode == MessageModes.MSG_BROADCAST then
    modules.game_textmessage.displayBroadcastMessage(name .. ': ' .. message)
    return
  end
  
  local localPlayer = g_game.getLocalPlayer()
  if name ~= g_game.getCharacterName()
        and isUsingIgnoreList()
        and not(isUsingWhiteList()) or 
        (isUsingWhiteList() and not(isWhitelisted(name))
        and not(isAllowingVIPs() and localPlayer:hasVip(name))) then
    if mode == MessageModes.MSG_PLAYER_TALK and isIgnoringYelling() then
      return
    elseif speaktype.private and isIgnoringPrivate() then
      return
    elseif isIgnored(name) then
      return
    end
  end 

  if (mode == MessageModes.MSG_PLAYER_TALK or 
      mode == MessageModes.MSG_PLAYER_WHISPER or
      mode == MessageModes.MSG_PLAYER_YELL) and creaturePos then
  if intervalTimeBetweenMsgs < 0.2 then -- 200 mil seconds
    breathReduction(#message * 20.0) -- + 300% factor  
  elseif intervalTimeBetweenMsgs < 0.4 then -- 400 mil seconds
    breathReduction(#message * 18.0) -- + 250% factor  
  elseif intervalTimeBetweenMsgs < 0.6 then -- 600 mil seconds
    breathReduction(#message * 15.0) -- + 200% factor  
  elseif intervalTimeBetweenMsgs < 1.0 then
    breathReduction(#message * 12.0) -- + 100% factor  
  elseif intervalTimeBetweenMsgs < 2.0 then
    breathReduction(#message * 6.0) -- + 100% factor  
  elseif intervalTimeBetweenMsgs < 3.0 then
    breathReduction(#message * 4.0) -- + 100% factor  
  else
   breathReduction(#message * 1.0) -- + 100% factor 
  end
  
  if regenerating == false then
    scheduleEvent(function() if g_game.isOnline() then breathRegeneration(currentBreath) end end, breathRegenerationTimeStep)
  end
  
    local staticText = StaticText.create()
    local staticMessage = message    
    staticText:setFont('verdana-11px-rounded')
    staticText:setColor('#FFFFFF')
    staticText:addMessage(name, mode, staticMessage)
    -- local animatedText = AnimatedText.create()
    -- animatedText:setText(message)    
    -- animatedText:addMessage(message)    
    -- animatedText:setColor(0xFFFF66FF)       
    -- animatedText:setDuration(calculateVisibleTime(message))   
    -- animatedText:setFont('verdana-11px-rounded')      
    g_map.addThing(staticText, creaturePos, -1)
    local channel = 'Padrão'
    -- i am talking, so lets talk white text
  local composedMessage = applyMessagePrefixies(name, level, message)
    --if name == localPlayer:getName() then -- my msg i see blue
      addText(composedMessage, '#A0A0A0', channel, name)  
   -- else -- near player is talking, so lets see  white
      --addText(composedMessage, '#808080', channel, name)  
    --end    
  elseif (mode == MessageModes.MSG_MONSTER_TALK or 
         mode == MessageModes.MSG_MONSTER_YELL) and creaturePos then
    local animatedText = AnimatedText.create()
    animatedText:setText(message)  
    animatedText:setColor32(0xFFE5CCAA)  
    animatedText:setDuration(calculateVisibleTime(message))   
    animatedText:setFont('verdana-11px-rounded')      
    g_map.addThing(animatedText, creaturePos, -1)   
  end
    

 
  if mode == MessageModes.MSG_PLAYER_PRIVATE_FROM then
    addPrivateText(composedMessage, '#00ff00', name, false, name)
    if modules.client_options.getOption('showPrivateMessagesOnScreen') then
      modules.game_textmessage.displayPrivateMessage(name .. ':\n' .. message)
    end
  end
end

function onOpenChannel(channelId, channelName)
  addChannel(channelName, channelId)
end

function onOpenPrivateChannel(receiver)
  addPrivateChannel(receiver)
end

function onOpenOwnPrivateChannel(channelId, channelName)
  local privateTab = getTab(channelName)
  if privateTab == nil then
    addChannel(channelName, channelId)
  end
  ownPrivateName = channelName
end

function onCloseChannel(channelId)
  local channel = channels[channelId]
  if channel then
    local tab = getTab(channel)
    if tab then
      consoleTabBar:removeTab(tab)
    end
    for k, v in pairs(channels) do
      if (k == tab.channelId) then channels[k] = nil end
    end
  end
end

function doChannelListSubmit()
  local channelListPanel = channelsWindow:getChildById('channelList')
  local openPrivateChannelWith = channelsWindow:getChildById('openPrivateChannelWith'):getText()
  if openPrivateChannelWith ~= '' then
    if openPrivateChannelWith:lower() ~= g_game.getCharacterName():lower() then
      g_game.openPrivateChannel(openPrivateChannelWith)
    else
      modules.game_textmessage.displayFailureMessage('You cannot create a private chat channel with yourself.')
    end
  else
    local selectedChannelLabel = channelListPanel:getFocusedChild()
    if not selectedChannelLabel then return end
    if selectedChannelLabel.channelId == 0xFFFF then
      g_game.openOwnChannel()
    else
      g_game.joinChannel(selectedChannelLabel.channelId)
    end
  end

  channelsWindow:destroy()
end

function onChannelList(channelList)
  if channelsWindow then channelsWindow:destroy() end
  channelsWindow = g_ui.displayUI('channelswindow')
  local channelListPanel = channelsWindow:getChildById('channelList')
  channelsWindow.onEnter = doChannelListSubmit
  channelsWindow.onDestroy = function() channelsWindow = nil end
  g_keyboard.bindKeyPress('Down', function() channelListPanel:focusNextChild(KeyboardFocusReason) end, channelsWindow)
  g_keyboard.bindKeyPress('Up', function() channelListPanel:focusPreviousChild(KeyboardFocusReason) end, channelsWindow)

  for k,v in pairs(channelList) do
    local channelId = v[1]
    local channelName = v[2]

    if #channelName > 0 then
      local label = g_ui.createWidget('ChannelListLabel', channelListPanel)
      label.channelId = channelId
      label:setText(channelName)

      label:setPhantom(false)
      label.onDoubleClick = doChannelListSubmit
    end
  end
end

function loadCommunicationSettings()
  communicationSettings.whitelistedPlayers = {}
  communicationSettings.ignoredPlayers = {}

  local ignoreNode = g_settings.getNode('IgnorePlayers')
  if ignoreNode then
    for i = 1, #ignoreNode do
      table.insert(communicationSettings.ignoredPlayers, ignoreNode[i])
    end
  end

  local whitelistNode = g_settings.getNode('WhitelistedPlayers')
  if whitelistNode then
    for i = 1, #whitelistNode do
      table.insert(communicationSettings.whitelistedPlayers, whitelistNode[i])
    end
  end

  communicationSettings.useIgnoreList = g_settings.getBoolean('UseIgnoreList')
  communicationSettings.useWhiteList = g_settings.getBoolean('UseWhiteList')
  communicationSettings.privateMessages = g_settings.getBoolean('IgnorePrivateMessages')
  communicationSettings.yelling = g_settings.getBoolean('IgnoreYelling')
  communicationSettings.allowVIPs = g_settings.getBoolean('AllowVIPs')
end

function saveCommunicationSettings()
  local tmpIgnoreList = {}
  local ignoredPlayers = getIgnoredPlayers()
  for i = 1, #ignoredPlayers do
    table.insert(tmpIgnoreList, ignoredPlayers[i])
  end

  local tmpWhiteList = {}
  local whitelistedPlayers = getWhitelistedPlayers()
  for i = 1, #whitelistedPlayers do
    table.insert(tmpWhiteList, whitelistedPlayers[i])
  end

  g_settings.set('UseIgnoreList', communicationSettings.useIgnoreList)
  g_settings.set('UseWhiteList', communicationSettings.useWhiteList)
  g_settings.set('IgnorePrivateMessages', communicationSettings.privateMessages)
  g_settings.set('IgnoreYelling', communicationSettings.yelling)
  g_settings.setNode('IgnorePlayers', tmpIgnoreList)
  g_settings.setNode('WhitelistedPlayers', tmpWhiteList)
end

function getIgnoredPlayers()
  return communicationSettings.ignoredPlayers
end

function getWhitelistedPlayers()
  return communicationSettings.whitelistedPlayers
end

function isUsingIgnoreList()
  return communicationSettings.useIgnoreList
end

function isUsingWhiteList()
  return communicationSettings.useWhiteList
end

function isIgnored(name)
  return table.find(communicationSettings.ignoredPlayers, name, true)
end

function addIgnoredPlayer(name)
  if isIgnored(name) then return end
  table.insert(communicationSettings.ignoredPlayers, name)
end

function removeIgnoredPlayer(name)
  table.removevalue(communicationSettings.ignoredPlayers, name)
end

function isWhitelisted(name)
  return table.find(communicationSettings.whitelistedPlayers, name, true)
end

function addWhitelistedPlayer(name)
  if isWhitelisted(name) then return end
  table.insert(communicationSettings.whitelistedPlayers, name)
end

function removeWhitelistedPlayer(name)
  table.removevalue(communicationSettings.whitelistedPlayers, name)
end

function isIgnoringPrivate()
  return communicationSettings.privateMessages
end

function isIgnoringYelling()
  return communicationSettings.yelling
end

function isAllowingVIPs()
  return communicationSettings.allowVIPs
end

function onClickIgnoreButton()
  if communicationWindow then return end
  communicationWindow = g_ui.displayUI('communicationwindow')
  local ignoreListPanel = communicationWindow:getChildById('ignoreList')
  local whiteListPanel = communicationWindow:getChildById('whiteList')
  communicationWindow.onDestroy = function() communicationWindow = nil end

  local useIgnoreListBox = communicationWindow:getChildById('checkboxUseIgnoreList')
  useIgnoreListBox:setChecked(communicationSettings.useIgnoreList)
  local useWhiteListBox = communicationWindow:getChildById('checkboxUseWhiteList')
  useWhiteListBox:setChecked(communicationSettings.useWhiteList)

  local removeIgnoreButton = communicationWindow:getChildById('buttonIgnoreRemove')
  removeIgnoreButton:disable()
  ignoreListPanel.onChildFocusChange = function() removeIgnoreButton:enable() end
  removeIgnoreButton.onClick = function()
    local selection = ignoreListPanel:getFocusedChild()
    if selection then
      ignoreListPanel:removeChild(selection)
      selection:destroy()
    end
    removeIgnoreButton:disable()
  end

  local removeWhitelistButton = communicationWindow:getChildById('buttonWhitelistRemove')
  removeWhitelistButton:disable()
  whiteListPanel.onChildFocusChange = function() removeWhitelistButton:enable() end
  removeWhitelistButton.onClick = function()
    local selection = whiteListPanel:getFocusedChild()
    if selection then
      whiteListPanel:removeChild(selection)
      selection:destroy()
    end
    removeWhitelistButton:disable()
  end

  local newlyIgnoredPlayers = {}
  local addIgnoreName = communicationWindow:getChildById('ignoreNameEdit')
  local addIgnoreButton = communicationWindow:getChildById('buttonIgnoreAdd')
  local addIgnoreFunction = function()
      local newEntry = addIgnoreName:getText()
      if newEntry == '' then return end
      if table.find(getIgnoredPlayers(), newEntry) then return end
      if table.find(newlyIgnoredPlayers, newEntry) then return end
      local label = g_ui.createWidget('IgnoreListLabel', ignoreListPanel)
      label:setText(newEntry)
      table.insert(newlyIgnoredPlayers, newEntry)
      addIgnoreName:setText('')
    end
  addIgnoreButton.onClick = addIgnoreFunction

  local newlyWhitelistedPlayers = {}
  local addWhitelistName = communicationWindow:getChildById('whitelistNameEdit')
  local addWhitelistButton = communicationWindow:getChildById('buttonWhitelistAdd')
  local addWhitelistFunction = function()
      local newEntry = addWhitelistName:getText()
      if newEntry == '' then return end
      if table.find(getWhitelistedPlayers(), newEntry) then return end
      if table.find(newlyWhitelistedPlayers, newEntry) then return end
      local label = g_ui.createWidget('WhiteListLabel', whiteListPanel)
      label:setText(newEntry)
      table.insert(newlyWhitelistedPlayers, newEntry)
      addWhitelistName:setText('')
    end
  addWhitelistButton.onClick = addWhitelistFunction

  communicationWindow.onEnter = function()
      if addWhitelistName:isFocused() then
        addWhitelistFunction()
      elseif addIgnoreName:isFocused() then
        addIgnoreFunction()
      end
    end

  local ignorePrivateMessageBox = communicationWindow:getChildById('checkboxIgnorePrivateMessages')
  ignorePrivateMessageBox:setChecked(communicationSettings.privateMessages)
  local ignoreYellingBox = communicationWindow:getChildById('checkboxIgnoreYelling')
  ignoreYellingBox:setChecked(communicationSettings.yelling)
  local allowVIPsBox = communicationWindow:getChildById('checkboxAllowVIPs')
  allowVIPsBox:setChecked(communicationSettings.allowVIPs)

  local saveButton = communicationWindow:recursiveGetChildById('buttonSave')
  saveButton.onClick = function()
      communicationSettings.ignoredPlayers = {}
      for i = 1, ignoreListPanel:getChildCount() do
        addIgnoredPlayer(ignoreListPanel:getChildByIndex(i):getText())
      end

      communicationSettings.whitelistedPlayers = {}
      for i = 1, whiteListPanel:getChildCount() do
        addWhitelistedPlayer(whiteListPanel:getChildByIndex(i):getText())
      end

      communicationSettings.useIgnoreList = useIgnoreListBox:isChecked()
      communicationSettings.useWhiteList = useWhiteListBox:isChecked()
      communicationSettings.yelling = ignoreYellingBox:isChecked()
      communicationSettings.privateMessages = ignorePrivateMessageBox:isChecked()
      communicationSettings.allowVIPs = allowVIPsBox:isChecked()
      communicationWindow:destroy()
    end

  local cancelButton = communicationWindow:recursiveGetChildById('buttonCancel')
  cancelButton.onClick = function()
      communicationWindow:destroy()
    end

  local ignoredPlayers = getIgnoredPlayers()
  for i = 1, #ignoredPlayers do
    local label = g_ui.createWidget('IgnoreListLabel', ignoreListPanel)
    label:setText(ignoredPlayers[i])
  end

  local whitelistedPlayers = getWhitelistedPlayers()
  for i = 1, #whitelistedPlayers do
    local label = g_ui.createWidget('WhiteListLabel', whiteListPanel)
    label:setText(whitelistedPlayers[i])
  end
end

function online()
  defaultTab = addTab(tr('Padrão'), true)

  if g_game.getClientVersion() < 862 then
    --g_keyboard.bindKeyDown('Ctrl+R', openPlayerReportRuleViolationWindow)
  end
  -- open last channels
  local lastChannelsOpen = g_settings.getNode('lastChannelsOpen')
  if lastChannelsOpen then
    local savedChannels = lastChannelsOpen[g_game.getCharacterName()]
    if savedChannels then
      for channelName, channelId in pairs(savedChannels) do
        channelId = tonumber(channelId)
        if channelId ~= -1 and channelId < 100 then
          if not table.find(channels, channelId) then
            g_game.joinChannel(channelId)
            table.insert(ignoredChannels, channelId)
          end
        end
      end
    end
  end
  scheduleEvent(function() ignoredChannels = {} end, 3000)
end

function offline()
  clear()
  
  if currentBreath < maxBreath then
    g_game.sendBreath(currentBreath)
  end
end

function onBreathChange(localPlayer, breath)
  currentBreath = breath
  if currentBreath < maxBreath and regenerating == false then
    regenerating = true
    scheduleEvent(function() breathRegeneration(currentBreath) end, 0)
  end
end

