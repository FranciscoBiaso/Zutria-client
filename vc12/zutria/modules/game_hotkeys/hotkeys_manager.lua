settings = nil
cooldownTimeBy100 = nil
cooldownBarReady = true
pushedCursor = false

function init()
  connect(g_game, { onGameStart = loadHotKeys})
  
  settings = g_settings.getNode('hotkeys') or {}    
end

function terminate()
  disconnect(g_game, { onGameStart = loadHotKeys})
  settings = nil
  cooldownTimeBy100 = nil
  cooldownBarReady = nil
end

function loadHotKeys()
  for i = 1, 9 do   
    local spellId = getHotkeySpellId(tostring(i))
    if spellId then
      g_keyboard.bindKeyPress(tostring(i), 
        function() 
          if cooldownBarReady then
            --cooldownBarReady = false
            doKeyCombo(spellId) 
            --displaySpellCooldown(tostring(i), spellId) 
          end
        end)      
    end    
  end
end

function displaySpellCooldown(hotkey, spellId)
  local spellGroup = modules.game_interface.getSpellPanel():getChildById('spellGroup' .. hotkey)
  local cooldownBar = spellGroup:getChildById('cooldownBar')
  local cooldownTime = modules.game_treeskills.getTableSpells()[spellId][6]  
  cooldownTimeBy100 = cooldownTime/100
  scheduleEvent(function() updateCoondownBar(cooldownBar, 0, cooldownTimeBy100) end, cooldownTimeBy100)
end

function updateCoondownBar(cooldownBar, percent, cooldownTimeBy100)
  if percent < 100 then
    percent = percent + 1
    cooldownBar:setBackgroundColor('#00ff00ff')
    cooldownBar:setPercent(percent)
    scheduleEvent(function() updateCoondownBar(cooldownBar, percent, cooldownTimeBy100) end, cooldownTimeBy100)
  else
    cooldownBar:setPercent(100)
    cooldownBar:setBackgroundColor('#989898ff')
    cooldownBarReady = true
  end
end

function doKeyCombo(spellId)
  if not g_game.isOnline() then return end
    -- is a spell instante or rune
    local descriptionSpellTable = modules.game_treespells.getTableDescriptionSpells()
    if descriptionSpellTable[spellId][1] == 2 or descriptionSpellTable[spellId][1] == 1 then
      g_game.sendSpell(spellId)
    
    -- is a spell actived by mouse
    elseif descriptionSpellTable[spellId][1] == 5 then 
      modules.game_interface.teste()
      -- if pushedCursor == false then
        -- g_mouse.pushCursor('spell')  
        -- pushedCursor = true
      -- end
    end
end

function saveHotkey(key, spellId)  
  if not g_game.isOnline() then return end
  
  local character = g_game.getCharacterName()
  if not settings[character] then
    settings[character] = {}
  end
  
  settings[character][key] = spellId
  
  g_keyboard.unbindKeyPress(key)  
  
  g_keyboard.bindKeyPress(key, 
      function() 
        --if cooldownBarReady then
          --cooldownBarReady = false
          doKeyCombo(spellId) 
          --displaySpellCooldown(key, spellId) 
        --end
      end)  
    
  g_settings.setNode('hotkeys', settings)
  g_settings.save()  
end

function getHotkeySpellId(hotkey)
  if not table.empty(settings) then
    local character = g_game.getCharacterName()
    if settings[character] then
      if settings[character][hotkey] then        
        return settings[character][hotkey]
      end      
    end
  end    
  return nil
end