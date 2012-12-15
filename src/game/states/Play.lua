local gamera      = require 'lib.gamera'

local Game        = require 'game.Game'
local Play        = Game:addState('Play')

local World       = require 'world'

local world
local player
local cam


function Play:enteredState()
  world  = World:new()
  player = World:getPlayer()
  cam    = gamera.new(World:getBoundaries())
end

function Play:exitedState()
  world:destroy()
  world, player, cam = nil, nil, nil
end


function Play:draw()
  cam:draw(function(l,t,w,h)
    world:draw(l,t,w,h)
  end)
end

function Play:update(dt)
  world:update(dt, cam:getVisible())
  cam:setPosition(player:getCenter())
end

function Play:escape()
  self:gotoState("MainMenu")
end

return Play
