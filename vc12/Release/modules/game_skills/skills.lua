skillsWindow = nil
skillsButton = nil

function init()
  connect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
    onLevelChange = onLevelChange,    
    onSkillChange = onSkillChange,
    onLevelPointsChange = onLevelPointsChange,
  })
  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline,    
  })

  skillsButton = modules.client_topmenu.addRightGameToggleButton('skillsButton', tr('Atributos') .. ' (Ctrl+S)', '/images/topbuttons/skills', toggle)
  skillsButton:setOn(true)
  skillsWindow = g_ui.loadUI('skills', modules.game_interface.getRightPanel())

  g_keyboard.bindKeyDown('Ctrl+S', toggle)

  refresh()
  skillsWindow:setup()

end

function terminate()
  disconnect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
    onLevelChange = onLevelChange,
    onSkillChange = onSkillChange,
    onLevelPointsChange = onLevelPointsChange
  })
  
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline,  
  })

  g_keyboard.unbindKeyDown('Ctrl+S')
  skillsWindow:destroy()
  skillsButton:destroy()
end

function expForLevel(level)
  return math.floor((50*level*level*level)/3 - 100*level*level + (850*level)/3 - 200)
end

function expToAdvance(currentLevel, currentExp)
  return expForLevel(currentLevel+1) - currentExp
end

function resetSkillColor(id)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setColor('#bbbbbb')
end

function setSkillValue(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setText(value)
end

function setSkillColor(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setColor(value)
end

function setSkillTooltip(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setTooltip(value)
end

function setSkillPercent(id, percent, tooltip)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('percent')
  widget:setPercent(math.floor(percent))

  if tooltip then
    widget:setTooltip(tooltip)
  end
end

function checkAlert(id, value, maxValue, threshold, greaterThan)
  if greaterThan == nil then greaterThan = false end
  local alert = false

  -- maxValue can be set to false to check value and threshold
  -- used for regeneration checking
  if type(maxValue) == 'boolean' then
    if maxValue then
      return
    end

    if greaterThan then
      if value > threshold then
        alert = true
      end
    else
      if value < threshold then
        alert = true
      end
    end
  elseif type(maxValue) == 'number' then
    if maxValue < 0 then
      return
    end

    local percent = math.floor((value / maxValue) * 100)
    if greaterThan then
      if percent > threshold then
        alert = true
      end
    else
      if percent < threshold then
        alert = true
      end
    end
  end

  if alert then
    setSkillColor(id, '#b22222') -- red
  else
    resetSkillColor(id)
  end
end

function refresh()
  local player = g_game.getLocalPlayer()
  if not player then return end
  
  local contentsPanel = skillsWindow:getChildById('contentsPanel')
  skillsWindow:setContentMinimumHeight(44)
  skillsWindow:setContentMaximumHeight(300)
end

function toggle()
  if skillsButton:isOn() then
    skillsWindow:close()
    skillsButton:setOn(false)
  else
    skillsWindow:open()
    skillsButton:setOn(true)
  end
end

function onMiniWindowClose()
  skillsButton:setOn(false)
end

function onSkillButtonClick(button)
  local percentBar = button:getChildById('percent')
  if percentBar then
    percentBar:setVisible(not percentBar:isVisible())
    if percentBar:isVisible() then
      button:setHeight(23)
    else
      button:setHeight(23 - 6)
    end
  end
end

function onAddSkillButtonClick(button)
  local player = g_game.getLocalPlayer()
  if not player then return end 
  
  local widgetParent = button:getParent()
  local idLabel = widgetParent:getId()
  local playerId = player:getId()
  
  if idLabel == 'health' then
    g_game.addSkillPoint(playerId, GameSkills.Health, 1) 
  elseif idLabel == 'physicalAttack' then
    g_game.addSkillPoint(playerId, GameSkills.PhysicalAttack, 1) 
  elseif idLabel == 'physicalDefense' then
    g_game.addSkillPoint(playerId, GameSkills.PhysicalDefense, 1)
  elseif idLabel == 'capacity' then
    g_game.addSkillPoint(playerId, GameSkills.Capacity, 1)
  elseif idLabel == 'manaPoints' then
    g_game.addSkillPoint(playerId, GameSkills.ManaPoints, 1)
  elseif idLabel == 'magicAttack' then
    g_game.addSkillPoint(playerId, GameSkills.MagicAttack, 1)
  elseif idLabel == 'magicDefense' then
    g_game.addSkillPoint(playerId, GameSkills.MagicDefense, 1)
  elseif idLabel == 'magicPoints' then
    g_game.addSkillPoint(playerId, GameSkills.MagicPoints, 1)
  elseif idLabel == 'playerSpeed' then
    g_game.addSkillPoint(playerId, GameSkills.PlayerSpeed, 1)
  elseif idLabel == 'attackSpeed' then
    g_game.addSkillPoint(playerId, GameSkills.AttackSpeed, 1)
  elseif idLabel == 'cooldown' then
    g_game.addSkillPoint(playerId, GameSkills.Cooldown, 1)
  elseif idLabel == 'avoidance' then
    g_game.addSkillPoint(playerId, GameSkills.Avoidance, 1)
  end
end

function onExperienceChange(localPlayer, value)
  setSkillValue('experience', value)
end

function onLevelChange(localPlayer, level, percent, oldLevel)
  setSkillValue('level', level)
  local text = tr('You have %s percent to go', 100 - percent) .. '\n' ..
               tr('%s of experience left', expToAdvance(localPlayer:getLevel(), localPlayer:getExperience()))

  if localPlayer.expSpeed ~= nil then
     local expPerHour = math.floor(localPlayer.expSpeed * 3600)
     if expPerHour > 0 then
        local nextLevelExp = expForLevel(localPlayer:getLevel()+1)
        local hoursLeft = (nextLevelExp - localPlayer:getExperience()) / expPerHour
        local minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft))*60)
        hoursLeft = math.floor(hoursLeft)
        text = text .. '\n' .. tr('%d of experience per hour', expPerHour)
        text = text .. '\n' .. tr('Next level in %d hours and %d minutes', hoursLeft, minutesLeft)
     end
  end

  setSkillPercent('level', percent, text)
 -- if oldLevel < level then
  --  setSkillValue('levelPoints', level)
  --end
end


function onSpeedChange(localPlayer, speed)
  --setSkillValue('playerSpeed', speed)
end

function onSkillChange(localPlayer, id, skill, oldskill)
    setSkillValue(GameSkillsName[id + 1], skill)
end

function onLevelPointsChange(localPlayer, levelPoints)
  setSkillValue('levelPoints', levelPoints)
end
