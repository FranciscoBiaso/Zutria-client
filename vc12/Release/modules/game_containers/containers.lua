local containerList = List()

function init()
  g_ui.importStyle('container')

  connect(Container, { onOpen = onContainerOpen,
                       onClose = onContainerClose,
                       onSizeChange = onContainerChangeSize,
                       onUpdateItem = onContainerUpdateItem })
  connect(Game, { onGameEnd = clean() })

  reloadContainers()
   
end

function terminate()
  disconnect(Container, { onOpen = onContainerOpen,
                          onClose = onContainerClose,
                          onSizeChange = onContainerChangeSize,
                          onUpdateItem = onContainerUpdateItem })
  disconnect(Game, { onGameEnd = clean() })
end

function reloadContainers()
  clean()
  for _,container in pairs(g_game.getContainers()) do
    onContainerOpen(container)
  end
end

function clean()
  for containerid,container in pairs(g_game.getContainers()) do
    destroy(container)
  end
end

function destroy(container)
  if container.window then
    container.window:destroy()
    container.window = nil
    container.itemsPanel = nil
  end
end

function refreshContainerItems(container)
  for slot=0,container:getCapacity()-1 do
    local itemWidget = container.itemsPanel:getChildById('item' .. slot)
    itemWidget:setItem(container:getItem(slot))
  end

end

function onContainerOpen(container, previousContainer)
  
  local localPlayer = g_game.getLocalPlayer()
  local item = localPlayer:getInventoryItem(InventorySlotBack)
  
  local childPanel = modules.game_interface.getRootPanel():getChildByPos(modules.game_interface.getMousePos())
  local isPlayerInventory = false
  
  local containerWindow = nil
  local insert = false
  -- is a container from game scenario not player inventory
  if not item then
    containerWindow = g_ui.createWidget('GameContainerWindow', modules.game_interface.getRootPanel())  
    -- is a container of player inventory
    insert = true
   
  elseif  childPanel:getId() == "inventoryWindow" then
    isPlayerInventory = true
    containerWindow = g_ui.createWidget('ContainerWindow', modules.game_interface.getRootPanel())  
    local topSetPanel = containerWindow:getChildById('topSet')
    local circlePanel = topSetPanel:getChildById('circle')
    circlePanel:setIcon('/images/game/slots/backpack')
    circlePanel:setIconColor('#ffffffbb')
  else
    containerWindow = g_ui.createWidget('GameContainerWindow', modules.game_interface.getRootPanel()) 
    insert = true    
  end  
  
  --modules.game_interface.getGameTextChatPanel():setText(countContainersScenarioOpened)
  
  if isPlayerInventory then
    containerWindow:setHeight(math.ceil(container:getCapacity()/9) * 44 + 102)
  else
    containerWindow:setHeight(math.ceil(container:getCapacity()/11) * 44 + 24)   
  end
  
  
  containerWindow:setId('container' .. container:getId())
  local containerPanel = containerWindow:getChildById('contentsPanel')
  local containerItemWidget = containerWindow:getChildById('containerItemWidget')
  
  containerWindow.onClose = function()
    g_game.close(container)
  end

  local containerLabel = containerWindow:getChildById('containerLabel')
  
  local name = container:getName()
  name = name:sub(1,1):upper() .. name:sub(2)
  containerLabel:setText(name)

  containerItemWidget:setItem(container:getContainerItem())

  containerPanel:destroyChildren()
  for slot=0,container:getCapacity()-1 do
    local itemWidget = g_ui.createWidget('Item', containerPanel)
    itemWidget:setId('item' .. slot)
    itemWidget:setItem(container:getItem(slot))
    itemWidget:setMarginRight(2)
    itemWidget:setPadding(3)
    itemWidget.position = container:getSlotPosition(slot)

    if not container:isUnlocked() then
      itemWidget:setBorderColor('red')
    end
  end

  container.window = containerWindow
  container.itemsPanel = containerPanel
  
  if insert == true then
    containerList.add(container)
  end
  
  --modules.game_interface.getGameTextChatPanel():setText(tostring(container))
  ajusteScenarioContainers(containerList.getList())
end

function ajusteScenarioContainers(list)
  local List = list
  local counter = 0
  while List do    
    List.value.window:setMarginBottom(counter * 25)
    List.value.window:setMarginLeft(counter * 25)
    List = List.next
    counter = counter + 1
  end
  
end

function onContainerClose(container)
  destroy(container)
  containerList.del(container)
  
 --ajusteScenarioContainers(l)
 ajusteScenarioContainers(containerList.getList())
end

function onContainerChangeSize(container, size)
  if not container.window then return end
  refreshContainerItems(container)
end

function onContainerUpdateItem(container, slot, item, oldItem)
  if not container.window then return end
  local itemWidget = container.itemsPanel:getChildById('item' .. slot)
  itemWidget:setItem(item)
end

function closeContainer() 
  local childPanel = modules.game_interface.getRootPanel():getChildByPos(modules.game_interface.getMousePos())
  childPanel.onClose()
  childPanel:destroy()  
end