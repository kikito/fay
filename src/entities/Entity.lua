local bump = require 'lib.bump'
local Each = require 'lib.each'

local Entity = class('Entity'):include(Each)

local DEFAULT_WIDTH = 16
local DEFAULT_HEIGHT = 16

function Entity:initialize(x,y,w,h)
  self.w, self.h = w or DEFAULT_WIDTH, h or DEFAULT_HEIGHT
  self.l, self.t = x - self.w / 2, y - self.h / 2
  self.class:add(self)
  bump.add(self)
end

function Entity:getBBox()
  return self.l, self.t, self.w, self.h
end

function Entity:shouldCollide(other)
  return false
end

function Entity:getCenter()
  return self.l + self.w*0.5, self.t + self.h*0.5
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
