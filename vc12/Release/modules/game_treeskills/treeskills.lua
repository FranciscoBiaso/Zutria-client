treeSkillsWindow = nil
treeSkillsButton = nil
treeSkillsPanel  = nil
groupSpellPanelTryed  = nil

function init()
  connect(LocalPlayer, {
    onSpellsChange = onSpellsChange,
    onSpellChange = onSpellChange,
    })
    
  treeSkillsWindow = g_ui.loadUI('treeskills', modules.game_interface.getRootPanel())
  --treeSkillsWindow:hide()
  
  treeSkillsButton = modules.client_topmenu.addRightGameToggleButton('treeSkillsButton', tr('árvore de habilidades'), '/images/topbuttons/hand', toggle)
  treeSkillsButton:setOn(true)  
  
  treeSkillsPanel = treeSkillsWindow:getChildById('treeSkillsPanel')   
  
  buildTreeSkills(tab_spells_model)
end

function terminate()
  disconnect(LocalPlayer, {
    onSpellsChange = onSpellsChange,
    onSpellChange = onSpellChange,
    })
  
  treeSkillsButton:destroy()  
  treeSkillsButton = nil
  treeSkillsWindow:destroy() 
  treeSkillsWindow = nil
  groupSpellPanelTryed  = nil
end

function toggle()
  if treeSkillsButton:isOn() then
    treeSkillsButton:setOn(false)
    treeSkillsWindow:hide()
  else
    treeSkillsButton:setOn(true)
    treeSkillsWindow:show()
    treeSkillsWindow:raise()
    treeSkillsWindow:focus()
  end
end

function updateSpellPanel(spellPanel, model)
  if type(model) == "string" then
    spellImage = spellPanel:getChildById('spellImageId')    
    spellImage:setButtonSpellName(model)
    spellLabel = spellPanel:getChildById('spellLabel') 
    spellImage:setButtonSpellName(model)
    if string.find(model,"arrow",1) == nil then -- spell image 
      spellImage:setImageClip(tab_spells[model][3] .. ' ' .. tab_spells[model][4] .. ' ' .. 32 .. ' ' .. 32)
      spellImage:setDraggingImageClip(tab_spells[model][3],tab_spells[model][4])                  
      -- the player has the spell
      if g_game.getLocalPlayer():hasSpell(tab_spells[model][5]) then
        spellLabel:setText(g_game.getLocalPlayer():getSpellLevel(tab_spells[model][5]) .. "/" .. tab_spells[model][1])
        spellImage:setImageColor('#ffffffff')
        spellImage:setBorderColor('#989898ff')
      else
        spellLabel:setText("0/" .. tab_spells[model][1])      
        spellImage:setImageColor('#565656ff')
      end      
    else -- arrow image      
       addSkillButton = spellPanel:getChildById('skillAddButton')     
       addSkillButton:destroy()
       addSkillButton = nil
       spellLabel:destroy()
       spellLabel = nil
       spellImage:breakAnchors()
       spellImage:addAnchor(AnchorHorizontalCenter,'parent',AnchorHorizontalCenter)
       spellImage:addAnchor(AnchorVerticalCenter,'parent',AnchorVerticalCenter)   
       spellImage:setBorderWidth(0)      
       spellImage:setImageClip(tab_arrows[model][1] .. ' ' .. tab_arrows[model][2] .. ' ' .. 32 .. ' ' .. 32)
       --spellPanel:destroy()
    end
  else
    spellPanel:hide()
  end
end

function createSkillPanel(panelModel)
   if panelModel[1] == 0 then -- HiddenPanel
      return g_ui.createWidget('HiddenPanel', treeSkillsPanel)
   elseif panelModel[1] == 1 then -- ArrowPanel
      return g_ui.createWidget('ArrowPanel', treeSkillsPanel)
   else -- SpellPanel
      panelView = g_ui.createWidget('SpellPanel', treeSkillsPanel)
      skillImage = panelView:getChildById('skillImage')
      skillImage:setSpellId(panelModel[2])      
      return panelView
   end
