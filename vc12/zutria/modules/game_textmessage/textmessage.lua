messagesPanel = nil
local bit = require("bit")
local topMenu = nil
function init()
  for msgName, msgMode in pairs(MessageModes) do
    if msgMode ~= MessageModes.MSG_LOOK then
      registerMessageMode(msgMode, displayMessage)
    end
  end
  topMenu = modules.client_topmenu.getTopMenu()
  connect(g_game, 'onGameEnd', clearMessages)
  messagesPanel = g_ui.loadUI('textmessage', modules.game_interface.getRootPanel())
end

function terminate()
  for msgName, msgMode in pairs(MessageModes) do
    if msgMode ~= MessageModes.MSG_LOOK then
      unregisterMessageMode(msgMode, displayMessage)
    end
  end

  disconnect(g_game, 'onGameEnd', clearMessages)
  clearMessages()
  messagesPanel:destroy()
  topMenu = nil
end

function calculateVisibleTime(text)
  if not text then return 4000 end
  return math.max(#text * 100, 4000)
end

function displayMessage(targetGui, mode, color, text)

  if not g_game.isOnline() then return end
  
  labelBottomMap = nil
  labelMiddleCenterMap = nil
  
  local msg_color = MessageColors[color]
  
  if bit.band(targetGui, MessageGUITarget.MSG_TARGET_CONSOLE) 
     ==  MessageGUITarget.MSG_TARGET_CONSOLE then
    --modules.game_console.addText(text, mode, 0, 'Padrão')
    --TODO move to game_console
  end
  
  if bit.band(targetGui, MessageGUITarget.MSG_TARGET_BOTTOM_CENTER_MAP)
     == MessageGUITarget.MSG_TARGET_BOTTOM_CENTER_MAP then
    --labelBottomMap = messagesPanel:recursiveGetChildById('bottomLabel')
    --labelBottomMap:setColor(msg_color)
    --displayMessageLabel(labelBottomMap, text)    
    topMenu:setText(text)
    topMenu:setColor(msg_color)
    scheduleEvent(function()  topMenu:setText('') end, calculateVisibleTime(text))
  end
  
  if bit.band(targetGui, MessageGUITarget.MSG_TARGET_TOP_CENTER_MAP)
     == MessageGUITarget.MSG_TARGET_TOP_CENTER_MAP then
    labelMiddleCenterMap = messagesPanel:recursiveGetChildById('middleCenterLabel')
    labelMiddleCenterMap:setColor(msg_color)
    displayMessageLabel(labelMiddleCenterMap, text)
  end
 
end

function displayMessageLabel(label, text)
  label:setText(text)
  label:setVisible(true)
  removeEvent(label.hideEvent)
  label.hideEvent = scheduleEvent(function() label:setVisible(false) end, calculateVisibleTime(text))
end

function displayPrivateMessage(text)
  displayMessage(MessageGUITarget.MSG_TARGET_TOP_CENTER_MAP,
  MessageModes.MSG_PLAYER_PRIVATE_FROM,
  MessageColors[7],
  text)
end

function displayStatusMessage(text)
  displayMessage(MessageGUITarget.MSG_TARGET_BOTTOM_CENTER_MAP,
  MessageModes.MSG_INFORMATION, 
  MessageColors.MSG_COLOR_WHITE,
  text)
end

function displayFailureMessage(text)
  displayMessage(MessageGUITarget.MSG_TARGET_BOTTOM_CENTER_MAP,
  MessageModes.MSG_INFORMATION, 
  MessageColors.MSG_COLOR_ORGANE,
  MessageModes.MSG_INFORMATION, text)
end

function displayGameMessage(text)
  displayMessage(MessageGUITarget.MSG_TARGET_BOTTOM_CENTER_MAP,
  MessageModes.MSG_INFORMATION, 
  MessageColors.MSG_COLOR_WHITE,
  text)
end

function displayBroadcastMessage(text)
  displayMessage(MessageGUITarget.MSG_TARGET_BOTTOM_CENTER_MAP,
  MessageModes.MSG_BROADCAST, 
  MessageColors.MSG_COLOR_WHITE,
  text)
end

function clearMessages()
  for _i,child in pairs(messagesPanel:recursiveGetChildren()) do
    if child:getId():match('Label') then
      child:hide()
      removeEvent(child.hideEvent)
    end
  end
end

function LocalPlayer:onAutoWalkFail(player)
  modules.game_textmessage.displayFailureMessage(tr('There is no way.'))
end