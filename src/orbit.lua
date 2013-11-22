local request = require "wsapi.request"
local response = require "wsapi.response"
local util = require "wsapi.util"

local _M = _M or {}

_M._NAME = "orbit"
_M._VERSION = "2.2.0"
_M._COPYRIGHT = "Copyright (C) 2007-2010 Kepler Project"
_M._DESCRIPTION = "MVC Web Development for the Kepler platform"

local REPARSE = {}

_M.mime_types = {
  ez = "application/andrew-inset",
  atom = "application/atom+xml",
  hqx = "application/mac-binhex40",
  cpt = "application/mac-compactpro",
  mathml = "application/mathml+xml",
  doc = "application/msword",
  bin = "application/octet-stream",
  dms = "application/octet-stream",
  lha = "application/octet-stream",
  lzh = "application/octet-stream",
  exe = "application/octet-stream",
  class = "application/octet-stream",
  so = "application/octet-stream",
  dll = "application/octet-stream",
  dmg = "application/octet-stream",
  oda = "application/oda",
  ogg = "application/ogg",
  pdf = "application/pdf",
  ai = "application/postscript",
  eps = "application/postscript",
  ps = "application/postscript",
  rdf = "application/rdf+xml",
  smi = "application/smil",
  smil = "application/smil",
  gram = "application/srgs",
  grxml = "application/srgs+xml",
  mif = "application/vnd.mif",
  xul = "application/vnd.mozilla.xul+xml",
  xls = "application/vnd.ms-excel",
  ppt = "application/vnd.ms-powerpoint",
  rm = "application/vnd.rn-realmedia",
  wbxml = "application/vnd.wap.wbxml",
  wmlc = "application/vnd.wap.wmlc",
  wmlsc = "application/vnd.wap.wmlscriptc",
  vxml = "application/voicexml+xml",
  bcpio = "application/x-bcpio",
  vcd = "application/x-cdlink",
  pgn = "application/x-chess-pgn",
  cpio = "application/x-cpio",
  csh = "application/x-csh",
  dcr = "application/x-director",
  dir = "application/x-director",
  dxr = "application/x-director",
  dvi = "application/x-dvi",
  spl = "application/x-futuresplash",
  gtar = "application/x-gtar",
  hdf = "application/x-hdf",
  xhtml = "application/xhtml+xml",
  xht = "application/xhtml+xml",
  js = "application/x-javascript",
  skp = "application/x-koan",
  skd = "application/x-koan",
  skt = "application/x-koan",
  skm = "application/x-koan",
  latex = "application/x-latex",
  xml = "application/xml",
  xsl = "application/xml",
  dtd = "application/xml-dtd",
  nc = "application/x-netcdf",
  cdf = "application/x-netcdf",
  sh = "application/x-sh",
  shar = "application/x-shar",
  swf = "application/x-shockwave-flash",
  xslt = "application/xslt+xml",
  sit = "application/x-stuffit",
  sv4cpio = "application/x-sv4cpio",
  sv4crc = "application/x-sv4crc",
  tar = "application/x-tar",
  tcl = "application/x-tcl",
  tex = "application/x-tex",
  texinfo = "application/x-texinfo",
  texi = "application/x-texinfo",
  t = "application/x-troff",
  tr = "application/x-troff",
  roff = "application/x-troff",
  man = "application/x-troff-man",
  me = "application/x-troff-me",
  ms = "application/x-troff-ms",
  ustar = "application/x-ustar",
  src = "application/x-wais-source",
  zip = "application/zip",
  au = "audio/basic",
  snd = "audio/basic",
  mid = "audio/midi",
  midi = "audio/midi",
  kar = "audio/midi",
  mpga = "audio/mpeg",
  mp2 = "audio/mpeg",
  mp3 = "audio/mpeg",
  aif = "audio/x-aiff",
  aiff = "audio/x-aiff",
  aifc = "audio/x-aiff",
  m3u = "audio/x-mpegurl",
  ram = "audio/x-pn-realaudio",
  ra = "audio/x-pn-realaudio",
  wav = "audio/x-wav",
  pdb = "chemical/x-pdb",
  xyz = "chemical/x-xyz",
  bmp = "image/bmp",
  cgm = "image/cgm",
  gif = "image/gif",
  ief = "image/ief",
  jpeg = "image/jpeg",
  jpg = "image/jpeg",
  jpe = "image/jpeg",
  png = "image/png",
  svg = "image/svg+xml",
  svgz = "image/svg+xml",
  tiff = "image/tiff",
  tif = "image/tiff",
  djvu = "image/vnd.djvu",
  djv = "image/vnd.djvu",
  wbmp = "image/vnd.wap.wbmp",
  ras = "image/x-cmu-raster",
  ico = "image/x-icon",
  pnm = "image/x-portable-anymap",
  pbm = "image/x-portable-bitmap",
  pgm = "image/x-portable-graymap",
  ppm = "image/x-portable-pixmap",
  rgb = "image/x-rgb",
  xbm = "image/x-xbitmap",
  xpm = "image/x-xpixmap",
  xwd = "image/x-xwindowdump",
  igs = "model/iges",
  iges = "model/iges",
  msh = "model/mesh",
  mesh = "model/mesh",
  silo = "model/mesh",
  wrl = "model/vrml",
  vrml = "model/vrml",
  ics = "text/calendar",
  ifb = "text/calendar",
  css = "text/css",
  html = "text/html",
  htm = "text/html",
  asc = "text/plain",
  txt = "text/plain",
  rtx = "text/richtext",
  rtf = "text/rtf",
  sgml = "text/sgml",
  sgm = "text/sgml",
  tsv = "text/tab-separated-values",
  wml = "text/vnd.wap.wml",
  wmls = "text/vnd.wap.wmlscript",
  etx = "text/x-setext",
  mpeg = "video/mpeg",
  mpg = "video/mpeg",
  mpe = "video/mpeg",
  qt = "video/quicktime",
  mov = "video/quicktime",
  mxu = "video/vnd.mpegurl",
  avi = "video/x-msvideo",
  movie = "video/x-sgi-movie",
  ice = "x-conference/x-cooltalk",
  rss = "application/rss+xml",
  atom = "application/atom+xml",
  json = "application/json"
}

