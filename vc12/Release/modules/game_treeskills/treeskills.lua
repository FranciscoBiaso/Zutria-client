treeSkillsWindow = nil
treeSkillsButton = nil
treeSkillsTabBar = nil
treeSkillsPanel  = nil

function init()
  connect(LocalPlayer, {
    onSpellsChange = onSpellsChange,
    })

  connect(g_game, { onGameStart = online,
                    onGameEnd   = offline })
  treeSkillsWindow = g_ui.loadUI('treeskills', modules.game_interface.getRootPanel())
  --treeSkillsWindow:hide()
  
  treeSkillsButton = modules.client_topmenu.addRightGameToggleButton('treeSkillsButton', tr('árvore de habilidades'), '/images/topbuttons/hand', toggle)
  treeSkillsButton:setOn(true)
  
  
  treeSkillsTabBar = treeSkillsWindow:getChildById('treeSkillsTabBar')
  treeSkillsTabBar:addTab("específicas", nil, processChannelTabTreeSkills)
  treeSkillsTabBar:addTab("genéricas", nil, processChannelTabTreeSkills)
  
  treeSkillsPanel = treeSkillsWindow:getChildById('treeSkillsPanel') 
end

function terminate()
  disconnect(LocalPlayer, {
    onSpellsChange = onSpellsChange,
    })
    
  disconnect(g_game, { onGameStart = online,
                       onGameEnd   = offline })
  treeSkillsWindow = nil
  treeSkillsButton = nil
  treeSkillsTabBar = nil
  treeSkillsPanel  = nil
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

function findGridSpellByVocaiton(vocation)
  if vocation == tab_vocations.fire_mage then
    return tab_fire_spell_grid
  end   
  return tab_fire_spell_grid
end

function updateSpellPanel(spellPanel, spellPanelGridCell, localPlayer)
  if type(spellPanelGridCell) == "string" then
    spellImage = spellPanel:getChildById('spellImageId')    
    spellLabel = spellPanel:getChildById('spellLabel')   
    if string.find(spellPanelGridCell,"arrow",1) == nil then -- spell image 
      spellImage:setImageClip(tab_spells[spellPanelGridCell][3] .. ' ' .. tab_spells[spellPanelGridCell][4] .. ' ' .. 32 .. ' ' .. 32)
      -- the player has the spell
      if localPlayer:hasSpell(tab_spells[spellPanelGridCell][5]) then
        spellLabel:setText(localPlayer:getSpellLevel(tab_spells[spellPanelGridCell][5]) .. "/" .. tab_spells[spellPanelGridCell][1])
        spellImage:setImageColor('#ffffffff')
        spellImage:setBorderColor('#989898ff')
      else
        spellLabel:setText("0/" .. tab_spells[spellPanelGridCell][1])      
        spellImage:setImageColor('#565656ff')
      end
    else -- arrow image        
       spellPanel:removeChild(spellLabel)
       spellImage:breakAnchors()
       spellImage:addAnchor(AnchorHorizontalCenter,'parent',AnchorHorizontalCenter)
       spellImage:addAnchor(AnchorVerticalCenter,'parent',AnchorVerticalCenter)   
       spellImage:setBorderWidth(0)      
       spellImage:setImageClip(tab_arrows[spellPanelGridCell][1] .. ' ' .. tab_arrows[spellPanelGridCell][2] .. ' ' .. 32 .. ' ' .. 32)
    end
  else
    spellPanel:hide()
  end
end

function loadTreeSkills(vocation, localPlayer)
  local tab_spells_grid = findGridSpellByVocaiton(vocation)

  for i=1, #tab_spells_grid, 1 do
    for j=1, #tab_spells_grid[1], 1 do
      local spellPanel = g_ui.createWidget('SpellPanel',treeSkillsPanel)
      -- first element {1,1}
      if i == 1 and j == 1 then       
        spellPanel:addAnchor(AnchorLeft,'parent',AnchorLeft)
        spellPanel:addAnchor(AnchorTop,'parent',AnchorTop) 
        spellPanel:setMarginTop(2)        
      -- only first column {1,1},{2,1},{3,1} ...
      elseif j == 1 then      
        spellPanel:addAnchor(AnchorLeft,'parent',AnchorLeft)
        spellPanel:addAnchor(AnchorTop,'prev',AnchorBottom)   
        spellPanel:setMarginTop(2)  
      -- all other elements
      else
        spellPanel:addAnchor(AnchorLeft,'prev',AnchorRight)
        spellPanel:addAnchor(AnchorTop,'prev',AnchorTop)
      end
      updateSpellPanel(spellPanel,tab_spells_grid[i][j], localPlayer)
    end
  end
end

function onSpellsChange(localPlayer, spellsList)
  --redraw the tree skills
  loadTreeSkills(localPlayer:getVocation(), localPlayer)
end
