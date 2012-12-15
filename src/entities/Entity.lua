local bump = require 'lib.bump'
local Each = require 'lib.each'

local Entity = class('Entity'):include(Each)


function Entity:initialize(l,t,w,h)
  self.l, self.t, self.w, self.h = l,t,w,h
  self.class:add(self)
  bump.add(self)
end

function Entity:getBBox()
  return self.l, self.t, self.w, self.h
end

function Entity:shouldCollide(other)
  return false
end

function Entity:collision(other, dx,dy)
end

function Entity:endCollision(other)
end

function Entity:getCenter()
  return self.l + self.w*0.5, self.t + self.h*0.5
end

function Entity:isOpaque()
  return true -- by default, everything is opaque
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
end


return Entity
