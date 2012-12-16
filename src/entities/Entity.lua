local bump      = require 'lib.bump'
local cron      = require 'lib.cron'
local Each      = require 'lib.each'
local Stateful  = require 'lib.stateful'

local Entity = class('Entity'):include(Each, Stateful)

function Entity:initialize(l,t,w,h)
  self.l, self.t, self.w, self.h = l,t,w,h
  self.class:add(self)
  bump.add(self)
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

function Entity:vectorTo(other)
  local cx,cy = self:getCenter()
  local ox,oy = other:getCenter()
  local dx,dy = ox-cx, oy-cy
  return dx,dy, math.sqrt(dx*dx + dy*dy)
end

function Entity:draw()
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle('line', self:getBBox())
end

function Entity:update(dt)
end

function Entity:destroy()
  bump.remove(self)
  self.class:remove(self)
  cron.tagged(self).cancel()
end


return Entity
