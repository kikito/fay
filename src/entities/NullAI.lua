local NullAI = {}

function NullAI:getMovementVector()
  return 0,0
end

function NullAI:reactToBlow() end
function NullAI:reactToDeath() end


return NullAI
