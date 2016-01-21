Spells = {}

spellWindow = nil
selectedSpell = nil
spells = {}

function init()
  connect(g_game, { onOpenSpellWindow = Spells.create,
                    onGameEnd = Spells.destroy })
	spellWindow = g_ui.displayUI('spells')
	spellWindow:show()
end

function terminate()
  disconnect(g_game, { onOpenSpellWindow = Spells.create,
                       onGameEnd = Spells.destroy })
  Spells.destroy()

  Spells = nil
end

function Spells.create(spellList)
  spells = spellList
  Spells.destroy()

  spellWindow = g_ui.displayUI('spells')
	spellWindow:show()
end

function Spells.destroy()
  if spellWindow then
    spellWindow:destroy()
    spellWindow = nil
    selectedSpell = nil
    spells = {}
  end
end

function Spells.selectSpell()
  if table.empty(spells) then
    return
  end
  -- TODO
end