-- @docclass
UISpellButton = extends(UIButton, "UISpellButton")

function UISpellButton.create()
  local button = UISpellButton.internalCreate()
  button:setFocusable(false)
  button:setDraggable(true)
  button.panel = nil
  button.imageXClip = 0
  button.imageYClip = 0
  button.spellId = nil
  button.hasSpell = nil
  return button
end

function UISpellButton:onMouseRelease(pos, button)
  return self:isPressed()
end

function UISpellButton:onDragEnter(mousePos)
  if self.hasSpell then
    modules.game_interface.getSpellPanel():setImageColor('#FFAAAAFF')   
    self.movingReference = { x = mousePos.x - self:getX(), y = mousePos.y - self:getY()}
    
    self.panel = g_ui.createWidget('UIButton',modules.game_interface.getRootPanel())
    self.panel:setImageSource('/images/game/spells/spells')
    self.panel:setBorderWidth(1)
    self.panel:setBorderColor('#989898ff')
    self.panel:setImageClip(self.imageXClip .. ' ' .. self.imageYClip .. ' ' .. 32 .. ' ' .. 32)
    self.panel:setWidth(30)
    self.panel:setHeight(30)
    self.panel:show()  
    return true
  else
    return false
  end
end

function UISpellButton:onDragLeave(droppedWidget, mousePos)
  modules.game_interface.getSpellPanel():setImageColor('#ffffffff') 
  local pos = { x = mousePos.x, y = mousePos.y}
  local spellGroupWidget = modules.game_interface.getChildSpellPanel():getChildByPos(pos)
  if spellGroupWidget ~= nil then
    local spellIcon = spellGroupWidget:getChildById('spellIcon')    
    if spellIcon ~= nil then
      spellIcon:setImageSource('/images/game/spells/spells')
      spellIcon:setImageColor('#ffffffff')
      spellIcon:setImageClip(self.imageXClip .. ' ' .. self.imageYClip .. ' ' .. 32 .. ' ' .. 32)
      
      --save the spell with the proper hotkey
      hotKeyText = spellGroupWidget:recursiveGetChildById('spellHotkeyText'):getText()
      modules.game_hotkeys.saveHotkey(hotKeyText, self.spellId)
    end
    local spellPanel = spellGroupWidget:getParent()
    spellPanel:onGeometryChange()
  end
  -- TODO: auto detect and reconnect anchors
  self.panel:destroy() 
  self.panel = nil
end

function UISpellButton:onDragMove(mousePos, mouseMoved)    
  local pos = { x = mousePos.x - self.movingReference.x, y = mousePos.y - self.movingReference.y }
  self.panel:setPosition(pos)
  self.panel:bindRectToParent()
end

function UISpellButton:setImageClipOfTempButton(xClip, yClip)
  self.imageXClip = xClip
  self.imageYClip = yClip
end

function UISpellButton:setSpellId(spellId)
  self.spellId = spellId
end

function UISpellButton:getSpellId()
  return self.spellId
end

function UISpellButton:addSpell()
  self.hasSpell = true
end