local root = os.getenv("NVIM_XPLR_ROOT")

local deps_vim = "/usr/share/nvim/runtime/lua/vim/?.lua"
local deps_nvim_xplr = ("%s%s"):format(root, "/xplr/?.lua")

local deps_luaclient = ("%s%s"):format(root, "/src/lua-client/?.lua")
local deps_coxpcall = ("%s%s"):format(root, "/src/coxpcall/src/?.lua")
local cdeps_mpack = ("%s%s"):format(root, "/src/libmpack/?.so")
local cdeps_luv = ("%s%s"):format(root, "/src/luv/?.so")
package.path = package.path .. ";" .. deps_nvim_xplr .. ";" .. deps_luaclient .. ";" .. deps_coxpcall .. ";" .. deps_vim
package.cpath = package.cpath .. ";" .. cdeps_mpack .. ";" .. cdeps_luv

-- temporary check health pipe until better solution
local required_plugins = { "nvim.session", "coxpcall", "luv", "mpack" }

local out = ""
local found_deps_amt = 0
for _, req in ipairs(required_plugins) do
  local found = pcall(require, req)
  if found then
    found_deps_amt = found_deps_amt + 1
  end
  out = out .. req .. "=" .. tostring(found) .. "\n"
end

-- write required deps back to nvim
local fp = io.open("/tmp/nvim-xplr-health.fifo", "a")
fp:write(out)

-- if all deps are found, test msgpack
if found_deps_amt == #required_plugins then
  local Client = require("nvim-xplr.client")
  local client = Client:new(os.getenv("NVIM_LISTEN_ADDRESS"))
  client:exec_lua([[return require'xplr.health'._check_msgpack_health(...)]], true)
end

os.exit()
