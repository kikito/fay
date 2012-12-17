local bump = require 'lib.bump'

local entities = require.tree 'entities'

local rand     = math.random

local World    = class('World')
local onScreen = {}

local WIDTH, HEIGHT = 4000,4000
local MAX_TILE_W, MAX_TILE_H = 200,200

function World:initialize()
  local fay   = entities.Fay:new(100,100)
  self.player = fay.mind

  for i=1,200 do
    entities.Tile:new(rand(0, WIDTH-MAX_TILE_W),
                      rand(0, HEIGHT-MAX_TILE_H),
                      rand(20, MAX_TILE_W),
                      rand(20, MAX_TILE_H))
  end

  for i=1,40 do
    entities.Knight:new(rand(100, WIDTH-100),
                        rand(100, HEIGHT-100),
                        fay)
  end

  for i=1,0 do
    entities.Archer:new(rand(100, WIDTH-100),
                        rand(100, HEIGHT-100),
                        fay)
  end
end

function World:getBoundaries()
  return 0,0,WIDTH,HEIGHT
end

function World:destroy()
  self.player = nil
  entities.Entity:safeEach('destroy')
end

local function sortOnScreen(a,b)
  if a.z == b.z then
    local _,ay = a:getCenter()
    local _,by = b:getCenter()
    return ay < by
  end
  return a.z < b.z
end

local function updateOnScreen(l,t,w,h)
  local length = 0
  onScreen = {}
  bump.eachInRegion(l,t,w,h, function(item)
    length = length + 1
    onScreen[length] = item
  end)
  table.sort(onScreen, sortOnScreen)
end

function World:draw(l,t,w,h)
  for _,item in ipairs(onScreen) do item:draw() end
end

function World:update(dt, l,t,w,h)
  updateOnScreen(l,t,w,h)
  for _,item in ipairs(onScreen) do
    if instanceOf(entities.AI, item) or instanceOf(entities.Player, item) then
      item:update(dt, onScreen)
    end
  end

  for _,item in ipairs(onScreen) do
    if not instanceOf(entities.AI, item) and not instanceOf(entities.Player, item) then
      item:update(dt)
    end
  end

  bump.collide(l,t,w,h)
end

return World
