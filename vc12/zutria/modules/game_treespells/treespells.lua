local treeSpellsButton = nil
local treeSpellsWindow = nil
local treeSpellsPanel  = nil
local currentIterface = 0 --root or start interface
local tempListOfSpells = nil
local spellBoxTryed = nil

function init()  
  treeSpellsWindow = g_ui.loadUI('treespells', modules.game_interface.getMapPanel())
  treeSpellsWindow:hide()
  treeSpellsPanel = treeSpellsWindow:getChildById('IDTreeSpellsPanel')  

  
  treeSpellsButton = modules.client_topmenu.addRightGameToggleButton('treeSpellsButton', tr('árvore de habilidades') .. ' (ctrl + a)', '/images/topbuttons/hand', toggle)
  g_keyboard.bindKeyDown('ctrl + A', toggle)
  treeSpellsButton:setOn(false) 
  
  backInterfaceButton = treeSpellsWindow:getChildById('IDBackInterfaceButton')
  backInterfaceButton:setImageClip(interface_mini_buttons[1][1] .. ' ' .. interface_mini_buttons[1][2] 
                                   .. ' ' .. 16 .. ' ' .. 16)
                                   
  informationInterfaceButton = treeSpellsWindow:getChildById('IDInformationInterfaceButton')
  informationInterfaceButton:setImageClip(interface_mini_buttons[2][1] .. ' ' .. interface_mini_buttons[2][2] 
                                   .. ' ' .. 16 .. ' ' .. 16)
  informationInterfaceButton:setTooltip('informações genéricas sobre magias')                                  
  
  connect(g_game, {
    onGameStart = buildStartInterface(getStartModelInterface()),
    onGameEnd = removeListSpells,    
  })
  
  connect(LocalPlayer, {
    onSpellsChange = onSpellsChange,
    onSpellChange = onSpellChange,
  })
end

function terminate()
  currentIterface = 0  
  
  disconnect(g_game, {
    onGameStart = buildStartInterface(getStartModelInterface()),
    onGameEnd = removeListSpells,  
  })
  
  
  disconnect(LocalPlayer, {
    onSpellsChange = onSpellsChange,
    onSpellChange = onSpellChange,
  })
  
end

function removeListSpells()
  tempListOfSpells = nil
end

function toggle()
  if treeSpellsButton:isOn() then
    treeSpellsButton:setOn(false)
    treeSpellsWindow:hide()
  else
    treeSpellsButton:setOn(true)
    treeSpellsWindow:show()
    treeSpellsWindow:raise()
    treeSpellsWindow:focus()
  end
end

-- build tree functions
-- create graphical user interface of static model
function buildStartInterface(model)
  local count = 1
  for row=1, #model, 1 do
    for column=1, #model[row], 1 do      
      local interfaceImageButton = g_ui.createWidget('interfaceImageButton', treeSpellsPanel)
      interfaceImageButton.type = count
      interfaceImageButton.onClick = changeInterfaceLayout
      count = count + 1
      local interfaceClassImage = interfaceImageButton:getChildById('IDInterfaceClassImage')
      -- is a image
      local cell = model[row][column]
      interfaceClassImage:setImageClip(cell[1] .. ' ' .. cell[2] .. ' '
                                         .. 3 * 16 .. ' ' .. 3 * 16)                                         
                                             
      -- is the first column of each row
      updateLayoutPanel(interfaceImageButton, row, column, 15, 45)
    end
  end
end

