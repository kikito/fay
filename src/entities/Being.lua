local cron   = require 'lib.cron'

local Entity = require.relative(..., 'Entity')
local NullAI = require.relative(..., 'NullAI')

local Being = class('Being', Entity)

function Being:initialize(x,y,w,h,speed)
  Entity.initialize(self, x-w/2, y-w/2, w, h, speed)
  self.mind = NullAI
  self.energy = 1
end

function Being:setMind(mind)
  self.mind = mind
end

function Being:shouldCollide(other)
  return self:isSolid() and other:isSolid()
end

function Being:collision(other, dx, dy)
  self.l, self.t = self.l + dx, self.t + dy
end

function Being:isOpaque()
  return false
end

function Being:draw()
  love.graphics.setColor(self:getColor())
  local cx,cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2)
end

function Being:update(dt)
  local dx,dy = self.mind:getMovementVector()
  self:move(dt, dx, dy)
end

function Being:blow(other, hitPoints)
  hitPoints = hitPoints or 1
  self.mind:reactToBlow(other, hitPoints)
  self.energy = self.energy - hitPoints
  if self.energy <= 0 then
    self:die()
  end
end

function Being:die()
  self.mind:reactToDeath()
  self:gotoState('Dead')
end


local Dead = Being:addState('Dead')
function Dead:enteredState()
  cron.tagged(self).cancel()
  cron.tagged(self).after(5, function() self:destroy() end)
  self.dead = true
end
function Dead:shouldCollide() return false end
function Dead:isSolid()       return false end
function Dead:draw()
  local l,t,w,h = self:getBBox()
  love.graphics.setColor(100,100,100)
  love.graphics.line(l,t,l+w,t+h)
  love.graphics.line(l,t+h,l+w,t)
end
function Dead:update()
end

return Being


