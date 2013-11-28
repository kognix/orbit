
local _M = _M or {}
if setfenv then
  setfenv(1, _M) -- for 5.1
else
  _ENV = _M -- for 5.2
end

local function flatten(t)
   local res = {}
   for _, item in ipairs(t) do
      res[#res + 1] = (type(item) == "table") and flatten(item) or item
   end
   return table.concat(res)
end

local function make_tag(name, data, class)
  class = class or ""
  if class then
    class = ' class="' .. class .. '"'
  end
  
  if not data then
    return "<" .. name .. class .. "/>"
  elseif type(data) == "string" then
    return "<" .. name .. class .. ">" .. data .. "</" .. name .. ">"
  end
  
  local attrs = {}
  for k, v in pairs(data) do
    if type(k) == "string" then
      table.insert(attrs, k .. '="' .. tostring(v) .. '"')
    end
  end
  
  return "<" .. name .. class .. " " .. table.concat(attrs, " ") .. ">" .. flatten(data) .. "</" .. name .. ">"
end

local function newtag(name)
  local tag = {}
  setmetatable(tag, {
    __call = function (_, data)
      return make_tag(name, data)
    end,
    __index = function(_, class)
      return function (data)
        return make_tag(name, data, class)
      end
    end
  })
  return tag
end

local function htmlify_func(func)
  local tags = {}

  local env = {
    H = function (name)
      local tag = tags[name]
      if not tag then
        tag = newtag(name)
        tags[name] = tag
      end
      return tag
    end
  }

  local old_env = getfenv(func)
  setmetatable(env, {
    __index = function (env, name)
      if old_env[name] then
        return old_env[name]
      end
      local tag = newtag(name)
      rawset(env, name, tag)
      return tag
    end
  })

  setfenv(func, env)
end


function _M.htmlify(app_module, ...)
  if type(app_module) == "function" then
    htmlify_func(app_module)
    for _, func in ipairs{...} do
      htmlify_func(func)
    end
  else
    local patterns = { ... }
    for _, patt in ipairs(patterns) do
      if type(patt) == "function" then
        htmlify_func(patt)
      else
        for name, func in pairs(app_module) do
          if string.match(name, "^" .. patt .. "$") and type(func) == "function" then
            htmlify_func(func)
          end
        end
      end
    end
  end
end