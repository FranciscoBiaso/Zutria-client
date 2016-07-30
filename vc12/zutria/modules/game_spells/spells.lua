local spellPanel = nil
local numberOfSpells = nil
function init()
  connect(g_game, { onGameStart = loadSpells,
                    onGameEnd = unloadSpells })

  g_ui.loadUI('spells', modules.game_interface.getSpellPanel())                    
  
  spellPanel = modules.game_interface.getChildSpellPanel()
  --spellPanel:hide()
  spellPanel.onGeometryChange = spellPanelGeometryChange
  
  numberOfSpells = 0
 
  buildSpellPanels()
  
  loadSpells()
end

function terminate()
  disconnect(g_game, { onGameStart = loadSpells,
                       onGameEnd = unloadSpells })
  spellPanel:destroy()
end

function spellPanelGeometryChange (oldRect, newRect)
  destroyButtons()
  
  buildSpellPanels()
  
  loadSpells()
  
end

function destroyButtons()
  for i=1,numberOfSpells,1 do
    button = spellPanel:getChildById('spellGroup' .. i)
    if button then
      button:destroy()
    end
  end
end

function buildSpellPanels()
  -- 2 * 17 = margin spell panel + margin arrow button
  -- 4 = margin from arrow button
  local widthSpellInterface = spellPanel:getWidth() - 34 - 4
  -- 32 + 1 = 33 = spellBox width + margin
  -- +2 = last margin added
  numberOfSpells = math.floor((widthSpellInterface + 2)/33)  
   
  for i=1,numberOfSpells,1 do
    button = g_ui.createWidget('spellGroup', spellPanel)
    button:setId('spellGroup' .. i)
  end
end

function loadSpells()  
  for i=1,numberOfSpells,1 do
    button = spellPanel:getChildById('spellGroup' .. i)
    spellHotkeyText = button:recursiveGetChildById('spellHotkeyText')
    spellHotkeyText:setText(tostring(i))    
    if i ~= 1 then
      button:breakAnchors()
      button:addAnchor(AnchorLeft,'prev',AnchorRight)
      button:addAnchor(AnchorBottom,'parent',AnchorBottom)
      button:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
    end
    
    if i == 1 then
      -- margin of next button 12
      -- margin of border of spell panel 24
      -- margin arrow left
      button:setMarginLeft(16)
    end
    
    spellId = modules.game_hotkeys.getHotkeySpellId(tostring(i))
    if spellId then
      tab_spells = modules.game_treespells.getTableSpells()
      if tab_spells[spellId] then
        local spellIcon = button:getChildById('spellIcon')
        spellIcon:setImageSource('/images/game/spells/spells')
        spellIcon:setImageColor('#ffffffff')        
        spellIcon:setImageClip(tab_spells[spellId][3][1] .. ' ' .. tab_spells[spellId][3][2] .. ' ' .. 32 .. ' ' .. 32)     
        local spellHotkeyText = spellIcon:getChildById('spellHotkeyText')
        if spellHotkeyText then
          spellHotkeyText:hide()
        end
      end
    end
  end  
end
