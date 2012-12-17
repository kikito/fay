local bump      = require 'lib.bump'
local cron      = require 'lib.cron'
local Each      = require 'lib.each'
local Stateful  = require 'lib.stateful'

local Entity = class('Entity'):include(Each, Stateful)

local sqrt = math.sqrt
local function abs(x) return x < 0 and -x or x end
local function truncateVector(maxL, x,y)
  if maxL == 0 or (x==0 and y==0) then return 0,0 end
  local len = sqrt(x*x + y*y)
  local s = maxL / len
  s = s < 1 and s or 1
  return x*s, y*s
end

local DEFAULT_W      = 16
local DEFAULT_H      = 16
local DEFAULT_SPEED  = 0

function Entity:initialize(l,t,w,h,speed)
  w,h,speed = w or DEFAULT_W, h or DEFAULT_H, speed or DEFAULT_SPEED
  self.l, self.t, self.w, self.h, self.speed = l,t,w,h,speed
  self:setGoal(self:getCenter())

  self.class:add(self)
  bump.add(self)
end

function Entity:setGoal(tx,ty)
  self.tx, self.ty = tx,ty
end

function Entity:getDistanceToGoal()
  local cx,cy = self:getCenter()
  local dx,dy = self.tx - cx, self.ty - cy
  return sqrt(dx*dx + dy*dy)
end

function Entity:getBBox()
  return self.l, self.t, self.w, self.h
end

function Entity:shouldCollide(other) return false end

function Entity:collision(other, dx,dy) end

function Entity:endCollision(other) end

function Entity:isOpaque()
  return true -- by default, everything is opaque
end

function Entity:isSolid()
  return true -- for now it only worls for stucking arrows
end

function Entity:getCenter()
  return self.l + self.w*0.5, self.t + self.h*0.5
end

function Entity:setCenter(x,y)
  self.l, self.t = x - self.w*0.5, y - self.h*0.5
end

function Entity:vectorTo(x,y)
  local cx,cy = self:getCenter()
  return x-cx, y-cy
end

function Entity:move(dt, dx,dy)
  dx, dy = truncateVector(self.speed, dx, dy)
  self.l, self.t = self.l + dx*dt, self.t + dy*dt
end

function Entity:getColor()
  return 255,255,255
end

function Entity:draw()
  love.graphics.setColor(self:getColor())
  love.graphics.rectangle('line', self:getBBox())
end

function Entity:update(dt)
end

function Entity:destroy()
  bump.remove(self)
  self.class:remove(self)
  cron.tagged(self).cancel()
end

function Entity:__tostring()
  local str = table.concat({self:getBBox()}, ", ")
  return self.class.name .. " { " .. str .. " }"
end


return Entity
