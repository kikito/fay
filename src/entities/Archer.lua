local cron = require 'lib.cron'

local Being = require.relative(..., 'Being')
local AI    = require.relative(..., 'AI')
local Arrow = require.relative(..., 'Arrow')

local Archer = class('Archer', Being)

function Archer:initialize(x,y,target)
  Being.initialize(self, x,y, 20,20, 60)
  self:setMind(AI:new(self, target, 200,400))
end

function Archer:getColor() return 0,0,255 end

function Archer:attack(x,y)
  self.attackX, self.attackY = x,y
  self:pushState('Shooting')
end

local Shooting = Archer:addState('Shooting')
function Shooting:getColor() return 255,0,0 end

function Shooting:draw()
  Archer.draw(self)
  love.graphics.setColor(200,200,200,100)
  local cx, cy = self:getCenter()
  love.graphics.line(cx,cy, self.attackX, self.attackY)
end

function Shooting:enteredState()
  cron.tagged(self, 'shoot').after(1, function()
    Arrow:new(self, self.attackX, self.attackY)
    self:popState('Shooting')
  end)
end

function Shooting:attack() end
function Shooting:update() end

function Shooting:exitedState()
  cron.tagged(self, 'shoot').cancel()
end

return Archer

