-- @docclass
g_tooltip = {}

-- private variables
local toolTipLabel
local currentHoveredWidget

-- private functions
local function moveToolTip(first)
  if not first and (not toolTipLabel:isVisible() or toolTipLabel:getOpacity() < 0.1) then return end

  local pos = g_window.getMousePosition()
  pos.y = pos.y + 1
  local xdif = g_window.getSize().width - (pos.x + toolTipLabel:getWidth())
  if xdif < 10 then
    pos.x = pos.x - toolTipLabel:getWidth() - 3
  else
    pos.x = pos.x + 20
  end
  toolTipLabel:setPosition(pos)
end

local function onWidgetHoverChange(widget, hovered)
  if hovered then
    if widget.tooltip and not g_mouse.isPressed() then
      g_tooltip.display(widget.tooltip)
      currentHoveredWidget = widget
    end
  else
    if widget == currentHoveredWidget then
      g_tooltip.hide()
      currentHoveredWidget = nil
    end
  end
end

local function onWidgetStyleApply(widget, styleName, styleNode)
  if styleNode.tooltip then
    widget.tooltip = styleNode.tooltip
  end
end

-- public functions
function g_tooltip.init()
  connect(UIWidget, {  onStyleApply = onWidgetStyleApply,
                       onHoverChange = onWidgetHoverChange})

  addEvent(function()
    toolTipLabel = g_ui.createWidget('UILabel', rootWidget)
    toolTipLabel:setId('toolTip')
    toolTipLabel:setBorderColor('#757575')
    toolTipLabel:setBorderWidth(1)
    toolTipLabel:setBackgroundColor('#111111cc')
    toolTipLabel:setTextAlign(AlignCenter)
    toolTipLabel:hide()
    toolTipLabel.onMouseMove = function() moveToolTip() end
  end)
end

function g_tooltip.terminate()
  disconnect(UIWidget, { onStyleApply = onWidgetStyleApply,
                         onHoverChange = onWidgetHoverChange })

  currentHoveredWidget = nil
  toolTipLabel:destroy()
  toolTipLabel = nil

  g_tooltip = nil
end

function g_tooltip.display(text)
  if text == nil or text:len() == 0 then return end
  if not toolTipLabel then return end

  toolTipLabel:setText(text)
  toolTipLabel:resizeToText()
  toolTipLabel:resize(toolTipLabel:getWidth() + 4, toolTipLabel:getHeight() + 4)
  toolTipLabel:show()
  toolTipLabel:raise()
  toolTipLabel:enable()
  g_effects.fadeIn(toolTipLabel, 300)
  moveToolTip(true)
end

function g_tooltip.hide()
  g_effects.fadeOut(toolTipLabel, 300)
end


-- @docclass UIWidget @{

-- UIWidget extensions
function UIWidget:setTooltip(text)
  self.tooltip = text
end

function UIWidget:removeTooltip()
  self.tooltip = nil
end

function UIWidget:getTooltip()
  return self.tooltip
end


-- @}

g_tooltip.init()
connect(g_app, { onTerminate = g_tooltip.terminate })
