local cron = require 'lib.cron'

local Being  = require.relative(..., 'Being')
local Entity = require.relative(..., 'Entity')

local Blow = class('Blow', Entity)
local DEFAULT_W = 20
local DEFAULT_H = 20
function Blow:initialize(origin, x,y ,w,h)
  w,h = w or DEFAULT_W, h or DEFAULT_H
  Entity.initialize(self, x-w/2,y-w/2,w,h)
  self.origin = origin
  cron.after(0.3, function() self:destroy() end)
end

function Blow:shouldCollide(other)
  return other:isSolid()
end

function Blow:isOpaque()
  return false
end

function Blow:draw()
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle('line', self:getBBox())
end

function Blow:collision(other)
  if other ~= self.origin then
    if instanceOf(Being, other) and other:isSolid() then
      other:blow(self.origin)
      self:destroy()
    end
  end
end

return Blow
