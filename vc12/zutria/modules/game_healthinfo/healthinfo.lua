Icons = {}
Icons[PlayerStates.Poison] = { tooltip = tr('You are poisoned'), path = '/images/game/states/poisoned', id = 'condition_poisoned' }
Icons[PlayerStates.Burn] = { tooltip = tr('You are burning'), path = '/images/game/states/burning', id = 'condition_burning' }
Icons[PlayerStates.Energy] = { tooltip = tr('You are electrified'), path = '/images/game/states/electrified', id = 'condition_electrified' }
Icons[PlayerStates.Drunk] = { tooltip = tr('You are drunk'), path = '/images/game/states/drunk', id = 'condition_drunk' }
Icons[PlayerStates.ManaShield] = { tooltip = tr('You are protected by a magic shield'), path = '/images/game/states/magic_shield', id = 'condition_magic_shield' }
Icons[PlayerStates.Paralyze] = { tooltip = tr('You are paralysed'), path = '/images/game/states/slowed', id = 'condition_slowed' }
Icons[PlayerStates.Haste] = { tooltip = tr('You are hasted'), path = '/images/game/states/haste', id = 'condition_haste' }
Icons[PlayerStates.Swords] = { tooltip = tr('You cannot log during combat'), path = '/images/game/states/logout_block', id = 'condition_logout_block' }
Icons[PlayerStates.Drowning] = { tooltip = tr('You are drowning'), path = '/images/game/states/drowning', id = 'condition_drowning' }
Icons[PlayerStates.Freezing] = { tooltip = tr('You are freezing'), path = '/images/game/states/freezing', id = 'condition_freezing' }
Icons[PlayerStates.Dazzled] = { tooltip = tr('You are dazzled'), path = '/images/game/states/dazzled', id = 'condition_dazzled' }
Icons[PlayerStates.Cursed] = { tooltip = tr('You are cursed'), path = '/images/game/states/cursed', id = 'condition_cursed' }
Icons[PlayerStates.PartyBuff] = { tooltip = tr('You are strengthened'), path = '/images/game/states/strengthened', id = 'condition_strengthened' }
Icons[PlayerStates.PzBlock] = { tooltip = tr('You may not logout or enter a protection zone'), path = '/images/game/states/protection_zone_block', id = 'condition_protection_zone_block' }
Icons[PlayerStates.Pz] = { tooltip = tr('You are within a protection zone'), path = '/images/game/states/protection_zone', id = 'condition_protection_zone' }
Icons[PlayerStates.Bleeding] = { tooltip = tr('You are bleeding'), path = '/images/game/states/bleeding', id = 'condition_bleeding' }
Icons[PlayerStates.Hungry] = { tooltip = tr('You are hungry'), path = '/images/game/states/hungry', id = 'condition_hungry' }

local healthInfoInterface = nil
local healthBar = nil
local manaBar = nil
local experienceBar = nil
local experienceBarPanel = nil

local healthLabelPanel = nil
local manaLabelPanel = nil

local healthTooltip = 'Pontos de vida = %d.'
local manaTooltip = 'Pontos de mana = %d.'
local experienceTooltip = 'You have %d%% to advance to level %d.'

function init()
   connect(LocalPlayer, { onHealthChange = onHealthChange,
                          onManaChange = onManaChange,
                          onLevelChange = onLevelChange,
                          onStatesChange = onStatesChange,                          
                         })
  
  healthInfoInterface = g_ui.loadUI('healthinfo', modules.game_interface.getRightPanel())
  
  -- local barsPanel = modules.game_interface.getBarsPanel()
  local healthBarPanel = modules.game_interface.getHealthBarPanel()
  healthBar = g_ui.createWidget('HealthBar',healthBarPanel)
  local manaBarPanel = modules.game_interface.getManaBarPanel()
  manaBar = g_ui.createWidget('ManaBar',manaBarPanel)
  local experienceBarPanel = modules.game_interface.getExperiencePanel()
  experienceBar = g_ui.createWidget('ExperienceBar',experienceBarPanel)

   -- load condition icons
   for k,v in pairs(Icons) do
    g_textures.preload(v.path)
   end

  if g_game.isOnline() then
     local localPlayer = g_game.getLocalPlayer()
     onHealthChange(localPlayer, localPlayer:getHealth(), localPlayer:getMaxHealth())
     onManaChange(localPlayer, localPlayer:getMana(), localPlayer:getMaxMana())
     onLevelChange(localPlayer, localPlayer:getLevel(), localPlayer:getLevelPercent())
     onStatesChange(localPlayer, localPlayer:getStates(), 0)
   end

   
   healthLabelPanel = modules.game_interface.getHealthLabelPanel()
   manaLabelPanel = modules.game_interface.getManaLabelPanel()

