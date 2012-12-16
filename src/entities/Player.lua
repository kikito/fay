local beholder = require 'lib.beholder'

local Being = require.relative(..., 'Being')

local Player = class('Player', Being)

function Player:initialize(x,y)
  Being.initialize(self, x, y, 16, 16, 85)
end

function Player:die()
  beholder.trigger('gameover')
end

return Player
