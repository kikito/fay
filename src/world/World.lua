local bump = require 'lib.bump'

local World = class('World')

function World:initialize()

  bump.initialize(16)

  function bump.collision(obj1,obj2,dx,dy)
    obj1:collision(obj2,dx,dy)
    obj2:collision(obj1,-dx,-dy)
  end

  function bump.endCollision(obj1,obj2)
    obj1:endCollision(obj2)
    obj2:endCollision(obj1)
  end

  function bump.shouldCollide(obj1,obj2)
    return obj1:shouldCollide(obj2) or obj2:shouldCollide(obj1)
  end

end

function World:getPlayer()

end

function World:destroy()

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

end

function World:update(dt, l,t,w,h)
  bump.collide(cam:getVisible())
end
