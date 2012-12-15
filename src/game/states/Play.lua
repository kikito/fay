local gamera      = require 'lib.gamera'
--local bump_debug  = require 'lib.bump_debug'

local Game        = require 'game.Game'
local Play        = Game:addState('Play')

local World       = require 'World'

local world, cam


function Play:enteredState()
  world  = World:new()
  cam    = gamera.new(World:getBoundaries())
end

function Play:exitedState()
  world:destroy()
  world, cam = nil, nil, nil
end


function Play:draw()
  cam:draw(function(l,t,w,h)
    world:draw(l,t,w,h)
    -- bump_debug.draw()
  end)
end

function Play:update(dt)
  world:update(dt, cam:getVisible())
  cam:setPosition(world.player:getCenter())
end

function Play:escape()
  self:gotoState("MainMenu")
end

return Play