end

function updatePositionOfTabSpellsInfo(cell, i, j)
  if cell[1] == 2 then -- is a skill 
    tab_spells_information[cell[2]][5][1] = i
    tab_spells_information[cell[2]][5][2] = j
  end
end

function clipPanelViewImage(panelView, panelModel)
  if panelModel[1] == 1 then -- is a arrow
    local arrowImage = panelView:getChildById('arrowImage')
    arrowImage:setImageClip(tab_arrows[panelModel[2]][1] .. ' ' .. tab_arrows[panelModel[2]][2] 
      .. ' ' .. 32 .. ' ' .. 32)
  elseif panelModel[1] == 2 then -- is a skill
    local skillImage = panelView:getChildById('skillImage')
    skillImage:setImageClip(tab_spells_information[panelModel[2]][3][1] .. ' ' .. 
      tab_spells_information[panelModel[2]][3][2]
      .. ' ' .. 32 .. ' ' .. 32)   
    skillImage:setImageClipOfTempButton(tab_spells_information[panelModel[2]][3][1],
      tab_spells_information[panelModel[2]][3][2])
  end
end

function updatePanelLayout(panel, i, j)
  -- first element {1,1}
  if i == 1 and j == 1 then       
    panel:addAnchor(AnchorLeft,'parent',AnchorLeft)
    panel:addAnchor(AnchorTop,'parent',AnchorTop) 
    panel:setMarginTop(2)        
  -- only first column {1,1},{2,1},{3,1} ...
  elseif j == 1 then      
    panel:addAnchor(AnchorLeft,'parent',AnchorLeft)
    panel:addAnchor(AnchorTop,'prev',AnchorBottom)   
    panel:setMarginTop(2)  
  -- all other elements
  else
    panel:addAnchor(AnchorLeft,'prev',AnchorRight)
    panel:addAnchor(AnchorTop,'prev',AnchorTop)
  end 
end

function buildTreeSkills(table)
  for i=1, #table, 1 do
    for j=1, #table[1], 1 do
      local panelModel = table[i][j]
      updatePositionOfTabSpellsInfo(panelModel, i, j)      
      local panelView = createSkillPanel(panelModel)
      panelView:setId('skillPanel' .. i .. j)
      clipPanelViewImage(panelView, panelModel)
      updatePanelLayout(panelView, i, j)
    end
  end
end

function updateViewPanel(viewPanel, spellId)
  skillImage = viewPanel:getChildById('skillImage')
  skillImage:setImageColor('#ffffffff')
  skillImage:setBorderColor('#989898ff')
  skillImage:setEnabled(true)  
  skillImage:AddSpell() 
end

function updateTreeSkills(model)
  local count = 1
  while model[count] do
    local indexI, indexj = tab_spells_information[model[count][1]][5][1], tab_spells_information[model[count][1]][5][2]
    local skillViewPanel = treeSkillsPanel:getChildById('skillPanel' .. indexI .. indexj)
    updateViewPanel(skillViewPanel, model[count][1])
    count = count + 1
  end  
end

function onSpellsChange(localPlayer, spellsList)
  --redraw the tree skills
  updateTreeSkills(spellsList)
end

function onSpellChange(localPlayer, spellId, spellLevel)
  if groupSpellPanelTryed then
    updateViewPanel(groupSpellPanelTryed, spellId)          
  end
end

function tryToUpSpellLevel()
  local groupSpellPanel = treeSkillsPanel:getChildByPos(g_window.getMousePosition())
  if groupSpellPanel then
    local spellImage = groupSpellPanel:getChildById('skillImage') 
    --spellLabel = groupSpellPanel:getChildById('spellLabel') 
    groupSpellPanelTryed = groupSpellPanel
    if spellImage then
      -- lua starts array with 1, so lets decrement 1 to c++ interpret correctly
      g_game.sendMsgTryToAddSpellLevel(spellImage:getSpellId() - 1)
    end
  end
end
