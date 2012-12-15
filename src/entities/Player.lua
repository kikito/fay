local Being = require.relative(..., 'Being')

local Player = class('Player', Being)

function Player:initialize(x,y)
  Being.initialize(self, x, y, 16, 16, 40)
end



return Player
