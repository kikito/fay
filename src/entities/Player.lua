local cron     = require 'lib.cron'
local beholder = require 'lib.beholder'

local Being = require.relative(..., 'Being')

local Player = class('Player', Being)

function Player:initialize(x,y)
  Being.initialize(self, x, y, 16, 16, 85)
end

function Player:die()
  beholder.trigger('gameover')
end

function Player:blow(other)
  self.energy = self.energy - 0.20
  if self.energy <= 0 then
    self:die()
  end
  cron.tagged(self, 'heal').cancel()
  cron.tagged(self, 'heal').after(5, function() self:gotoState('Healing') end)
end

local Healing = Player:addState('Healing')

function Healing:update(dt)
  Player.update(self, dt)
  self.energy = self.energy + dt*0.1
  if self.energy >= 1 then
    self.energy = 1
    self:gotoState()
  end
end

function Healing:blow(other)
  self:gotoState()
  Player.blow(self, other)
end

function Healing:draw()
  Player.draw(self)
  local cx, cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2 + 3)
end

return Player
