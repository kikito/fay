local cron = require 'lib.cron'

local AI   = require.relative(..., 'AI')
local Blow = require.relative(..., 'Blow')

local Knight = class('Knight', AI)

function Knight:initialize(x,y, primaryTarget)
  AI.initialize(self, x,y, 60)
  self.primaryTarget = primaryTarget -- this never changes (usually, the player)
  self.target = primaryTarget
  self:gotoState('Idle')
end

function Knight:getColor() return 255,255,255 end

function Knight:draw()
  love.graphics.setColor(self:getColor())
  local cx,cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2)
end

function Knight:blow(other)
  self.energy = self.energy - 0.25
  if self.energy < 0 then
    self:die()
  else
    self:gotoState('Pursuing')
    self.target = other
  end
end

function Knight:lookAround(visibles)
  AI.lookAround(self, visibles)
  if self.seen[self.target] and self.target.dead then
    self.target = self.primaryTarget
    self:gotoState('Idle')
  end
end

local Idle = Knight:addState('Idle')
function Idle:think()
  if self.seen[self.target] then
    self.tx, self.ty = self.target:getCenter()
    self:gotoState('Pursuing')
  end
end


local Pursuing = Knight:addState('Pursuing')
function Pursuing:getColor() return 255,255,0 end

function Pursuing:enteredState()
  cron.tagged(self, 'pursue').after(10, function() self:gotoState('Idle') end)
end

function Pursuing:think()
  if self.seen[self.target] then
    cron.tagged(self, 'pursue').cancel()
    cron.tagged(self, 'pursue').after(10, function() self:gotoState('Idle') end)
    self.tx, self.ty = self.target:getCenter()
    local _,_,d = self:vectorTo(self.target)
    if d < 40 then
      self:gotoState('Attacking')
    end
  end
end


local Attacking = Knight:addState('Attacking')
function Attacking:getColor() return 255,0,0 end

function Attacking:enteredState()
  cron.tagged(self, 'blow').after(0.5, function() self:gotoState('Pursuing') end)
end

function Attacking:update(dt)
  -- Immobile on attack
end

function Attacking:exitedState()
  local cx, cy = self:getCenter()
  local tx, ty = self.target:getCenter()
  local x,y = cx + (tx-cx)/2, cy + (ty-cy)/2
  Blow:new(self, x,y)
end

return Knight
