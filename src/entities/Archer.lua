local cron = require 'lib.cron'

local AI    = require.relative(..., 'AI')
local Arrow = require.relative(..., 'Arrow')

local Archer = class('Archer', AI)

local FLEEING_D  = 200
local PURSUING_D = 400

function Archer:initialize(x,y,target)
  AI.initialize(self, x,y, 60)
  self.target = target
  self:gotoState('Idle')
end

function Archer:getColor() return 0,255,255 end

function Archer:draw()
  love.graphics.setColor(self:getColor())
  love.graphics.rectangle('line', self:getBBox())
end

function Archer:blow(other)
  self.energy = self.energy - 0.34
  if self.energy < 0 then
    self:die()
  else
    self:gotoState('Pursuing')
    self.target = other
  end
end

function Archer:lookAround(visibles)
  AI.lookAround(self, visibles)
  if self.seen[self.target] and self.target.dead then
    self.target = self.primaryTarget
    self:gotoState('Idle')
  end
end

local Idle = Archer:addState('Idle')
function Idle:think()
  if self.seen[self.target] then
    local _,_,d = self:vectorTo(self.target)
    if d < FLEEING_D then
      self:gotoState('Fleeing')
    elseif d > PURSUING_D then
      self:gotoState('Pursuing')
    else
      self:gotoState('Shooting')
    end
  end
end

local Fleeing = Archer:addState('Fleeing')
function Fleeing:getColor() return 0,255,255 end
function Fleeing:enteredState()
  cron.tagged(self, 'flee').after(10, function() self:gotoState('Idle') end)
end
function Fleeing:think()
  if self.seen[self.target] then self.tx, self.ty = self.target:getCenter()
    cron.tagged(self, 'flee').cancel()
    cron.tagged(self, 'flee').after(10, function() self:gotoState('Idle') end)
    local _,_,d = self:vectorTo(self.target)
    if d < FLEEING_D then return end
    if d > PURSUING_D then
      self:gotoState('Pursuing')
    else
      self:gotoState('Shooting')
    end
  end
end
function Fleeing:getDesiredMovementVector()
  local dx,dy = AI.getDesiredMovementVector(self)
  return -dx, -dy
end

local Pursuing = Archer:addState('Pursuing')
function Pursuing:getColor() return 255,0,0 end
function Pursuing:enteredState()
  cron.tagged(self, 'pursue').after(10, function() self:gotoState('Idle') end)
end
function Pursuing:think()
  if self.seen[self.target] then
    self.tx, self.ty = self.target:getCenter()
    cron.tagged(self, 'pursue').cancel()
    cron.tagged(self, 'pursue').after(10, function() self:gotoState('Idle') end)
    local _,_,d = self:vectorTo(self.target)
    if d < FLEEING_D then
      self:gotoState('Fleeing')
    elseif d > PURSUING_D then return
    else
      self:gotoState('Shooting')
    end
  end
end

local Shooting = Archer:addState('Shooting')
function Shooting:getColor() return 255,0,0 end

function Shooting:draw()
  Archer.draw(self)
  love.graphics.setColor(200,200,200,100)
  local cx, cy = self:getCenter()
  love.graphics.line(cx,cy, self.tx, self.ty)
end

function Shooting:enteredState()
  cron.tagged(self, 'shoot').after(2.5, function()
    Arrow:new(self, self.target)
    self:gotoState('Pursuing')
  end)
end
function Shooting:think()
  if self.seen[self.target] then
    self.tx, self.ty = self.target:getCenter()
    local _,_,d = self:vectorTo(self.target)
    if d < FLEEING_D then
      cron.tagged(self, 'shoot').cancel()
      self:gotoState('Fleeing')
    elseif d > PURSUING_D then
      cron.tagged(self, 'shoot').cancel()
      self:gotoState('Pursuing')
    end
  else
    cron.tagged(self, 'shoot').cancel()
    self:gotoState('Pursuing')
  end
end
function Shooting:getDesiredMovementVector()
  return 0,0 -- don't move while shooting
end

return Archer