end

function terminate()
  disconnect(LocalPlayer, {   onHealthChange = onHealthChange,
                              onManaChange = onManaChange,                              
                              onLevelChange = onLevelChange,
                              onStatesChange = onStatesChange,                              
                             })

  healthBar:destroy()
  manaBar:destroy()
  experienceBar:destroy()
  experienceBarPanel = nil
  healthLabelPanel:destroyChildren()
  manaLabelPanel:destroyChildren()
  healthInfoInterface = nil
end

function toggleIcon(bitChanged)
  local content = modules.game_interface.getConditionPanel()

  local icon = content:getChildById(Icons[bitChanged].id)
  if icon then
    icon:destroy()
  else
    icon = loadIcon(bitChanged)
    icon:setParent(content)
  end
end

function loadIcon(bitChanged)
  local icon = g_ui.createWidget('ConditionWidget', content)
  icon:setId(Icons[bitChanged].id)
  icon:setImageSource(Icons[bitChanged].path)
  icon:setTooltip(Icons[bitChanged].tooltip)
  return icon
end

-- hooked events
function onMiniWindowClose()
  healthInfoButton:setOn(false)
end

function onHealthChange(localPlayer, health, maxHealth)
  healthBar:setTooltip(tr(healthTooltip, health, maxHealth))
  
  local percentage = health / maxHealth
  percentage = percentage * 100
 -- local color = '#'
 -- if percentage >= 50 then
		-- local redColor = 255.0 * (50-(percentage-50))/50.0
    -- redColor = DEC_HEX(redColor)
    -- color = color .. tostring(redColor) .. 'ff00'
	-- else
    -- local yellowColor = 255.0 * percentage / 50.0
    -- yellowColor = DEC_HEX(yellowColor)
    -- color = color .. 'ff' .. tostring(yellowColor) .. '00'
  -- end
  
  healthBar:setValue(health, 0, maxHealth)
  
  healthLabelPanel:setText(health .. '/' .. maxHealth)
end


function onManaChange(localPlayer, mana, maxMana)
  manaBar:setTooltip(tr(manaTooltip, mana, maxMana))
  manaBar:setValue(mana, 0, maxMana)
  
  manaLabelPanel:setText(mana .. '/' .. maxMana)  
end

function onLevelChange(localPlayer, value, percent)
  --experienceBar:setText(percent .. '%')
  experienceBar:setTooltip(tr(experienceTooltip, percent, value+1))
  experienceBar:setPercent(percent)
end

function onStatesChange(localPlayer, now, old)
  if now == old then return end

  local bitsChanged = bit32.bxor(now, old)
  for i = 1, 32 do
    local pow = math.pow(2, i-1)
    if pow > bitsChanged then break end
    local bitChanged = bit32.band(bitsChanged, pow)
    if bitChanged ~= 0 then
      toggleIcon(bitChanged)
    end
  end
end

function setHealthTooltip(tooltip)
  healthTooltip = tooltip

  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    healthBar:setTooltip(tr(healthTooltip, localPlayer:getHealth(), localPlayer:getMaxHealth()))
  end
end

function setManaTooltip(tooltip)
  manaTooltip = tooltip

  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    manaBar:setTooltip(tr(manaTooltip, localPlayer:getMana(), localPlayer:getMaxMana()))
  end
end

function setExperienceTooltip(tooltip)
  experienceTooltip = tooltip

  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    experienceBar:setTooltip(tr(experienceTooltip, localPlayer:getLevelPercent(), localPlayer:getLevel()+1))
  end
end
