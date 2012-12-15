local AI = require.relative(..., 'AI')

local Knight = class('Knight', AI)

function Knight:initialize(x,y,target)
  AI.initialize(self, x,y, 30)
  self.target = target
end

function Knight:update(dt, visibles)
  self:lookAround(visibles)
  if self.seen[self.target] then
    self.tx, self.ty = self.target:getCenter()
  end
  AI.update(self,dt)
end

return Knight
