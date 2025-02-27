skillsWindow = nil
skillsButton = nil
StaminaBar = nil
local maxSkillValue = 0

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

  skillsButton = modules.client_topmenu.addRightGameToggleButton('skillsButton', tr('Atributos') .. ' (Ctrl + A)', '/images/topbuttons/skills', toggle)
  skillsButton:setOn(true)
  skillsWindow = g_ui.loadUI('skills', modules.game_interface.getRootPanel())

  local topSetPanel = skillsWindow:getChildById('topSet')
  local circlePanel = topSetPanel:getChildById('circle')
  circlePanel:setIcon('/images/game/spells/physics')
  circlePanel:setIconSize({width = 57, height = 57})
  circlePanel:setIconOffset({x = 8, y = 9})
  circlePanel:setIconColor('#ffffff55')
  
  g_keyboard.bindKeyDown('Ctrl + A', toggle)

  
  local staminaPanel = modules.game_interface.getStaminaBarPanel()
  StaminaBar = g_ui.createWidget('StaminaBar',staminaPanel)
  StaminaBar:setValue(80,0,100)
  StaminaBar:setBackgroundColor('#ff0000ff')
  
  refresh()
  --skillsWindow:setup()

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
  
  --local contentsPanel = skillsWindow:getChildById('contentsPanel')
  --skillsWindow:setContentMinimumHeight(44)
 -- skillsWindow:setContentMaximumHeight(330)
end

function toggle()
  if skillsButton:isOn() then
    skillsWindow:hide()
    skillsButton:setOn(false)
  else
    skillsWindow:show()
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
  g_game.addSkillPoint(playerId, GameSkills[idLabel], 1)  
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

  --setSkillPercent('level', percent, text)
 -- if oldLevel < level then
  --  setSkillValue('levelPoints', level)
  --end
end


function onSpeedChange(localPlayer, speed)
  --setSkillValue('playerSpeed', speed)
end

function onSkillChange(localPlayer, id, skill, oldskill)
    setSkillValue(GameSkills[id + 1], skill)
    if skill > maxSkillValue then
      maxSkillValue = skill
    end
    
    drawBars()
end

function onLevelPointsChange(localPlayer, levelPoints)
  setSkillValue('levelPoints', levelPoints)
end

function drawBars()
  childPanel = skillsWindow:getChildById('skillChildPanel')
  childrenList = childPanel:recursiveGetChildren()  
  for i,v in ipairs(childrenList) do 
    local barPanel = v:getChildById('skillBar')
    
    if barPanel then
      local skillValue = v:getChildById('value')
      local value = tonumber(skillValue:getText())
      local skillName = v:getChildById('skillName')
      local textName = skillName:getText()
      local i,j = string.find(textName, " %(")       
      if i then
        textName = string.sub(textName,0 , i - 1)
      end
      if value then
        barPanel:setValue(value,0, maxSkillValue)
        skillName:setText(textName .. ' (' .. tostring(value) .. ')')
      end
    end
    --child:setBackgroundColor('#ff0000ff')
  end
end
