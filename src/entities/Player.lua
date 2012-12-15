local Being = require.relative(..., 'Being')

local Player = class('Player', Being)

function Player:initialize(x,y)
  Being.initialize(self, x, y, 16, 16, 40)
  self.tx, self.ty = 0,0
end

function Player:setTarget(tx,ty)
  self.tx, self.ty = tx,ty
end

function Player:getDesiredMovementVector()
  local cx,cy = self:getCenter()
  return self.tx - cx, self.ty - cy
end


return Player
