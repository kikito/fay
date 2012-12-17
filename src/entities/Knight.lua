local cron = require 'lib.cron'

local Being = require.relative(..., 'Being')
local AI    = require.relative(..., 'AI')
local Blow  = require.relative(..., 'Blow')

local Knight = class('Knight', Being)

function Knight:initialize(x,y, target)
  Being.initialize(self, x,y, 24,24, 60)
  self:setMind(AI:new(self, target, 0,40))
end

function Knight:getColor() return 0,255,255 end

function Knight:attack(x,y)
  self.attackX, self.attackY = x,y
  self:pushState('Attacking')
end

function Knight:blow(other)
  Being.blow(self, other, 0.25)
end

local Attacking = Knight:addState('Attacking')
function Attacking:getColor() return 255,0,0 end

function Attacking:enteredState()
  cron.tagged(self, 'attack').after(0.5, function()
    local cx, cy = self:getCenter()
    local tx, ty = self.attackX, self.attackY
    local dx, dy = tx-cx, ty-cy
    local m = math.max(self.w, self.h) / math.sqrt(dx*dx + dy*dy)
    local x,y = cx + dx*m, cy+dy*m
    Blow:new(self, x,y)
    self:popState('Attacking')
  end)
end

-- do nothing while attacking
function Attacking:attack() end
function Attacking:update(dt) end

function Attacking:exitedState()
  cron.tagged(self, 'attack').cancel()
end

return Knight