_M.app_module_methods = {}
local app_module_methods = _M.app_module_methods

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

local function serve_file(app_module)
  return function (web)
    return app_module:serve_static(web, web.real_path .. web.path_info)
  end
end

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

function app_module_methods.dispatch_static(app_module, ...)
  app_module:dispatch_get(serve_file(app_module), ...)
end

function app_module_methods.serve_static(app_module, web, filename)
  local ext = string.match(filename, "%.([^%.]+)$")
  if app_module.use_xsendfile then
    web.headers["Content-Type"] = _M.mime_types[ext] or "application/octet-stream"
    web.headers["X-Sendfile"] = filename
    return "xsendfile"
  end
  
  local file = io.open(filename, "rb")
  if not file then
    return app_module.not_found(web)
  end
    
  web.headers["Content-Type"] = _M.mime_types[ext] or "application/octet-stream"
  local contents = file:read("*a")
  file:close()
  return contents
end

local function newtag(name)

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


function _M.htmlify(app_module, ...)

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

app_module_methods.htmlify = _M.htmlify

function app_module_methods.model(app_module, ...)
  if app_module.mapper.default then
    local table_prefix = (app_module._NAME and app_module._NAME .. "_") or ""
      if not orbit.model then
        require "orbit.model"
      end
      app_module.mapper = orbit.model.new(app_module.mapper.table_prefix or table_prefix, app_module.mapper.conn, app_module.mapper.driver, app_module.mapper.logging)
   end
   return app_module.mapper:new(...)
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
    local ok, status, headers, _res = xpcall(function ()
      return handler(wsapi_env, unpack(captures))
    end, debug.traceback)
    
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
