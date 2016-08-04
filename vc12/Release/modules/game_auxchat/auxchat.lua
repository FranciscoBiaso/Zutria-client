local mainPanel = nil
local textEdit = nil

function init()
  -- connect(g_game, { onGameStart = loadSpells,
                    -- onGameEnd = unloadSpells })

  mainPanel = g_ui.loadUI('auxchat', modules.game_interface.getRootPanel())
  local topSetPanel = mainPanel:getChildById('topSet')
  local circlePanel = topSetPanel:getChildById('circle')
  circlePanel:setIcon('/images/game/auxchat/friend')
  circlePanel:setIconColor('#ffffff66')
  --mainPanel:hide()
 -- mainPanel:focus()
  
  
  textEdit = mainPanel:getChildById('auxchatTextEdit')
  textEdit.onKeyDown = onKeyDown
end

function terminate()

  mainPanel:destroy()
end

-- on key text --> find players
function onKeyDown(UITextEdit, key, modifiers)
  mainPanel:setText(KeyCodeDescs[key])
end

