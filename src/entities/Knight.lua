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
  if self.energy <= 0 then
    self:die()
  else
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

function Knight:attack(x,y)
  self.attackX, self.attackY = x,y
  self:pushState('Attacking')
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
      self:attack(self.tx, self.ty)
    end
  end
end


local Attacking = Knight:addState('Attacking')
function Attacking:getColor() return 255,0,0 end

function Attacking:enteredState()
  cron.tagged(self, 'blow').after(0.5, function()
    local cx, cy = self:getCenter()
    local tx, ty = self.attackX, self.attackY
    local dx, dy = tx-cx, ty-cy
    local m = math.max(self.w, self.h) / math.sqrt(dx*dx + dy*dy)
    local x,y = cx + dx*m, cy+dy*m
    Blow:new(self, x,y)
    self:popState('Attacking')
  end)
end

function Attacking:attack()
  -- can not cancel current attack until finished
end

function Attacking:update(dt)
  -- Immobile on attack
end

function Attacking:exitedState()
  cron.tagged(self, 'blow').cancel()
end

return Knight
