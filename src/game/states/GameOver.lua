local cron = require 'lib.cron'

local Game = require 'game.Game'

local GameOver = Game:addState('GameOver')


function GameOver:enteredState()
  cron.after(5, function() self:gotoState('MainMenu') end)
end

function GameOver:draw()
  love.graphics.print("You died. Game Over!", 250, 280)
end

function GameOver:escape()
  self:gotoState('MainMenu')
end
