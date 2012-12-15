local Entity = require.relative(..., 'Entity')

local Being = class('Being', Entity)

local DEFAULT_W = 16
local DEFAULT_H = 16
local DEFAULT_SPEED = 60

local sqrt = math.sqrt

local function abs(x) return x < 0 and -x or x end
local function vectorLength(x,y) return sqrt(x*x + y*y) end
local function truncateVector(maxL, x,y)
  local s = maxL / vectorLength(x,y)
  s = s > 1 and s or 1
  return x*s, y*s
end

function Being:initialize(x,y,speed)
  Entity.initialize(self, x-DEFAULT_W/2, y-DEFAULT_H/2, DEFAULT_W, DEFAULT_H)
  self.speed = speed or DEFAULT_SPEED
end

function Being:shouldCollide()
  return true
end

function Being:collide(other, dx, dy)
  self.l, self.t = self.l + dx, self.t + dy
end

function Being:getDesiredMovementVector()
  return 0,0 -- no movement
end

function Being:draw()
  love.graphics.setColor(0,255,0)
  local cx,cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2)
end

function Being:update(dt)
  local dx, dy = truncateVector(self.speed, self:getDesiredMovementVector())
  self.l, self.t = self.l + dx*dt, self.t + dy*dt
end

return Being


