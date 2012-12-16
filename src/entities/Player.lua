local cron     = require 'lib.cron'
local tween    = require 'lib.tween'
local beholder = require 'lib.beholder'
local bump     = require 'lib.bump'

local Being = require.relative(..., 'Being')
local Fay   = require.relative(..., 'Fay')
local AI    = require.relative(..., 'AI')

local Player = class('Player', Being)

local POSSESS_RADIUS = 20

function Player:initialize(x,y)
  Being.initialize(self, x, y, 16, 16, 250)
  self.body = Fay:new(x,y)
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
  self:gotoState('Blinking')
end
function Player:secondaryAction()
  -- do nothing by default
end

function Player:update(dt)
  self:setCenter(self.body:getCenter())
end

function Player:setTarget(x,y)
  Being.setTarget(self, x,y)
  self.body:setTarget(x,y)
end

function Player:shouldCollide() return false end
function Player:isSolid()       return false end
function Player:isOpaque()      return false end
function Player:collision()                  end

local Unblinking = Player:addState('Unblinking')
function Unblinking:update(dt)
  Being.update(self, dt)
  if self:getDistanceToTarget() < 20 then
    self:setCenter(self.tx, self.ty)
    self.body:setCenter(self.tx, self.ty)
    self.body:gotoState()
    self:gotoState()
  end
end
function Unblinking:getDesiredMovementVector()
  self:setTarget(self.body:getCenter())
  local dx,dy = Player.getDesiredMovementVector(self)
  return dx*100, dy*100 -- don't aminorate when reaching target
end

local Blinking = Player:addState('Blinking', Unblinking)

function Blinking:enteredState()
  self.body:gotoState('Stun')
end

function Blinking:shouldCollide(other)
  return other ~= self.body and instanceOf(AI, other)
end

function Blinking:collision(other)
  self.possessed  = other
  other.possessor = self
  other:gotoState('Possessed')
  self:gotoState('Possessing')
end

function Blinking:getDesiredMovementVector()
  local dx, dy = Player.getDesiredMovementVector(self)
  return dx*100, dy*100
end

local Possessing = Player:addState('Possessing')
function Possessing:setTarget(x,y)
  self.possessed:setTarget(x,y)
end
function Possessing:update(dt)
  self:setCenter(self.possessed:getCenter())
end
function Possessing:primaryAction(x,y)
  self.possessed:attack(x,y)
end
function Possessing:secondaryAction()
  self.possessed:die()
end


return Player
