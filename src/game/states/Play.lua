local gamera      = require 'lib.gamera'
local bump        = require 'lib.bump'
--local bump_debug  = require 'lib.bump_debug'

local Game        = require 'game.Game'
local Play        = Game:addState('Play')

local World       = require 'World'

local world, cam

local function initializeBump()
  bump.initialize(64)

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

function Play:enteredState()
  initializeBump()
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
    local tx,ty = cam:toWorld(love.mouse.getPosition())
    love.graphics.setColor(255,255,255)
    love.graphics.circle('line', tx, ty, 20)
    -- bump_debug.draw()
  end)
end

function Play:update(dt)
  world.player:setTarget(cam:toWorld(love.mouse.getPosition()))
  world:update(dt, cam:getVisible())
  cam:setPosition(world.player:getCenter())
end

function Play:escape()
  self:gotoState("MainMenu")
end

return Play
