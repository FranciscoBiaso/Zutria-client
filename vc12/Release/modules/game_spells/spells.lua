spellPanel = nil

function init()
  connect(g_game, { onGameStart = loadSpells,
                    onGameEnd = unloadSpells })

  g_ui.loadUI('spells', modules.game_interface.getSpellPanel())                    
  spellPanel = modules.game_interface.getSpellPanel()
  spellPanel:show()

end

function terminate()
  disconnect(g_game, { onGameStart = loadSpells,
                       onGameEnd = unloadSpells })
  spellPanel:destroy()
end

function loadSpells()  

  for i=1,9,1 do  
    button = g_ui.createWidget('spellGroup', spellPanel)
    spellHotkeyText = button:recursiveGetChildById('spellHotkeyText')
    spellHotkeyText:setText(i)    
    if i ~= 1 then
      button:breakAnchors()
      button:addAnchor(AnchorLeft,'prev',AnchorRight)
      button:addAnchor(AnchorBottom,'parent',AnchorBottom)
    end
  end
  
end

function unloadSpells()
end