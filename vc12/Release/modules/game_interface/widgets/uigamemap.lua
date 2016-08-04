UIGameMap = extends(UIMap, "UIGameMap")

function UIGameMap.create()
  local gameMap = UIGameMap.internalCreate()
  gameMap:setKeepAspectRatio(true)  
  gameMap:setLimitVisibleRange(false)
  gameMap:setDrawLights(true)    
  return gameMap
end

function UIGameMap:onDragEnter(mousePos)
  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = tile:getTopMoveThing()
  if not thing then return false end

  self.currentDragThing = thing

  g_mouse.pushCursor('target')
  self.allowNextRelease = false
  return true
end

function UIGameMap:onDragLeave(droppedWidget, mousePos)
  self.currentDragThing = nil
  self.hoveredWho = nil
  g_mouse.popCursor('target')
  return true
end

function UIGameMap:onDrop(widget, mousePos)
  if not self:canAcceptDrop(widget, mousePos) then return false end

  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = widget.currentDragThing
  local toPos = tile:getPosition()

  local thingPos = thing:getPosition()
  if thingPos.x == toPos.x and thingPos.y == toPos.y and thingPos.z == toPos.z then return false end

  if thing:isItem() and thing:getCount() > 1 then
    modules.game_interface.moveStackableItem(thing, toPos)
  else
    g_game.move(thing, toPos, 1)
  end

  return true
end

function UIGameMap:onMousePress()
  if not self:isDragging() then
    self.allowNextRelease = true
  end
end

function UIGameMap:onMouseRelease(mousePosition, mouseButton)

  if not self.allowNextRelease then
    return true
  end

  local autoWalkPos = self:getTilePosition(mousePosition)

  -- happens when clicking outside of map boundaries
  if not autoWalkPos then return false end

  local localPlayerPos = g_game.getLocalPlayer():getPosition()
  if autoWalkPos.z ~= localPlayerPos.z then
    local dz = autoWalkPos.z - localPlayerPos.z
    autoWalkPos.x = autoWalkPos.x + dz
    autoWalkPos.y = autoWalkPos.y + dz
    autoWalkPos.z = localPlayerPos.z
  end

  local lookThing
  local useThing
  local creatureThing
  local multiUseThing
  local attackCreature
  local tile = self:getTile(mousePosition)
  if tile then
    lookThing = tile:getTopLookThing()
    useThing = tile:getTopUseThing()
    creatureThing = tile:getTopCreature()
  end
  
  -- coins
  if lookThing:getId() == 2229 then
    modules.game_interface.getGameTextChatPanel():setText('coins')
  end

  local autoWalkTile = g_map.getTile(autoWalkPos)
  if autoWalkTile then
    attackCreature = autoWalkTile:getTopCreature()
  end
  
  local ret
  local isNpc = false
  if creatureThing then       
    if creatureThing:isNpc() then
      isNpc = true
      modules.game_npc.setTalkginNPc(modules.game_npc.getNpcIdByName(creatureThing:getName()))
      g_game.sendNpcLeftClick(creatureThing:getName())         
    end
  end
  if not isNpc then
    ret = modules.game_interface.processMouseAction(mousePosition, mouseButton, autoWalkPos, lookThing, useThing, creatureThing, attackCreature)  
  end
  if ret then
    self.allowNextRelease = false
  end

  return ret
end

function UIGameMap:canAcceptDrop(widget, mousePos)
  if not widget or not widget.currentDragThing then return false end

  local children = rootWidget:recursiveGetChildrenByPos(mousePos)
  for i=1,#children do
    local child = children[i]
    if child == self then
      return true
    elseif not child:isPhantom() then
      return false
    end
  end

  error('Widget ' .. self:getId() .. ' not in drop list.')
  return false
end

function UIGameMap:onMouseMove(mousePos, mouseMoved)


  mapPanel = modules.game_interface.getMapPanel()
  
  local pos = { x= mousePos.x - mapPanel:getPosition().x, y = mousePos.y - mapPanel:getPosition().y}
  mapPanel:setText(pos.x .. ' ' .. pos.y)
  
  if not g_mouse.isCursorChanged() then
     g_mouse.pushCursor('default')
  end

  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = tile:getTopThing()
  local creature = tile:getTopCreature()
  if not thing then return end
  
  if not creature then    
    if g_mouse.getTopCursorId() == 6 then --npc
      g_mouse.popCursor('npc')
    elseif g_mouse.getTopCursorId() == 7 then --battle
      g_mouse.popCursor('battle')
    elseif g_mouse.getTopCursorId() == 8 then --player
      g_mouse.popCursor('player')
    elseif g_mouse.getTopCursorId() == 9 then --inspect
      g_mouse.popCursor('inspect')
    end
    
    if thing:isPickupable() == true and not thing:isGround() and g_mouse.getTopCursorId() ~= 9 then
      g_mouse.pushCursor('inspect') 
    end
  else
    if g_mouse.getTopCursorId() == 9 then --inspect
      g_mouse.popCursor('inspect')
    end
    
    if creature:isNpc() and g_mouse.getTopCursorId() ~= 6 then
      g_mouse.pushCursor('npc')
    elseif creature:isMonster() and  g_mouse.getTopCursorId() ~= 7 then
      g_mouse.pushCursor('battle') 
    elseif creature:isPlayer() and  g_mouse.getTopCursorId() ~= 8 then
      g_mouse.pushCursor('player') 
    end
  end

  return true  
end
