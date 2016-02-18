InventorySlotStyles = {
  [InventorySlotHead] = "HeadSlot",
  [InventorySlotBody] = "BodySlot",
  [InventorySlotBelt] = "BeltSlot",
  [InventorySlotLeg] = "LegSlot",
  [InventorySlotFeet] = "FeetSlot",
  [InventorySlotNeck] = "NeckSlot",
  [InventorySlotRight] = "RightSlot",
  [InventorySlotFinger] = "FingerSlot",
  [InventorySlotGlooves] = "GloovesSlot",
  [InventorySlotRobe] = "RobeSlot",
  [InventorySlotLeft] = "LeftSlot",
  [InventorySlotBack] = "BackpackSlot",
  [InventorySlotBag] = "BagSlot",
  [InventorySlotBracelet] = "BraceletSlot",
  [InventorySlotExtra] = "ExtraSlot",
}

inventoryWindow = nil
inventoryButton = nil
inventoryPanel = nil

local invetoryPanelVisibility = true

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
  
  inventoryWindow:setup()

  refresh()
end

function terminate()
  disconnect(LocalPlayer, {
    onInventoryChange = onInventoryChange,
    onFreeCapacityChange = onFreeCapacityChange,
  })
  disconnect(g_game, { onGameStart = refresh })

  g_keyboard.unbindKeyDown('I')

  inventoryWindow:destroy()
end

function refresh()
  local player = g_game.getLocalPlayer()
  for i = InventorySlotFirst, InventorySlotLast, 1 do
  
    if g_game.isOnline() then
      onInventoryChange(player, i, player:getInventoryItem(i))
    else
      onInventoryChange(player, i, nil)
    end
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

  itemPanel = inventoryPanel:getChildById('slot' .. slot)
  itemWidget = itemPanel:getChildById('itemSlot' .. slot)
  if item then
    itemPanel:setImageColor('#ffffffff')
    itemWidget:setStyle('InventoryItem')
    itemWidget:setImageColor('#ffffffff')
    itemWidget:setItem(item)
  else
    itemPanel:setImageColor('#676767ff')
    itemPanel:setBorderWidth(1)
    itemWidget:setStyle(InventorySlotStyles[slot])  
    itemWidget:setImageColor('#a9a9a9ff') 
    itemWidget:setBorderWidth(0)
    itemWidget:setItem(nil)
  end
end

function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    if string.len(OUT) == 0 then
      OUT = "00"
    elseif string.len(OUT) <= 1 then
      OUT = '0' .. OUT 
    end
    return OUT
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
