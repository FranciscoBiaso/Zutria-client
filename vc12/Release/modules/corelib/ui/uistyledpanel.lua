-- @docclass
UIStyledPanel = extends(UIWidget, "UIStyledPanel")

function UIStyledPanel.create()
  local styledPanel = UIStyledPanel.internalCreate()  
  styledPanel:setDraggable(true)
  styledPanel:setFocusable(false)
  return styledPanel
end

function UIStyledPanel:onDragEnter(mousePos)
  self:breakAnchors()
  self.movingReference = { x = mousePos.x - self:getX(), y = mousePos.y - self:getY() }
  
  local mapPanel = modules.game_interface.getMapPanel()
  mapPanel:removeAnchor(AnchorBottom)
  return true
end

function UIStyledPanel:onDragLeave(droppedWidget, mousePos)
  -- TODO: auto detect and reconnect anchors  
end

function UIStyledPanel:onDragMove(mousePos, mouseMoved)
  local pos = { x = mousePos.x - self.movingReference.x, y = mousePos.y - self.movingReference.y }
  self:setPosition(pos)
  self:bindRectToParent()
end
