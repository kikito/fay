local Entity = require.relative(..., "Entity")

local Tile = class('Tile', Entity)

function Tile:initialize(l,t,w,h)
  Entity.initialize(self, l,t,w,h)
end

function Tile:getColor()
  return 0,0,255
end

return Tile
