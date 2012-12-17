local bump = require 'lib.bump'
local cron = require 'lib.cron'

local Entity = require.relative(..., 'Entity')
local Being  = require.relative(..., 'Being')

local AI    = class('AI', Entity)

function AI:initialize(body, target, fleeDistance, pursueDistance)
  self.body = body
  self.seen = {}
  self.foes = {[target]=true}
  self.fleeDistance   = fleeDistance
  self.pursueDistance = pursueDistance

  local cx,cy = body:getCenter()
  Entity.initialize(self, cx,cy,10,10)
end

function AI:getColor()
  return 255,255,0
end

function AI:draw()
  love.graphics.setColor(self:getColor())
  local cx,cy = self:getCenter()
  love.graphics.circle('fill', cx,cy, 5)
end

function AI:shouldCollide() return false end
function AI:isSolid()       return false end
function AI:isOpaque()      return false end
function AI:collision()     end

function AI:canSee(other)
  local cx,cy = self:getCenter()
  local ox,oy = other:getCenter()
  local seen = false
  local result = bump.eachInSegment(cx,cy,ox,oy, function(item)
    if item == self or item == self.body then return end
    if item == other then
      seen = true
      return false
    end
    if item:isOpaque() then return false end
  end)
  return seen
end

function AI:lookAround(onScreen)
  self.seen = {}
  for _,other in pairs(onScreen) do
    if other ~= self and instanceOf(Being, other) then
      if self:canSee(other) then self.seen[other] = true end
    end
  end
end

function AI:update(dt, onScreen)
  self:setCenter(self.body:getCenter())
  self:lookAround(onScreen)
  self:think()
end

function AI:forgetDeadFoes()
  for foe,_ in pairs(self.foes) do
    if foe.dead then self.foes[foe]=nil end
  end
end

function AI:getClosestSeenFoe()
  local foe, distance
  local closestDistance, closestFoe = math.huge, nil
  for foe,_ in pairs(self.foes) do
    if self.seen[foe] then
      local distance = self:getDistanceToOther(foe)
      if distance < closestDistance then
        closestFoe = foe
        closestDistance = distance
      end
    end
  end
  return closestFoe, closestDistance
end

function AI:getDistanceToOther(other)
  local cx, cy = self:getCenter()
  local tx, ty = other:getCenter()
  local dx, dy = tx-cx, ty-cy
  return math.sqrt(dx*dx + dy*dy)
end

function AI:think()
  self:forgetDeadFoes()
  local foe, d = self:getClosestSeenFoe()
  if foe then
    self.target = foe
    self:setGoal(self.target:getCenter())

    if d < self.fleeDistance then
      self:gotoState('Fleeing')
    elseif d > self.pursueDistance then
      self:gotoState('Pursuing')
    else
      self.body:attack(self.target:getCenter())
    end
  else
    self:gotoState()
  end
end

function AI:reactToBlow(other)
  self.foes[other] = true
end

function AI:reactToDeath()
  self.body, self.foes, self.seen = nil, nil, nil
  self.seen = nil
  self:destroy()
end

function AI:getMovementVector()
  local cx,cy = self:getCenter()
  local dx,dy = self.tx - cx, self.ty - cy
  return dx*100, dy*100
end

local Fleeing = AI:addState('Fleeing')
function Fleeing:getColor() return 255,0,255 end
function Fleeing:getMovementVector()
  local dx,dy = AI.getMovementVector(self)
  return -dx,-dy
end

local Pursuing = AI:addState('Pursuing')
function Pursuing:getColor() return 255,0,0 end

local Sleeping = AI:addState('Sleeping')
function Sleeping:getColor() return 100,100,100 end
function Sleeping:update()
  self:setCenter(self.body:getCenter())
end
function Sleeping:reactToBlow(other)
  self:gotoState()
  AI.reactToBlow(self, other)
end


return AI
