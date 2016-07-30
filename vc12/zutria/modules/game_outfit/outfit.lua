ADDON_SETS = {
  [1] = { 1 },
  [2] = { 2 },
  [3] = { 1, 2 },
  [4] = { 3 },
  [5] = { 1, 3 },
  [6] = { 2, 3 },
  [7] = { 1, 2, 3 }
}

outfitWindow = nil
outfit = nil
outfits = nil
outfitCreature = nil
currentOutfit = 1
local outfitCreatureBox

addons = nil
currentColorBox = nil
currentClotheButtonBox = nil
colorBoxes = {}

function init()
  connect(g_game, {
    onOpenOutfitWindow = create,
    onGameEnd = destroy
  })
end

function terminate()
  disconnect(g_game, {
    onOpenOutfitWindow = create,
    onGameEnd = destroy
  })
  destroy()
end


function create(creatureOutfit, outfitList, creatureMount, mountList)
  if outfitWindow and not outfitWindow:isHidden() then
    return
  end

  outfitCreature = creatureOutfit
  outfits = outfitList
  destroy()

  outfitWindow = g_ui.displayUI('outfitwindow')
  local colorBoxPanel = outfitWindow:recursiveGetChildById('colorBoxPanel')

  -- setup outfit/mount display boxs
  outfitCreatureBox = outfitWindow:getChildById('outfitCreatureBox')
  if outfitCreature then
    outfit = outfitCreature:getOutfit()
    outfitCreatureBox:setCreature(outfitCreature)
  else
    outfitCreatureBox:hide()
    outfitWindow:getChildById('outfitName'):hide()
    outfitWindow:getChildById('outfitNextButton'):hide()
    outfitWindow:getChildById('outfitPrevButton'):hide()
  end

  -- set addons
  addons = {
    [1] = {widget = outfitWindow:getChildById('addon1'), value = 1},
    [2] = {widget = outfitWindow:getChildById('addon2'), value = 2},
    [3] = {widget = outfitWindow:getChildById('addon3'), value = 4}
  }

  for _, addon in pairs(addons) do
    addon.widget.onCheckChange = function(self) onAddonCheckChange(self, addon.value) end
  end

  if outfit.addons and outfit.addons > 0 then
    for _, i in pairs(ADDON_SETS[outfit.addons]) do
      addons[i].widget:setChecked(true)
    end
  end

  -- hook outfit sections
  currentClotheButtonBox = outfitWindow:getChildById('head')
  outfitWindow:getChildById('head').onCheckChange = onClotheCheckChange
  outfitWindow:getChildById('primary').onCheckChange = onClotheCheckChange
  outfitWindow:getChildById('secondary').onCheckChange = onClotheCheckChange
  outfitWindow:getChildById('detail').onCheckChange = onClotheCheckChange

  -- populate color panel
  local lines = 9
  local col = 13
  for j=0,col - 1 do
    for i=0,lines - 1 do
      local colorBox = g_ui.createWidget('ColorBox', colorBoxPanel)
      local outfitColor = getOufitColor(j*lines + i)
      colorBox:setImageColor(outfitColor)
      colorBox:setId('colorBox' .. j*lines+i)
      colorBox.colorId = j*lines + i

      if j*lines + i == outfit.head then
        currentColorBox = colorBox
        colorBox:setChecked(true)
      end
      colorBox.onCheckChange = onColorCheckChange
      colorBoxes[#colorBoxes+1] = colorBox
    end
  end

  updateOutfit()
end

function destroy()
  if outfitWindow then
    outfitWindow:destroy()
    outfitWindow = nil
    outfitCreature = nil
    currentColorBox = nil
    currentClotheButtonBox = nil
    colorBoxes = {}
    addons = {}
  end
end

function randomize()
  local outfitTemplate = {
    outfitWindow:getChildById('head'),
    outfitWindow:getChildById('primary'),
    outfitWindow:getChildById('secondary'),
    outfitWindow:getChildById('detail')
  }

  for i = 1, #outfitTemplate do
    outfitTemplate[i]:setChecked(true)
    colorBoxes[math.random(1, #colorBoxes)]:setChecked(true)
    outfitTemplate[i]:setChecked(false)
  end
  outfitTemplate[1]:setChecked(true)
end

function accept()
  g_game.changeOutfit(outfit)
  destroy()
end

function nextOutfitType()
  if not outfits then
    return
  end
  currentOutfit = currentOutfit + 1
  if currentOutfit > #outfits then
    currentOutfit = 1
  end
  updateOutfit()
end

function previousOutfitType()
  if not outfits then
    return
  end
  currentOutfit = currentOutfit - 1
  if currentOutfit <= 0 then
    currentOutfit = #outfits
  end
  updateOutfit()
end

function onAddonCheckChange(addon, value)
  if addon:isChecked() then
    outfit.addons = outfit.addons + value
  else
    outfit.addons = outfit.addons - value
  end
  outfitCreature:setOutfit(outfit)
end

function onColorCheckChange(colorBox)
  if colorBox == currentColorBox then
    colorBox.onCheckChange = nil
    colorBox:setChecked(true)
    colorBox.onCheckChange = onColorCheckChange
  else
    currentColorBox.onCheckChange = nil
    currentColorBox:setChecked(false)
    currentColorBox.onCheckChange = onColorCheckChange

    currentColorBox = colorBox

    if currentClotheButtonBox:getId() == 'head' then
      outfit.head = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == 'primary' then
      outfit.body = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == 'secondary' then
      outfit.legs = currentColorBox.colorId
    elseif currentClotheButtonBox:getId() == 'detail' then
      outfit.feet = currentColorBox.colorId
    end

    outfitCreature:setOutfit(outfit)
    --outfitCreatureBox:setCreature(outfit)
  end
end

function onClotheCheckChange(clotheButtonBox)
  if clotheButtonBox == currentClotheButtonBox then
    clotheButtonBox.onCheckChange = nil
    clotheButtonBox:setChecked(true)
    clotheButtonBox.onCheckChange = onClotheCheckChange
  else
    currentClotheButtonBox.onCheckChange = nil
    currentClotheButtonBox:setChecked(false)
    currentClotheButtonBox.onCheckChange = onClotheCheckChange

    currentClotheButtonBox = clotheButtonBox

    local colorId = 0
    if currentClotheButtonBox:getId() == 'head' then
      colorId = outfit.head
    elseif currentClotheButtonBox:getId() == 'primary' then
      colorId = outfit.body
    elseif currentClotheButtonBox:getId() == 'secondary' then
      colorId = outfit.legs
    elseif currentClotheButtonBox:getId() == 'detail' then
      colorId = outfit.feet
    end
    outfitWindow:recursiveGetChildById('colorBox' .. colorId):setChecked(true)
  end
end

function updateOutfit()
  if table.empty(outfits) or not outfit then
    return
  end
  local nameWidget = outfitWindow:getChildById('outfitName')
  --nameWidget:setText(outfits[currentOutfit][2])

  local availableAddons = outfits[currentOutfit].second

  local prevAddons = {}
  for k, addon in pairs(addons) do
    prevAddons[k] = addon.widget:isChecked()
    addon.widget:setChecked(false)
    addon.widget:setEnabled(false)
  end
  outfit.addons = 0

  if availableAddons > 0 then
    for _, i in pairs(ADDON_SETS[availableAddons]) do
      addons[i].widget:setEnabled(true)
      addons[i].widget:setChecked(true)
    end
  end

  outfit.type = outfits[currentOutfit].first
  outfitCreature:setOutfit(outfit)
end

