local lookPanel = nil

function init()
  lookPanel = g_ui.loadUI('look', modules.game_interface.getRootPanel())
  
  registerMessageMode(20 , displayMessage)
  
  lookPanel:hide()
end

function terminate()
  unregisterMessageMode(20, displayMessage)
  lookPanel:destroy() 
end

function calculateVisibleTime(text)
  return math.max(#text * 100, 4000)
end

function displayMessage(mode, text)
  if not g_game.isOnline() then return end
  
  local sprite = lookPanel:getChildById('sprite')
  local thingType = string.sub(text,1,string.find(text,'#') - 1)
  text = string.sub(text,string.find(text,'#') + 1,#text)
  local sprId = string.sub(text,1,string.find(text,'#') - 1)
  text = string.sub(text,string.find(text,'#') + 1,#text)
  sprite:setImageSpriteById(thingType, sprId)
  local label = lookPanel:getChildById('lookLabel')
  label:setText(text)
  lookPanel:setVisible(true)
  removeEvent(lookPanel.hideEvent)
  lookPanel.hideEvent = scheduleEvent(function() lookPanel:setVisible(false) end, calculateVisibleTime(text))  
end