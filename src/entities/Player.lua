local cron     = require 'lib.cron'
local tween    = require 'lib.tween'
local beholder = require 'lib.beholder'
local bump     = require 'lib.bump'

local Entity = require.relative(..., 'Entity')
local Being  = require.relative(..., 'Being')
local NullAI = require.relative(..., 'NullAI')

local Player = class('Player', Entity)

function Player:initialize(body)
  self.body = body
  local cx,cy = body:getCenter()
  Entity.initialize(self, cx,cy,10,10,300)

  beholder.group(self, function()
    beholder.observe('player', 'primary', function(x,y)
      self:primaryAction(x,y)
    end)
    beholder.observe('player', 'secondary', function()
      self:secondaryAction()
    end)
  end)
end

function Player:getColor() return 0,255,0 end

function Player:draw()
  love.graphics.setColor(self:getColor())
  local cx, cy = self:getCenter()
  love.graphics.circle('fill', cx,cy, self.w/2)
end

function Player:destroy()
  beholder.stopObserving(self)
  Entity.destroy(self)
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

function Player:getMovementVector()
  local cx,cy = self:getCenter()
  return self.tx - cx, self.ty - cy
end

function Player:shouldCollide() return false end
function Player:isSolid()       return false end
function Player:isOpaque()      return false end
function Player:collision()                  end

function Player:reactToBlow() end
function Player:reactToDeath() end

function Player:possess(other)
  self.replaced_mind  = other.mind
  self.replaced_mind:gotoState('Sleeping')
  self.possessed_body = other
  other.mind          = self
  self:gotoState('Possessing')
end

local Blinking = Player:addState('Blinking')
function Blinking:getColor()
  return 255,255,0
end
function Blinking:enteredState()
  self.body.mind = NullAI
end
function Blinking:update(dt)
  local dx,dy = self:getMovementVector()
  self:move(dt, dx, dy)
  if self:getDistanceToGoal() < 20 then
    self.body.mind = self
    self.body:setCenter(self:getCenter())
    self:gotoState()
  end
end
function Blinking:shouldCollide(other)
  return other ~= self.body and instanceOf(Being, other) and not other.dead
end
function Blinking:collision(other)
  self:possess(other)
end
function Blinking:getMovementVector()
  local dx, dy = Player.getMovementVector(self)
  return dx*100, dy*100
end


local Possessing = Player:addState('Possessing')
function Possessing:update(dt)
  self:setCenter(self.possessed_body:getCenter())
end
function Possessing:primaryAction(x,y)
  self.possessed_body:attack(x,y)
end
function Possessing:secondaryAction()
  self.possessed_body:die()
end
function Possessing:reactToDeath()
  self.replaced_mind:reactToDeath()
  self:gotoState('Unblinking')
end
function Possessing:reactToBlow(other)
  self.replaced_mind:reactToBlow(other)
  self:gotoState('Unblinking')
end
function Possessing:exitedState()
  self.possessed_body.mind = self.replaced_mind
  self.possessed_body = nil
  self.replaced_mind = nil
end

local Unblinking = Player:addState('Unblinking')
function Unblinking:getColor() return 255,0,255 end
function Unblinking:enteredState()
  self.speed = 400
  self.tx, self.ty = self.body:getCenter()
end
function Unblinking:update(dt)
  local dx,dy = self:getMovementVector()
  self:move(dt, dx, dy)
  if self:getDistanceToGoal() < 20 then
    self:setCenter(self.tx, self.ty)
    self.body.mind = self
    self:gotoState()
  end
end
function Unblinking:getMovementVector()
  local dx, dy = Player.getMovementVector(self)
  return dx*100, dy*100 -- don't aminorate when reaching goal
end
function Unblinking:setGoal()
end
function Unblinking:primaryAction() end
function Unblinking:exitedState()
  self.speed = 300
end


return Player
