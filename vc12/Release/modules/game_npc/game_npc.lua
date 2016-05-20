local npcWindow = nil
local npcPanel = nil
local npcButtonSell = nil
local npcPurchaseButton = nil
local npcCraftButton = nil
local npcMissionButton = nil
local npcExitButton = nil
local npcSellTable = nil
local npcSellTableData = nil
local npcSellTableScrollBar = nil
local npcActionButton = nil
local talkingNpc = nil

function init()  
  npcWindow = g_ui.loadUI('game_npc', modules.game_interface:getMapPanel())
  npcWindow:hide()
  npcPanel = npcWindow:getChildById('npcPanel')
  
  -- buttons
  npcButtonSell = npcPanel:recursiveGetChildById('npcSellButton')
  npcButtonSell.onClick = onNpcButtonSell
  npcPurchaseButton = npcPanel:recursiveGetChildById('npcPurchaseButton')
  npcPurchaseButton.onClick = onNpcPurchaseButton
  npcCraftButton = npcPanel:recursiveGetChildById('npcCraftButton')
  npcCraftButton.onClick = onNpcCraftButton
  npcMissionButton = npcPanel:recursiveGetChildById('npcMissionButton')
  npcMissionButton.onClick = onNpcMissionButton
  npcExitButton = npcPanel:recursiveGetChildById('npcExitButton')
  npcExitButton.onClick = onNpcExitButton
 
  --tables
  npcSellTable = npcPanel:getChildById('npcSellTable')
  npcSellTable:setSorting(2, TABLE_SORTING_DESC)
  npcSellTableData = npcPanel:getChildById('npcSellTableData')
  npcSellTableScrollBar = npcPanel:getChildById('npcSellTableScrollBar')
  
  
  npcActionButton = npcWindow:getChildById('npcActionButton')
  
  npcActionButton:hide()
  
  connect(LocalPlayer, {
    onOpenNpcWindow = onOpenNpcWindow,
  })
end


function terminate()
  disconnect(LocalPlayer, {
    onOpenNpcWindow = onOpenNpcWindow,    
  })
  
end

function toggle()
  npcWindow:hide()
end

function onOpenNpcWindow(localPlayer, windowId)
  npcWindow:setText('npc: ' .. npcs[1][1])
  
  npcWindow:show()
  npcWindow:raise()
  npcWindow:focus()
end

function onNpcButtonSell()
  onButtonClick(1) -- sell id  
end

function onNpcPurchaseButton()
  onButtonClick(2) -- buy id
end

function onNpcCraftButton()
  onButtonClick(3) -- buy id
end

function onNpcMissionButton()
  onButtonClick(4) -- buy id
end

function onNpcExitButton()
  onButtonClick(5) -- exit id
end

function onButtonClick(buttonId)
  if not talkingNpc then return end
  
  if buttonId == 1 then -- sell id    
  elseif buttonId == 2 then -- buy id
    showSellWindow()
  elseif buttonId == 3 then -- craft id
  elseif buttonId == 4 then -- mission id
  elseif buttonId == 5 then -- exit window id  
    npcWindow:hide()
  end   
end

-- npcId is created inside npcs file [ 1 - ferreiro, 2 - etc]
function setTalkginNPc(npcId)
  talkingNpc = npcId
end

-- get npcId by name
function getNpcIdByName(npcName)
  for i=1,#npcs,1 do
    if npcs[i][1] == npcName then
      return i
    end
  end
  return nil
end


function hideButtons()
  npcPurchaseButton:hide()
  npcButtonSell:hide()
  npcCraftButton:hide()
  npcMissionButton:hide()  
  npcExitButton:hide()
end

function showSellWindow()
  
  npcWindow:setText('npc: ' .. npcs[1][1] .. ' - comprando')
  npcPanel:removeAnchor(AnchorBottom)
  npcPanel:addAnchor(AnchorBottom,'npcActionButton', AnchorTop)
  npcPanel:setMarginBottom(6)

  npcSellTable:addHeader(
  {
    {text = 'item', width = 190},
    {text = '$ preço unitário', width = 160},
    {text = 'quantidade', width = 150},
    {text = '$ preço acumulado', width = 220},
    }
  )
  
  npcSellTable:setColumnStyle('NpcInputBoxSpinBox', true, 3)
  
  row = npcSellTable:addRow({
         {sprId = 2219, text ='capa'},
         {text = '12'},
         {text = '0'},
         {text = '0'},
         }, 30)
  row = npcSellTable:addRow({
         {sprId = 2220, text ='espada de calda longa'},
         {text = '30'},
         {text = '0'},
         {text = '0'},
         }, 30)
  row = npcSellTable:addRow({
         {sprId = 2224},
         {text = '26'},
         {text = '0'},
         {text = '0'},
         }, 30) 
  row = npcSellTable:addRow({
         {sprId = 2222},
         {text = '6'},
         {text = '0'},
         {text = '0'},
         }, 30)         

         
  npcSellTableData:setVisible(true) 
  npcSellTableScrollBar:show()  
  
  npcActionButton:show()
  npcSellTable:show()
  
end

function changeTotalPriceOfSellTable(rowId)
  local amount = tonumber(npcSellTable:getCellData(rowId,3))
  local unityPrice = tonumber(npcSellTable:getCellData(rowId,2))
  local totalPrice = amount * unityPrice
  npcSellTable:setCellData(rowId, 4, totalPrice)   
end

function onNPCScrollUp(spinBox)
  local rowId = spinBox:getParent().rowId
  changeTotalPriceOfSellTable(rowId)
end

function onNPCButtonUp(spinBox)
  local rowId = spinBox:getParent().rowId
  changeTotalPriceOfSellTable(rowId)
end

function onNPCScrollDown(spinBox)
  local rowId = spinBox:getParent().rowId
  changeTotalPriceOfSellTable(rowId)     
end

function onNPCButtonDown(spinBox)
  local rowId = spinBox:getParent().rowId
  changeTotalPriceOfSellTable(rowId)     
end









