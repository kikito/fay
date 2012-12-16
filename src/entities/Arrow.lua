local bump   = require 'lib.bump'
local cron   = require 'lib.cron'

local Entity = require.relative(..., 'Entity')
local Blow   = require.relative(..., 'Blow')

local Arrow = class('Arrow', Entity)

local function min(a,b) return a < b and a or b end
local function max(a,b) return a > b and a or b end

function Arrow:initialize(origin, tx,ty)
  local cx, cy = origin:getCenter()
  self.ox, self.oy = cx,cy
  self.tx, self.ty = tx,ty

  local l,t = min(cx,tx), min(cy,ty)
  local r,b = max(cx,tx), max(cy,ty)
  Entity.initialize(self, l,t,r-l,b-t)

  bump.eachInSegment(cx,cy,tx,ty, function(item, x,y)
    if item ~= origin and item:isSolid() then
      self.hit = item
      self.tx, ty = x,y
      self.blow = Blow:new(origin, x,y,5,5)
      return false
    end
  end)

  cron.after(0.25, function() self:destroy() end)
end

-- arrows are only visual stuff. What hurts is their blow
function Arrow:shouldCollide() return false end
function Arrow:isSolid() return false end

function Arrow:draw()
  love.graphics.setColor(255,255,255,150)
  love.graphics.line(self.ox, self.oy, self.tx, self.ty)
end

function Arrow:destroy()
  if self.blow then self.blow:destroy() end
  self.blow = nil
  Entity.destroy(self)
end

return Arrow
