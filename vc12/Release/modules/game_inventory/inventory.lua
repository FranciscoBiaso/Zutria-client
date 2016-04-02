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
  })
  connect(g_game, { onGameStart = refresh })
  
  inventoryButton = modules.client_topmenu.addRightGameToggleButton('InventoryButton', tr('equipamentos') .. ' (I)', '/images/topbuttons/equipament', toggle)
  inventoryButton:setOn(true)
  
  g_keyboard.bindKeyDown('I', toggle)

  inventoryWindow = g_ui.loadUI('inventory', modules.game_interface.getRightPanel())
  inventoryPanel = inventoryWindow:getChildById('contentsPanel') 
  inventoryWindow:disableResize()
  
  refresh()
  inventoryWindow:setup()
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
    inventoryWindow:close()
    inventoryButton:setOn(false)
  else
    inventoryWindow:open()
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
    slotPanel:setImageColor('#676767ff')
    slotPanel:setBorderWidth(1)
    itemWidget:setImageClip(InventorySlots[slot][2][1] .. ' ' .. InventorySlots[slot][2][2] .. ' ' .. 32 .. ' ' .. 32)  
    itemWidget:setImageColor('#a9a9a9ff') 
    itemWidget:setBorderWidth(0)
    itemWidget:setItem(nil)
  end
end

function onFreeCapacityChange(player, freeCapacity)
  capacityValueLabel = inventoryPanel:getChildById('capacityValueLabel')
  totalCapacityValue = player:getSkillValue(3)/100
  capPercentage = (freeCapacity/totalCapacityValue) * 100
  capacityBar = inventoryPanel:getChildById('capacityBar')
  
  if capPercentage >= 50 then
    capacityValueLabel:setColor('#' .. DEC_HEX(255.0 * (50-(capPercentage-50))/50.0) .. 'ff00ff')
    capacityBar:setBackgroundColor('#' .. DEC_HEX(255.0 * (50-(capPercentage-50))/50.0) .. 'ff00ff')
  else    
    capacityValueLabel:setColor('#ff' .. DEC_HEX(255.0 * capPercentage / 50.0) .. '00ff')
    capacityBar:setBackgroundColor('#ff' .. DEC_HEX(255.0 * capPercentage / 50.0) .. '00ff')
  end
  capacityValueLabel:setText(freeCapacity .. ' izis')
  
  capacityBar:setPercent(100 - capPercentage)
  
end
