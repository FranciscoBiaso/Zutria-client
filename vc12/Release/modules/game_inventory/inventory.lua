--[1]name, [2]imageClip [3]position
InventorySlots = {
  {"HeadSlot",     {9  * 32, 0 * 32}, {x=65535, y=1,  z=0}},
  {"BodySlot",     {3  * 32, 0 * 32}, {x=65535, y=2,  z=0}},
  {"BeltSlot",     {2  * 32, 0 * 32}, {x=65535, y=3,  z=0}},
  {"LegSlot",      {11 * 32, 0 * 32}, {x=65535, y=4,  z=0}},
  {"FeetSlot",     {6  * 32, 0 * 32}, {x=65535, y=5,  z=0}},
  {"NeckSlot",     {12 * 32, 0 * 32}, {x=65535, y=6,  z=0}},
  {"RightSlot",    {0  * 32, 1 * 32}, {x=65535, y=7,  z=0}},
  {"FingerSlot",   {7  * 32, 0 * 32}, {x=65535, y=8,  z=0}},
  {"GloovesSlot",  {8  * 32, 0 * 32}, {x=65535, y=9,  z=0}},
  {"RobeSlot",     {14 * 32, 0 * 32}, {x=65535, y=10, z=0}},
  {"LeftSlot",     {1  * 32, 1 * 32}, {x=65535, y=11, z=0}},
  {"BackpackSlot", {0  * 32, 0 * 32}, {x=65535, y=12, z=0}},
  {"BagSlot",      {1  * 32, 0 * 32}, {x=65535, y=13, z=0}},
  {"BraceletSlot", {4  * 32, 0 * 32}, {x=65535, y=14, z=0}},
  {"ExtraSlot",    {5  * 32, 0 * 32}, {x=65535, y=15, z=0}},
}

inventoryWindow = nil
inventoryButton = nil
inventoryPanel = nil

function init()
  connect(LocalPlayer, {
    onInventoryChange = onInventoryChange,
    onFreeCapacityChange = onFreeCapacityChange,
    onUpdateLocalBalance = onUpdateLocalBalance,
  })
  connect(g_game, { onGameStart = refresh })
  
  inventoryButton = modules.client_topmenu.addRightGameToggleButton('InventoryButton', tr('equipamentos') .. ' (ctrl + E)', '/images/topbuttons/equipament', toggle)
  inventoryButton:setOn(true)
  
  g_keyboard.bindKeyDown('ctrl + E', toggle)

  inventoryWindow = g_ui.loadUI('inventory', modules.game_interface.getRootPanel())
  inventoryPanel = inventoryWindow:getChildById('inventoryPanel') 
  --inventoryWindow:disableResize()
  
  local topSetPanel = inventoryWindow:getChildById('topSet')
  local circlePanel = topSetPanel:getChildById('circle')
  circlePanel:setIcon('/images/game/slots/armor')
  circlePanel:setIconColor('#ffffffbb')
  
  
  refresh()
  --inventoryWindow:setup()
end

function terminate()
  disconnect(LocalPlayer, {
    onInventoryChange = onInventoryChange,
    onFreeCapacityChange = onFreeCapacityChange,
  })
  disconnect(g_game, { onGameStart = refresh })

  g_keyboard.unbindKeyDown('I')

  inventoryWindow:destroy()
  inventoryButton:destroy()
  inventoryPanel:destroy()
end

function refresh()
  local player = g_game.getLocalPlayer()
  for i = InventorySlotFirst, InventorySlotLast, 1 do  
    if g_game.isOnline() then
      onInventoryChange(player, i, player:getInventoryItem(i))
    else
      onInventoryChange(player, i, nil)
    end
    slotPanel = inventoryPanel:getChildById('slot' .. i)
    itemWidget = slotPanel:getChildById('itemSlot' .. i)
    itemWidget:changePos(InventorySlots[i][3])
  end
  
  
end

function toggle()
  if inventoryButton:isOn() then
    inventoryWindow:hide()
    inventoryButton:setOn(false)
  else
    inventoryWindow:show()
    inventoryButton:setOn(true)
  end
end

function onInventoryWindowClose()
  inventoryButton:setOn(false)
end

-- hooked events
function onInventoryChange(player, slot, item, oldItem)
  if slot > InventorySlotLast then return end

  slotPanel = inventoryPanel:getChildById('slot' .. slot)
  itemWidget = slotPanel:getChildById('itemSlot' .. slot)
  if item then
    slotPanel:setImageColor('#ffffffff')
    itemWidget:setImageColor('#ffffff00')
    itemWidget:setItem(item)
  else
    slotPanel:setImageColor('#ffffffff')
    itemWidget:setImageClip(InventorySlots[slot][2][1] .. ' ' .. InventorySlots[slot][2][2] .. ' ' .. 32 .. ' ' .. 32)  
       
    itemWidget:setImageColor('#454545ff') 
    itemWidget:setItem(nil)
  end
end

function onFreeCapacityChange(player, freeCapacity)
  capacityValueLabel = inventoryPanel:getChildById('capacityValueLabel')
  totalCapacityValue = player:getSkillValue(3)/100
  capPercentage = (freeCapacity/totalCapacityValue)
  capBar = inventoryPanel:recursiveGetChildById('capBar')
  
  color = nil
  if capPercentage * 100 >= 50 then
    capacityValueLabel:setColor('#' .. DEC_HEX(255.0 * (50-(100 * capPercentage-50))/50.0) .. 'ff00ff')
    color = '#' .. DEC_HEX(255.0 * (50-(100 * capPercentage-50))/50.0) .. 'ff00ff'
    --capacityBar:setBackgroundColor('#' .. DEC_HEX(255.0 * (50-(capPercentage-50))/50.0) .. 'ff00ff')
  else    
    capacityValueLabel:setColor('#ff' .. DEC_HEX(255.0 * 100 * capPercentage / 50.0) .. '00ff')
    color = '#ff' .. DEC_HEX(255.0 * 100 * capPercentage / 50.0) .. '00ff'
    --capacityBar:setBackgroundColor('#ff' .. DEC_HEX(255.0 * capPercentage / 50.0) .. '00ff')
  end
  capacityValueLabel:setText('! ' .. freeCapacity .. ' izis')
  
  local height = 32 - capPercentage * 32
  --capacityBar:setPercent(100 - capPercentage) 
  capBar:setHeight(height)  
  --modules.game_interface.getGameTextChatPanel():setText(height)
  
  capBar:setIconClip({x = 0, y = 32 - height, width = 32,height = height })
  capBar:setIconColor(color)
end

function getInventoryWindow()
  return inventoryWindow
end

function onUpdateLocalBalance(player, countMoneyChanged)
  moneyLabel = inventoryPanel:getChildById('moneyLabel')
  moneyLabel:setText('$ ' ..  tostring(countMoneyChanged) .. '.0')
end