-- type = mage/druid/knight/archer/etc
function buildSpellInterface(type)
  local model = getTableVocationSpells(type)  
  treeSpellsPanel:resize(42 * #model[1] + 20 + (#model[1] - 1) * 2, 
    50 * #model + 20 + (#model - 1) * 2)
  treeSpellsWindow:resize(treeSpellsPanel:getWidth() + 20, treeSpellsPanel:getHeight() + 50 + 16)
   for row=1, #model, 1 do
    for column=1, #model[row], 1 do      
      local cell = model[row][column]
      local panel = nil
      if cell[1] == 2 then -- spell image 
        panel = g_ui.createWidget('spellBoxImage', treeSpellsPanel)        
        panel:setId('IDSpellBoxPanel ' .. tostring(cell[2]))
        local spellImage = panel:getChildById('IDSpellImage')        
        spellImage:setImageClip(spells[cell[2]][3][1] 
          .. ' ' .. spells[cell[2]][3][2]  
          .. ' ' .. 32 .. ' ' .. 32) 
        spellImage:setImageClipOfTempButton(spells[cell[2]][3][1], spells[cell[2]][3][2])
        spellImage:setTooltip(createSpellTooltip(cell[2]))
        -- spell icon bottom right
        local spellTypePanel = spellImage:getChildById('spellTypePanelId')
        spellTypePanel:setImageClip(spellTypes[spells_description[cell[2]][1]][1][1] .. ' ' ..
                                    spellTypes[spells_description[cell[2]][1]][1][2] .. ' ' ..
                                    16 .. ' ' .. 16)
        --spellTypePanel:setTooltip('Tipo: ' .. transformSpellTypeToStr(spells_description[cell[2]][1]))
        --spell label
        local spellLabel = panel:getChildById('IDSpellLabel')
        spellLabel:setTooltip(createSpellLevelToolTip(cell[2]))
        spellLabel:setText('0/' .. spells[cell[2]][2])
      elseif cell[1] == 1 then -- arrow image
        panel = g_ui.createWidget('boxArrow', treeSpellsPanel)
        if cell[2] == 4 or cell[2] == 5 then
          panel:setPaddingTop(12)
        end
        local arrowImage = panel:getChildById('IDArrowImage')
        arrowImage:setImageClip(tab_arrows[cell[2]][1] .. ' ' .. tab_arrows[cell[2]][2] 
          .. ' ' .. 32 .. ' ' .. 32) 
      elseif cell[1] == 0 then -- hidden
        panel = g_ui.createWidget('boxPanel', treeSpellsPanel)      
      end
      
      updateLayoutPanel(panel, row, column, 2, 2)
      
    end
  end
  
  -- update active spells of this player
  if tempListOfSpells then
    updateTreeSpells(tempListOfSpells)
  end
end

function buildInformationInterface()
  local title = g_ui.createWidget('UILabel', treeSpellsPanel)
  title:breakAnchors()
  title:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
  title:addAnchor(AnchorTop, 'parent', AnchorTop)
  title:setMarginTop(4)
  title:setText('Tipos de magia')
  title:setColor('#ffff00FF')
  
  for i = 1, #spellTypes, 1 do
    local boxInformation = g_ui.createWidget('boxInformation', treeSpellsPanel)
    local panelInfoImage = boxInformation:getChildById('IDPanelInfoImage')
    panelInfoImage:setImageClip(spellTypes[i][1][1] .. ' ' .. spellTypes[i][1][2]
                                .. ' ' .. 16 .. ' ' .. 16)
    local labelInformation = boxInformation:getChildById('IDLabelInformation')
    local text = spellTypes[i][2]
    local numberOfRows = 1
    for j = 1, #text, 1 do    
      if j % math.floor(labelInformation:getSize().width/6.5) == 0 then
        numberOfRows = numberOfRows + 1
        local firsHalf = string.sub(text, 1, j)
        local secondHalf = string.sub(text, j + 1)
        if string.sub(secondHalf,1,1) == ' ' then
          secondHalf = string.sub(text, j + 2)
        end
        text = firsHalf .. '\n' .. secondHalf        
      end
    end    
    boxInformation:resize(boxInformation:getWidth() ,labelInformation:getTextSize().height * numberOfRows)
    labelInformation:resize(labelInformation:getWidth() ,labelInformation:getTextSize().height * numberOfRows)
    labelInformation:setText(text) 
    labelInformation:getTextAlign(AlignRight)    
    
    if i == 1 then
      boxInformation:setMarginTop(20)
    end
    
    local hSeparetor = g_ui.createWidget('HorizontalSeparator', treeSpellsPanel)
    hSeparetor:breakAnchors()
    hSeparetor:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    hSeparetor:addAnchor(AnchorRight, 'parent', AnchorRight)
    hSeparetor:addAnchor(AnchorTop, 'prev', AnchorBottom)
    hSeparetor:setMarginTop(5)
    
  end
end

function updateLayoutPanel(panel, row, column, marginTop, marginLeft)
  if column == 1 and row == 1 then 
    panel:removeAnchor(AnchorLeft)
    panel:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    panel:removeAnchor(AnchorTop)
    panel:addAnchor(AnchorTop, 'parent', AnchorTop)
  elseif column == 1 and row ~= 1 then
    panel:removeAnchor(AnchorLeft)
    panel:addAnchor(AnchorLeft, 'parent', AnchorLeft)
    panel:removeAnchor(AnchorTop)
    panel:addAnchor(AnchorTop, 'prev', AnchorBottom)
    panel:setMarginTop(marginTop)
  else
    panel:setMarginLeft(marginLeft)
  end
end

-- interface functions

function resetSize(w, h)
  treeSpellsWindow:resize(350 + w,440 + h)
  treeSpellsPanel:resize(245 + w,320 + h)
end

function changeInterfaceLayout(button)

  if currentIterface == 0 then
    currentIterface = currentIterface + 1
    local buttonType = button.type      
    treeSpellsPanel:destroyChildren()   
    buildSpellInterface(buttonType)
  end
end

function backInterface(button)
  if currentIterface > 0 then
    currentIterface = currentIterface - 1  
    treeSpellsPanel:destroyChildren()   
    resetSize(0,0)
    buildStartInterface(getStartModelInterface())
  end
end

function informationInterface(button) 
  currentIterface = 1
  treeSpellsPanel:destroyChildren()   
  resetSize(50, 0)
  buildInformationInterface()
end

--auxiliar function 
--grab information about spell inside spell_description table
function createSpellTooltip(spellId)
  local titleMsg = '  # ' .. spells[spellId][1] .. ' #  ' .. '\n'  
  for i = 1, #(spells[spellId][1]), 1 do
    titleMsg = titleMsg .. '*'
  end
  titleMsg = titleMsg .. '\n'
  
  local msg = spells_description[spellId][3]

  for j=1, #msg, 1 do  
    if math.mod(j, 40) == 0 then -- 200 pixels width
      local firstHalf = string.sub(msg, 1, j)
      local secondHalf = string.sub(msg, j + 1)
      if string.sub(secondHalf,1,1) == ' ' then
        secondHalf = string.sub(msg, j + 2)
      end
      if string.sub(firstHalf, j, -1) ~= ' ' and string.sub(secondHalf, 1, 1) ~= ' ' then
        firstHalf = string.sub(msg, 1, j) .. '-'
      end
      msg = firstHalf .. '\n' .. secondHalf
    end   
  end
  return titleMsg .. msg  
end

function createSpellLevelToolTip(spellId)
  local maxLevel = spells[spellId][2]
  local countPoints = spells_description[spellId][2]
  local msg = ''
  local tempCountPoints = countPoints
  for i =1 , maxLevel, 1 do
    tempCountPoints = countPoints - (i-1) * math.floor(countPoints/7);
    
    msg = msg .. 'Nível '.. i .. ' requer: ' .. 
      string.format("%02d",tempCountPoints) .. ' pontos'
    if i ~= maxLevel then
      msg = msg .. '\n'
    end
  end
  return msg
end

function onSpellsChange(localPlayer, spellsList)
  tempListOfSpells = spellsList
  --redraw the tree skills
  
  if treeSpellsPanel then
    updateTreeSpells(spellsList)    
  end
end

function onSpellChange(localPlayer, spellId, spellLevel)
  spellId = spellId
  if spellBoxTryed then
    local spellImagePanel = spellBoxTryed:getChildById('IDSpellImage')
    spellImagePanel:setImageColor('#ffffffff')
    spellImagePanel:setBorderColor('#abababff')
    if spellImagePanel:getSpellId() then
      
    else
    end
    spellImagePanel:addSpell() 
    spellImagePanel:setSpellId(spellId)
  
  
    local spellLabel = spellBoxTryed:getChildById('IDSpellLabel')
    spellLabel:setText(spellLevel + 1 .. '/' .. spells[spellId][2])    
  end
  spellBoxTryed = nil
end

function updateTreeSpells(list)
  local count = 1
  while list[count] do
    local spellImageBox = treeSpellsPanel:recursiveGetChildById('IDSpellBoxPanel ' 
          .. tostring(list[count][1]))
    if spellImageBox then
      local spellImagePanel = spellImageBox:getChildById('IDSpellImage')
      if spellImagePanel then
        spellImagePanel:setImageColor('#ffffffff')
        spellImagePanel:setBorderColor('#abababff')
        spellImagePanel:setBorderWidth(1)
        spellImagePanel:addSpell()
        spellImagePanel:setSpellId(list[count][1])
      end
      
      local spellImageLabel = spellImageBox:getChildById('IDSpellLabel')
      if spellImageLabel then       
          spellImageLabel:setText(tostring(list[count][2] + 1) .. '/' .. spells[list[count][1]][2])
      end
    end
    count = count + 1
  end  
end

function tryToUpSpellLevel()
  local spellBox = treeSpellsPanel:getChildByPos(g_window.getMousePosition())
  if spellBox then  
    spellBoxTryed = spellBox
    local spellImagePanel = spellBox:getChildById('IDSpellImage')
    if spellImagePanel and  spellImagePanel:getSpellId() then
      -- lua starts array with 1, so lets decrement 1 to c++ interpret correctly
      g_game.sendMsgTryToAddSpellLevel(spellImagePanel:getSpellId() - 1)
    end
  end
end

