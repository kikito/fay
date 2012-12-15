local Entity = require.relative(..., 'Entity')

local Blow = class('Blow', Entity)
local DEFAULT_W = 20
local DEFAULT_H = 20
function Blow:initialize(origin, target ,w,h)
  w,h = w or DEFAULT_W, h or DEFAULT_H
  local cx, cy = origin:getCenter()
  local tx, ty = target:getCenter()
  local x,y = cx + (tx-cx)/2, cy + (ty-cy)/2
  Entity.initialize(self, x-w/2,y-w/2,w,h)
end

function Blow:isOpaque()
  return false
end

function Blow:draw()
  love.graphics.setColor(255,0,0)
  love.graphics.rectangle('line', self:getBBox())
end

return Blow
