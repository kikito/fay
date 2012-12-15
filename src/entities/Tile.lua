local Entity = require.relative(..., "Entity")

local Tile = class('Tile', Entity)

function Tile:initialize(l,t,w,h)
  Entity.initialize(self, l,t,w,h)
end

function Tile:draw()
  love.graphics.setColor(0,0,255)
  love.graphics.rectangle("line", self:getBBox())
end

return Tile
