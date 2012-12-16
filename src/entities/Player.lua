local cron     = require 'lib.cron'
local tween    = require 'lib.tween'
local beholder = require 'lib.beholder'

local Being = require.relative(..., 'Being')
local Fay   = require.relative(..., 'Fay')

local Player = class('Player', Being)

function Player:initialize(x,y)
  Being.initialize(self, x, y, 16, 16, 200)
  self.sustrate = Fay:new(x,y)
  beholder.group(self, function()
    beholder.observe('player', 'primary', function(x,y)
      self:primaryAction(x,y)
    end)
    beholder.observe('player', 'secondary', function()
      self:secondaryAction()
    end)
  end)
end

function Player:destroy()
  beholder.stopObserving(self)
  Being.destroy(self)
end

function Player:primaryAction(x,y)
  self.blinkX, self.blinkY = x-self.w/2,y-self.h/2
  self:gotoState('Blinking')
end

function Player:update(dt)
  self:setCenter(self.sustrate:getCenter())
end

function Player:setTarget(x,y)
  self.sustrate:setTarget(x,y)
end

function Player:shouldCollide() return false end
function Player:isSolid()       return false end
function Player:isOpaque()      return false end
function Player:collision()                  end

local Blinking = Player:addState('Blinking')

function Blinking:enteredState()
  self.sustrate:gotoState('Stun')
  tween(0.4, self, {l=self.blinkX, t=self.blinkY}, 'linear', function()
    self.sustrate:setCenter(self:getCenter())
    self.sustrate:gotoState()
    self:gotoState()
  end)
end

function Blinking:update()
end

return Player
