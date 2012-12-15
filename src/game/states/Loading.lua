local loader = require 'lib.love-loader'

local Game  = require 'game.Game'
local media = require 'media'

local Loading = Game:addState('Loading')

function readFolder(path, holder, readFunction)
  local lfs = love.filesystem
  local fileNames = lfs.enumerate(path)
  for i,fileName in ipairs(fileNames) do
    local path  = folder.."/".. fileName
    if lfs.isFile(path) then
      local name = fileName:match("(.+)%.") -- transforms "file.png" into "file"
      readFunction(holder, name, path)
    end
  end
end

function Loading:enteredState()
  self:log('Entered Loading')
  readFolder('media/images', media.images, loader.newImage)

  loader.start(function() self:gotoState("MainMenu") end)
end

function Loading:update()
  loader.update()
end

function Loading:draw()
  love.graphics.print("Loading ...", 350,290)
end

return Loading
