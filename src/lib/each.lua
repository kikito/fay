local Each = { static = {} }
local instances = {}

local function clone(t)
  local result = {}
  for k,v in pairs(t) do result[k] = v end
  return result
end

local function add(klass, instance)
  if includes(Each, klass) then
    add(klass.super, instance)
    instances[klass] = instances[klass] or {}
    instances[klass][instance] = 1
  end
end

local function remove(klass, instance)
  if includes(Each, klass) then
    instances[klass][instance] = nil
    remove(klass.super, instance)
  end
end

local function each(collection, method, ...)
  for instance,_ in pairs(collection) do
    local m = type(method) == 'function' and method or instance[method]
    m(instance, ...)
  end
end

-- public interface

function Each.static:each(method, ...)
  each(instances[self], method, ...)
end

function Each.static:safeEach(method, ...)
  each(clone(instances[self]), method, ...)
end

Each.static.add    = add
Each.static.remove = remove

return Each
