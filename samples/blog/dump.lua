local db = require "luasql.sqlite3"
local model = require "orbit.model"

local env = sqlite3()
local conn = env:connect("blog.db")

local mapper = model.new("blog_", conn, "sqlite3")

local tables = { "post", "comment", "page" }

print [[

local db = require "luasql.mysql"
local model = require "orbit.model"

local env = mysql()
local conn = env:connect("blog", "root", "password")

local mapper = model.new("blog_", conn, "mysql")

]]

local function serialize_prim(v)
  local type = type(v)
  if type == "string" then
    return string.format("%q", v)
  end
  return tostring(v)
end

local function serialize(t)
  local fields = {}
  for k, v in pairs(t) do
    table.insert(fields, " [" .. string.format("%q", k) .. "] = " .. serialize_prim(v))
  end
  return "{\n" .. table.concat(fields, ",\n") .. "}"
end

for _, tn in ipairs(tables) do

  print("\n -- Table " .. tn .. "\n")

  local t = mapper:new(tn)
  print("local t = mapper:new('" .. tn .. "')")
  local recs = t:find_all()

  for i, rec in ipairs(recs) do
    print("\n-- Record " .. i .. "\n")
    print("local rec = t:new(" .. serialize(rec)..")")
    print("rec:save(true)")
  end
end
