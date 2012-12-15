local beholder = require 'lib.beholder'

local Entity = require.relative(..., 'Entity')

local Player = class('Player', Entity)

function Player:initialize(x,y)
  Entity.initialize(self, x, y)
  self.wishes = {}
  self.speed = 60
  beholder.group(self, function()
    for _,action in ipairs({'up','down','right','left'}) do
      beholder.observe('player', 'start', action, function() self.wishes[action] = true end)
      beholder.observe('player', 'stop', action, function() self.wishes[action] = nil end)
    end
  end)
end

local directions = {
  up     = { dy  = -1 },
  down   = { dy  = 1 },
  left   = { dx  = -1 },
  right  = { dx  = 1 }
}

function Player:update(dt)
  local dx,dy = 0,0
  for wish,_ in pairs(self.wishes) do
    dx = dx + (directions[wish].dx or 0)
    dy = dy + (directions[wish].dy or 0)
  end
  self.l = self.l + dt * dx * self.speed
  self.t = self.t + dt * dy * self.speed
end

function Player:draw()
  love.graphics.setColor(0,255,0)
  local cx,cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2)
end

return Player
