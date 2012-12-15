local bump = require 'lib.bump'

local Being = require.relative(..., 'Being')

local Enemy = class('Enemy', Being)

function Enemy:initialize(x,y,speed, target)
  Being.initialize(self, x,y,24,24,speed)
  self.target = target
  self.tx, self.ty = x,y
end

function Enemy:draw()
  love.graphics.setColor(255,0,0)
  local cx,cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2)
end

function Enemy:updateTargetPositionIfVisible()
  local cx,cy = self:getCenter()
  local tx,ty = self.target:getCenter()
  local seen = false
  local result = bump.eachInSegment(cx,cy,tx,ty, function(item)
    if item == self then return end
    if item == self.target then
      seen = true
      return false
    end
    if item:isOpaque() then return false end
  end)
  if seen then self.tx, self.ty = tx,ty end
end

function Enemy:getDesiredMovementVector()
  self:updateTargetPositionIfVisible()
  local cx,cy = self:getCenter()
  return self.tx-cx, self.ty-cy
end

return Enemy
