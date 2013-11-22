-----------------------------------------------------------------------------
-- Xavante Orbit pages handler
--
-- Author: Fabio Mascarenhas
--
-----------------------------------------------------------------------------

local xavante = require "wsapi.xavante"
local common = require "wsapi.common"

local _M = _M or {}
if setfenv then
  setfenv(1, _M) -- for 5.1
else
  _ENV = _M -- for 5.2
end

-------------------------------------------------------------------------------
-- Returns the Orbit Pages handler
-------------------------------------------------------------------------------
function makeHandler (diskpath, params)
  params = setmetatable({
    modname = params.modname or "orbit.pages" 
  }, {
    __index = params or {}
  })
  
  local op_loader = common.make_isolated_launcher(params)
  return xavante.makeHandler(op_loader, nil, diskpath)
end

return _M
