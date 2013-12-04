local request = require "wsapi.request"
local response = require "wsapi.response"
local util = require "wsapi.util"
local htmlify = require "orbit.htmlify"
local mime_types = require 'orbit.mime_types'

local _M = _M or {}

_M._NAME = "orbit"
_M._VERSION = "2.3.0"
_M._COPYRIGHT = "Copyright (C) 2007-2010 Kepler Project"
_M._DESCRIPTION = "MVC Web Development for the Kepler platform"

local REPARSE = {}

_M.app_module_methods = {}
local app_module_methods = _M.app_module_methods

function app_module_methods.dispatch_get(app_module, func, ...)
  for _, pat in ipairs{ ... } do
    table.insert(app_module.dispatch_table.get, { pattern = pat, handler = func })
  end
end

function app_module_methods.dispatch_post(app_module, func, ...)
  for _, pat in ipairs{ ... } do
    table.insert(app_module.dispatch_table.post, { pattern = pat, handler = func })
  end
end

function app_module_methods.dispatch_put(app_module, func, ...)
  for _, pat in ipairs{ ... } do
    table.insert(app_module.dispatch_table.put, { pattern = pat, handler = func })
  end
end

function app_module_methods.dispatch_delete(app_module, func, ...)
  for _, pat in ipairs{ ... } do
    table.insert(app_module.dispatch_table.delete, { pattern = pat, handler = func })
  end
end

function app_module_methods.dispatch_wsapi(app_module, func, ...)
  for _, pat in ipairs{ ... } do
    for _, tab in pairs(app_module.dispatch_table) do
      table.insert(tab, { pattern = pat, handler = func, wsapi = true })
    end
  end
end

local function serve_file(app_module)
  return function (web)
    return app_module:serve_static(web, web.real_path .. web.path_info)
  end
end

function app_module_methods.dispatch_static(app_module, ...)
  app_module:dispatch_get(serve_file(app_module), ...)
end

function app_module_methods.serve_static(app_module, web, filename)
  local ext = string.match(filename, "%.([^%.]+)$")
  if app_module.use_xsendfile then
    web.headers["Content-Type"] = mime_types[ext] or "application/octet-stream"
    web.headers["X-Sendfile"] = filename
    return "xsendfile"
  end
  
  local file = io.open(filename, "rb")
  if not file then
    return app_module.not_found(web)
  end
    
  web.headers["Content-Type"] = mime_types[ext] or "application/octet-stream"
  local contents = file:read("*a")
  file:close()
  return contents
end

app_module_methods.htmlify = htmlify

function app_module_methods.model(app_module, ...)
  if app_module.mapper.default then
    local table_prefix = (app_module._NAME and app_module._NAME .. "_") or ""
    if not model then local model = require "orbit.model" end
    app_module.mapper = model.new(app_module.mapper.table_prefix or table_prefix, app_module.mapper.conn, app_module.mapper.driver, app_module.mapper.logging)
  end
  return app_module.mapper:new(...)
end

function _M.new(app_module)
  app_module = app_module or {}
  if type(app_module) == "string" then
    app_module = { _NAME = app_module }
  end
  
  for k, v in pairs(app_module_methods) do
    app_module[k] = v
  end
  
  app_module.run = function (wsapi_env)
    return _M.run(app_module, wsapi_env)
  end
  
  app_module.real_path = app_path or "."
  app_module.mapper = { default = true }
  app_module.not_found = function (web)
    web.status = "404 Not Found"
    return [[<html><head><title>Not Found</title></head><body><p>Not found!</p></body></html>]]
  end
  app_module.server_error = function (web, msg)
    web.status = "500 Server Error"
    return [[<html><head><title>Server Error</title></head><body><pre>]] .. msg .. [[</pre></body></html>]]
  end
  
  app_module.reparse = REPARSE
  
  app_module.dispatch_table = {
    get = {},
    post = {},
    put = {},
    delete = {}
  }

  return app_module
end

_M.web_methods = {}
local web_methods = _M.web_methods

function web_methods:redirect(url)
  self.status = "302 Found"
  self.headers["Location"] = url
  return "redirect"
end

