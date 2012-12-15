local cron = require 'lib.cron'

local AI   = require.relative(..., 'AI')
local Blow = require.relative(..., 'Blow')

local Knight = class('Knight', AI)

function Knight:initialize(x,y,target)
  AI.initialize(self, x,y, 60)
  self.target = target
  self:gotoState('Idle')
end

function Knight:getColor() return 255,255,255 end

function Knight:draw()
  love.graphics.setColor(self:getColor())
  local cx,cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2)
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
  local cx, cy = self:getCenter()
  local tx, ty = self.target:getCenter()
  local x,y = cx + (tx-cx)/2, cy + (ty-cy)/2
  self.blow = Blow:new(self, x,y)
  cron.tagged(self, 'blow').after(0.5, function() self:gotoState('Pursuing') end)
end

function Attacking:update(dt)
  -- Immobile on attack
end

function Attacking:exitedState()
  self.blow:destroy()
  self.blow = nil
end

return Knight
