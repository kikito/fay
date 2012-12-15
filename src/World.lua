local bump = require 'lib.bump'

local entities = require.tree 'entities'

local rand     = math.random

local World = class('World')

local WIDTH, HEIGHT = 4000,4000
local MAX_TILE_W, MAX_TILE_H = 200,200

local function initializeBump()
  bump.initialize(16)

  function bump.collision(obj1,obj2,dx,dy)
    obj1:collision(obj2,dx,dy)
    obj2:collision(obj1,-dx,-dy)
  end

  function bump.endCollision(obj1,obj2)
    obj1:endCollision(obj2)
    obj2:endCollision(obj1)
  end

  function bump.getBBox(obj)
    return obj:getBBox()
  end

  function bump.shouldCollide(obj1,obj2)
    return obj1:shouldCollide(obj2) or obj2:shouldCollide(obj1)
  end
end

function World:initialize()
  initializeBump()
  self.player = entities.Player:new(100,100)
  for i=1,50 do
    entities.Tile:new(rand(0, WIDTH-MAX_TILE_W),
                      rand(0, HEIGHT-MAX_TILE_H),
                      rand(20, MAX_TILE_W),
                      rand(20, MAX_TILE_H))
  end
end

function World:getBoundaries()
  return 0,0,WIDTH,HEIGHT
end

function World:destroy()
  self.player = nil
end

local function sortForDrawing(a,b)
  if a.z == b.z then
    local _,ay = a:getCenter()
    local _,by = b:getCenter()
    return ay < by
  end
  return a.z < b.z
end

function World:draw(l,t,w,h)
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('line', l,t,w,h)
  local visibles, length = {}, 0
  bump.eachInRegion(l,t,w,h, function(item)
    length = length + 1
    visibles[length] = item
  end)
  table.sort(visibles, sortForDrawing)
  for _,visible in ipairs(visibles) do
    visible:draw()
  end
end

function World:update(dt, l,t,w,h)
  bump.eachInRegion(l,t,w,h, function(item) item:update(dt) end)
  bump.collide()
end

return World
