local Session = require("nvim.session")
local SocketStream = require("nvim.socket_stream")

local Client = {}
Client.__index = Client

function Client:new(socket_path)
  local stream = SocketStream.open(socket_path)
  return setmetatable({
    _session = Session.new(stream),
  }, Client)
end

-- convert userdata and function references to strings before sending lua tables over msgpack
local function deepnil(orig) end
deepnil = (function()
  local function _id(v)
    return v
  end

  local deepnil_funcs = {
    table = function(orig)
      local copy = {}

      for k, v in pairs(orig) do
        copy[deepnil(k)] = deepnil(v)
      end
      return copy
    end,
    number = _id,
    string = _id,
    ["nil"] = _id,
    boolean = _id,
    ["function"] = function()
      return "<function>"
    end,
    ["userdata"] = function()
      return "<userdata>"
    end,
  }

  return function(orig)
    local f = deepnil_funcs[type(orig)]
    if f then
      return f(orig)
    else
      --error("Cannot deepcopy object of type "..type(orig))
    end
  end
end)()

function Client:exec_lua(code, t)
  self._session:request("nvim_exec_lua", code, { deepnil(t) })
  if #self._session._pending_messages > 0 then
    return self._session:next_message()[3]
  end
end
--end

function Client:request(method, ...)
  return self._session:request(method, ...)
end

-- Executes an ex-command. VimL errors manifest as client (lua) errors, but
-- v:errmsg will not be updated.
function Client:command(cmd)
  self._session:request("nvim_command", cmd)
end

return Client
