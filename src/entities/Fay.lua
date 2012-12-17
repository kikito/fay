local cron     = require 'lib.cron'
local beholder = require 'lib.beholder'

local Being = require.relative(..., 'Being')
local Player   = require.relative(..., 'Player')

local Fay = class('Fay', Being)

function Fay:initialize(x,y)
  Being.initialize(self, x, y, 16, 16, 85)
  self:setMind(Player:new(self))
end

function Fay:die()
  beholder.trigger('gameover')
end

function Fay:blow(other)
  Being.blow(other, 0.2)
  self:resetHealingCounter()
end

function Fay:resetHealingCounter()
  cron.tagged(self, 'heal').cancel()
  cron.tagged(self, 'heal').after(5, function() self:pushState('Healing') end)
end


local Healing = Fay:addState('Healing')
function Healing:update(dt)
  Fay.update(self, dt)
  self.energy = self.energy + dt*0.1
  if self.energy >= 1 then
    self.energy = 1
    self:popState('Healing')
  end
end
function Healing:blow(other)
  self:popState('Healing')
  Fay.blow(self, other)
end
function Healing:draw()
  Fay.draw(self)
  local cx, cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2 + 3)
end


return Fay
