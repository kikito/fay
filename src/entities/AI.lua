local bump = require 'lib.bump'

local Being = require.relative(..., 'Being')

local AI    = class('AI', Being)

local weakKeys = {__mode = "k"}

function AI:initialize(x,y,speed)
  Being.initialize(self, x,y,24,24,speed)
  self.seen = setmetatable({}, weakKeys)
end

function AI:draw()
  love.graphics.setColor(255,0,0)
  local cx,cy = self:getCenter()
  love.graphics.circle('line', cx,cy, self.w/2)
end

function AI:canSee(other)
  local cx,cy = self:getCenter()
  local ox,oy = other:getCenter()
  local seen = false
  local result = bump.eachInSegment(cx,cy,ox,oy, function(item)
    if item == self then return end
    if item == other then
      seen = true
      return false
    end
    if item:isOpaque() then return false end
  end)
  return seen
end

function AI:lookAround(visibles)
  self.seen = {}
  for _,other in pairs(visibles) do
    if other ~= self and instanceOf(Being, other) then
      if self:canSee(other) then self.seen[other] = true end
    end
  end
end

return AI
