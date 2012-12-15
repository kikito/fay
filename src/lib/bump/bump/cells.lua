-- bump.cells : This module contains the cells used in bump.lua, as well as the
-- functions to manage them. You usually will not need to use any of these

local cells = {} -- (public/exported) holds the public cell interface

local path = (...):gsub("%.cells$","")
local util       = require(path .. '.util')

local store      -- (private) holds references to the individual rows and cells

function cells.create(gx,gy)
  store.rows[gy] = store.rows[gy] or util.newWeakTable('v')
  local cell = {items = util.newWeakTable(), gx=gx, gy=gy}
  store.rows[gy][gx] = cell
  return cell
end
local cells_create = cells.create

function cells.get(gx,gy)
  return store.rows[gy] and store.rows[gy][gx]
end
local cells_get = cells.get

function cells.getOrCreate(gx,gy)
  return cells_get(gx,gy) or cells_create(gx,gy)
end

function cells.add(item, gl,gt,gw,gh)
  local cell
  for gx=gl,gl+gw do
    for gy=gt,gt+gh do
      cell = cells.getOrCreate(gx,gy)
      cell.items[item] = true
      store.nonEmptyCells[cell] = store.nonEmptyCells[cell] or 0
      store.nonEmptyCells[cell] = store.nonEmptyCells[cell] + 1
    end
  end
end

function cells.each(callback)
  for _,row in pairs(store.rows) do
    for _,cell in pairs(row) do
      if callback(cell) == false then return false end
    end
  end
end
local cells_each = cells.each

function cells.eachInBox(gl,gt,gw,gh, callback)
  local row, cell
  for gy=gt,gt+gh do
    row = store.rows[gy]
    if row then
      for gx=gl,gl+gw do
        cell = row[gx]
        if cell then
          if callback(cell) == false then return false end
        end
      end
    end
  end
end
local cells_eachInBox = cells.eachInBox

function cells.remove(item, gl,gt,gw,gh)
  cells_eachInBox(gl, gt, gw, gh, function(cell)
    cell.items[item] = nil
    store.nonEmptyCells[cell] = store.nonEmptyCells[cell] - 1
    if store.nonEmptyCells[cell] == 0 then store.nonEmptyCells[cell] = nil end
  end)
end

function cells.eachItemInBox(gl,gt,gw,gh, callback, visited)
  visited = visited and util.copy(visited) or {}
  cells_eachInBox(gl, gt, gw, gh, function(cell)
    for item,_ in pairs(cell.items) do
      if not visited[item] then
        visited[item] = true
        if callback(item) == false then return false end
      end
    end
  end)
end

function cells.count()
  local count = 0
  cells_each(function() count = count + 1 end)
  return count
end

function cells.reset(newCellSize)
  store = { rows = {}, nonEmptyCells = {} }
end

cells.reset()

return cells
