spellPanel = nil

function init()
  connect(g_game, { onGameStart = loadSpells,
                    onGameEnd = unloadSpells })

  g_ui.loadUI('spells', modules.game_interface.getSpellPanel())                    
  
  spellPanel = modules.game_interface.getSpellPanel()
  spellPanel:show()
  
  buildSpellPanels()
end

function terminate()
  disconnect(g_game, { onGameStart = loadSpells,
                       onGameEnd = unloadSpells })
  spellPanel:destroy()
end

function buildSpellPanels()
  for i=1,9,1 do
    button = g_ui.createWidget('spellGroup', spellPanel)
    button:setId('spellGroup' .. i)
  end
end

function loadSpells()  
  for i=1,9,1 do
    button = spellPanel:getChildById('spellGroup' .. i)
    spellHotkeyText = button:recursiveGetChildById('spellHotkeyText')
    spellHotkeyText:setText(tostring(i))    
    if i ~= 1 then
      button:breakAnchors()
      button:addAnchor(AnchorLeft,'prev',AnchorRight)
      button:addAnchor(AnchorBottom,'parent',AnchorBottom)
    end
    spellId = modules.game_hotkeys.getHotkeySpellId(tostring(i))
    if spellId then
      tab_spells = modules.game_treeskills.getTableSpells()
      if tab_spells[spellId] then
        spellIcon = button:getChildById('spellIcon')
        spellIcon:setImageSource('/images/game/spells/spells')
        spellIcon:setImageColor('#ffffffff')        
        spellIcon:setImageClip(tab_spells[spellId][3][1] .. ' ' .. tab_spells[spellId][3][2] .. ' ' .. 32 .. ' ' .. 32)                       
      end
    end
  end  
end

function unloadSpells()
end