local lookPanel = nil

function init()
  lookPanel = g_ui.loadUI('look', modules.game_interface.getRootPanel())
  
  registerMessageMode(MessageModes.MSG_LOOK , displayMessage)
  
  lookPanel:hide()
end

function terminate()
  unregisterMessageMode(MessageModes.MSG_LOOK, displayMessage)
  lookPanel:destroy() 
end

function calculateVisibleTime(text)
  return math.max(#text * 100, 4000)
end

function displayMessage(targetGUI, msgMode, msgColor, msgtext)
  if not g_game.isOnline() then return end
  
  --local sprite = lookPanel:getChildById('sprite')
  local thingType = string.sub(msgtext,1,string.find(msgtext,'#') - 1)
  msgtext = string.sub(msgtext,string.find(msgtext,'#') + 1,#msgtext)
  local sprId = string.sub(msgtext,1,string.find(msgtext,'#') - 1)
  msgtext = string.sub(msgtext,string.find(msgtext,'#') + 1,#msgtext)
  --sprite:setImageSpriteById(thingType, sprId)
  local label = lookPanel:getChildById('lookLabel')
  label:setText(msgtext)
  lookPanel:setVisible(true)
  removeEvent(lookPanel.hideEvent)
  lookPanel.hideEvent = scheduleEvent(function() lookPanel:setVisible(false) end, calculateVisibleTime(msgtext))  
end