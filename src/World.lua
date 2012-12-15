local bump = require 'lib.bump'

local entities = require.tree 'entities'

local rand     = math.random

local World = class('World')

local WIDTH, HEIGHT = 4000,4000
local MAX_TILE_W, MAX_TILE_H = 200,200

function World:initialize()
  self.player = entities.Player:new(100,100)

  for i=1,200 do
    entities.Tile:new(rand(0, WIDTH-MAX_TILE_W),
                      rand(0, HEIGHT-MAX_TILE_H),
                      rand(20, MAX_TILE_W),
                      rand(20, MAX_TILE_H))
  end

  for i=1,40 do
    entities.Enemy:new(rand(100, WIDTH-100),
                       rand(100, HEIGHT-100),
                       45,
                       self.player)
  end
end

function World:getBoundaries()
  return 0,0,WIDTH,HEIGHT
end

function World:destroy()
  self.player = nil
  entities.Entity:safeEach('destroy')
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
  local visibles, length = {}, 0
  bump.eachInRegion(l,t,w,h, function(item)
    length = length + 1
    visibles[length] = item
  end)
  table.sort(visibles, sortForDrawing)
  for _,visible in ipairs(visibles) do visible:draw() end
end

function World:update(dt, l,t,w,h)
  bump.eachInRegion(l,t,w,h, function(item) item:update(dt) end)
  bump.collide()
end

return World
