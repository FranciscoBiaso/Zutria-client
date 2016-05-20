-- @docclass
UIVerticalProgressBar = extends(UIWidget, "UIVerticalProgressBar")

function UIVerticalProgressBar.create()
  local progressbar = UIVerticalProgressBar.internalCreate()
  progressbar:setFocusable(false)
  progressbar:setOn(true)
  progressbar.min = 0
  progressbar.max = 100
  progressbar.value = 0
  progressbar.bgBorderLeft = 0
  progressbar.bgBorderRight = 0
  progressbar.bgBorderTop = 0
  progressbar.bgBorderBottom = 0
  return progressbar
end

function UIVerticalProgressBar:setMinimum(minimum)
  self.minimum = minimum
  if self.value < minimum then
    self:setValue(minimum)
  end
end

function UIVerticalProgressBar:setMaximum(maximum)
  self.maximum = maximum
  if self.value > maximum then
    self:setValue(maximum)
  end
end

function UIVerticalProgressBar:setValue(value, minimum, maximum, color)
  if minimum then
    self:setMinimum(minimum)
  end

  if maximum then
    self:setMaximum(maximum)
  end

 self.value = math.max(math.min(value, self.maximum), self.minimum)
  
  if color then
    self:setBackgroundColor(color)
  end
  self:updateBackground()
end

function UIVerticalProgressBar:setPercent(percent)
  self:setValue(percent, 0, 100)
end

function UIVerticalProgressBar:getPercent()
  return self.value
end

function UIVerticalProgressBar:getPercentPixels()
  return (self.maximum - self.minimum) / self:getHeight()
end

function UIVerticalProgressBar:getProgress()
  if self.minimum == self.maximum then return 1 end 
  return (self.value - self.minimum) / (self.maximum - self.minimum)
end

function UIVerticalProgressBar:updateBackground()
  if self:isOn() then
    local width = self:getWidth() - self.bgBorderRight - self.bgBorderLeft      
    local rect = { x = self.bgBorderLeft, y = self:getHeight() * ( 1 - self:getProgress()), width = width, 
        height = math.max(self:getHeight() - self:getHeight() * ( 1 - self:getProgress()),1)}
    self:setBackgroundRect(rect)
  end
end

function UIVerticalProgressBar:onSetup()
  self:updateBackground()
end

function UIVerticalProgressBar:onStyleApply(name, node)
  for name,value in pairs(node) do
    if name == 'background-border-left' then
      self.bgBorderLeft = tonumber(value)
    elseif name == 'background-border-right' then
      self.bgBorderRight = tonumber(value)
    elseif name == 'background-border-top' then
      self.bgBorderTop = tonumber(value)
    elseif name == 'background-border-bottom' then
      self.bgBorderBottom = tonumber(value)
    elseif name == 'background-border' then
      self.bgBorderLeft = tonumber(value)
      self.bgBorderRight = tonumber(value)
      self.bgBorderTop = tonumber(value)
      self.bgBorderBottom = tonumber(value)
    end
  end
end

function UIVerticalProgressBar:onGeometryChange(oldRect, newRect)
  if not self:isOn() then
    self:setWidth(0)
  end
  self:updateBackground()
end
