-- @docclass
UISpellButton = extends(UIButton, "UISpellButton")

function UISpellButton.create()
  local button = UISpellButton.internalCreate()
  button:setFocusable(false)
  button:setDraggable(true)
  button.panel = nil
  button.imageXClip = 0
  button.imageYClip = 0
  button.playerHasSpell = false
  return button
end

function UISpellButton:onMouseRelease(pos, button)
  return self:isPressed()
end

function UISpellButton:onDragEnter(mousePos)
  if self.playerHasSpell == true then
    modules.game_interface.getSpellPanel():setImageColor('#ff000099')   
    self.movingReference = { x = mousePos.x - self:getX(), y = mousePos.y - self:getY()}
    
    self.panel = g_ui.createWidget('UIButton',modules.game_interface.getRootPanel())
    self.panel:setImageSource('/images/game/spells/spells')
    self.panel:setBorderWidth(1)
    self.panel:setBorderColor('#989898ff')
    self.panel:setImageClip(self.imageXClip .. ' ' .. self.imageYClip .. ' ' .. 32 .. ' ' .. 32)
    self.panel:setWidth(32)
    self.panel:setHeight(32)
    self.panel:show()  
  return true
  else
    return false
  end
end

function UISpellButton:onDragLeave(droppedWidget, mousePos)
  modules.game_interface.getSpellPanel():setImageColor('#bcbcbc22') 
  local pos = { x = mousePos.x, y = mousePos.y}
  spellGroupWidget = modules.game_interface.getSpellPanel():getChildByPos(pos)
  if spellGroupWidget ~= nil then
    spellIcon = spellGroupWidget:getChildById('spellIcon')
    if spellIcon ~= nil then
      spellIcon:setImageSource('/images/game/spells/spells')
      spellIcon:setImageClip(self.imageXClip .. ' ' .. self.imageYClip .. ' ' .. 32 .. ' ' .. 32)
    end
  end
  -- TODO: auto detect and reconnect anchors
  self.panel:destroy()  
end

function UISpellButton:onDragMove(mousePos, mouseMoved)    
  local pos = { x = mousePos.x - self.movingReference.x, y = mousePos.y - self.movingReference.y }
  self.panel:setPosition(pos)
  self.panel:bindRectToParent()
end

function UISpellButton:setDraggingImageClip(xClip, yClip)
  self.imageXClip = xClip
  self.imageYClip = yClip
end

function UISpellButton:setPlayerHasSpell(value)
  self.playerHasSpell = value
end