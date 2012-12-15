local Entity = require.relative(..., 'Entity')

local Blow = class('Blow', Entity)
local DEFAULT_W = 20
local DEFAULT_H = 20
function Blow:initialize(origin, x,y ,w,h)
  w,h = w or DEFAULT_W, h or DEFAULT_H
  Entity.initialize(self, x-w/2,y-w/2,w,h)
  self.origin = origin
end

function Blow:isOpaque()
  return false
end

function Blow:draw()
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle('line', self:getBBox())
end

return Blow