function web_methods:link(url, params)
  local link = {}
  local prefix = self.prefix or ""
  local suffix = self.suffix or ""
  for k, v in pairs(params or {}) do
    link[#link + 1] = k .. "=" .. util.url_encode(v)
  end
  local qs = table.concat(link, "&")
  
  if qs and qs ~= "" then
    return prefix .. url .. suffix .. "?" .. qs
  end
  
  return prefix .. url .. suffix
end

function web_methods:static_link(url)
  local prefix = self.prefix or self.script_name
  local is_script = prefix:match("(%.%w+)$")
  if not is_script then
    return self:link(url)
  end
  
  local vpath = prefix:match("(.*)/") or ""
  return vpath .. url
end

function web_methods:empty(s)
  return not s or string.match(s, "^%s*$")
end

function web_methods:content_type(s)
  self.headers["Content-Type"] = s
end

function web_methods:page(name, env)
  local pages = pages or require "orbit.pages"
  local filename = (name:sub(1, 1) == "/") and self.doc_root .. name or self.real_path .. "/" .. name
  local template = pages.load(filename)
  if template then
    return pages.fill(self, template, env)
  end
end

function web_methods:page_inline(contents, env)
  local pages = pages or require "orbit.pages"
  local template = pages.load(nil, contents)
  if template then
    return pages.fill(self, template, env)
  end
end

function web_methods:empty_param(param)
  return self:empty(self.input[param])
end

for name, func in pairs(util) do
  web_methods[name] = function (self, ...)
    return func(...)
  end
end

local function dispatcher(app_module, method, path, index)
  index = index or 0
  if #app_module.dispatch_table[method] == 0 then
    return app_module["handle_" .. method], {}
  end
  
  for index = index+1, #app_module.dispatch_table[method] do
    local item = app_module.dispatch_table[method][index]
    local captures
    if type(item.pattern) == "string" then
      captures = { string.match(path, "^" .. item.pattern .. "$") }
    else
      captures = { item.pattern:match(path) }
    end
    if #captures > 0 then
      for i = 1, #captures do
        if type(captures[i]) == "string" then
          captures[i] = util.url_decode(captures[i])
        end
      end
      return item.handler, captures, item.wsapi, index
    end
  end
end

local function make_web_object(app_module, wsapi_env)

  local req = request.new(wsapi_env)
  local web = {
    status = '200 OK',
    response = '',
    headers = {
      ['Content-Type']= 'text/html'
    },
    cookies = {},
    vars = wsapi_env,
    prefix = app_module.prefix or wsapi_env.SCRIPT_NAME,
    suffix = app_module.suffix,
    real_path = (wsapi_env.APP_PATH ~= "") and wsapi_env.APP_PATH or app_module.real_path or ".",
    doc_root = wsapi_env.DOCUMENT_ROOT,
    path_info = req.path_info,
    path_translated = (wsapi_env.PATH_TRANSLATED ~= "") and wsapi_env.PATH_TRANSLATED or wsapi_env.SCRIPT_FILENAME,
    script_name = wsapi_env.SCRIPT_NAME,
    method = string.lower(req.method),
    input = req.params,
    cookies = req.cookies,
    GET = req.GET,
    POST = req.POST
  }

  setmetatable(web, {
    __index = web_methods
  })

  local _res = response.new(web.status, web.headers)

  web.set_cookie = function (_, name, value)
    _res:set_cookie(name, value)
  end

  web.delete_cookie = function (_, name, path)
    _res:delete_cookie(name, path)
  end

  return web, _res
end

function _M.run(app_module, wsapi_env)
  local handler, captures, wsapi_handler, index = dispatcher(app_module, string.lower(wsapi_env.REQUEST_METHOD), wsapi_env.PATH_INFO)
  handler = handler or app_module.not_found
  captures = captures or {}
  if wsapi_handler then
    local ok, status, headers, _res = xpcall(
      function () return handler(wsapi_env, unpack(captures)) end,
      debug.traceback
    )
    
    if ok then
      return status, headers, _res
    end
    handler, captures = app_module.server_error, { status }
  end
  
  local web, _res = make_web_object(app_module, wsapi_env)
  
  repeat
    local reparse = false
    local ok, _response = xpcall(
      function () return handler(web, unpack(captures)) end,
      function(msg) return debug.traceback(msg)end
    )
    if not ok then
      _res.status = "500 Internal Server Error"
      _res:write(app_module.server_error(web, _response))
    else
      if _response == REPARSE then
        reparse = true
        handler, captures, wsapi_handler, index = dispatcher(app_module, string.lower(wsapi_env.REQUEST_METHOD), wsapi_env.PATH_INFO, index)
        handler, captures = handler or app_module.not_found, captures or {}
        if wsapi_handler then
          error("Cannot reparse to WSAPI handler")
        end
      else
        _res.status = web.status
        _res:write(_response)
      end
    end
  until not reparse
  
  return _res:finish()
end

return _M
