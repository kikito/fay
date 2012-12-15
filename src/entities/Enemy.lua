local bump = require 'lib.bump'

local Being = require.relative(..., 'Being')

local Enemy = class('Enemy', Being)

function Enemy:initialize(x,y,speed, target)
  Being.initialize(self, x,y,24,24,speed)
  self.target = target
end

function Enemy:draw()
  love.graphics.setColor(255,0,0)
  local cx,cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2)
end

function Enemy:seesTarget()
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
  if seen then return tx-cx,ty-cy end
end

function Enemy:getDesiredMovementVector()
  local dx,dy = self:seesTarget()
  return dx or 0, dy or 0
end

return Enemy
