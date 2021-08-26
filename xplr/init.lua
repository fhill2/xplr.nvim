local root = "/home/f1/.local/share/nvim/site/pack/packer/start/xplr.nvim"

local deps_vim = "/usr/share/nvim/runtime/lua/vim/?.lua"
local deps_nvim_xplr = ("%s%s"):format(root, "/xplr/?.lua")

local deps_luaclient = ("%s%s"):format(root, "/src/lua-client/?.lua")
local deps_coxpcall = ("%s%s"):format(root, "/src/coxpcall/src/?.lua")
local cdeps_mpack = ("%s%s"):format(root, "/src/libmpack/?.so")
local cdeps_luv = ("%s%s"):format(root, "/src/luv/?.so")
package.path = package.path .. ";" .. deps_nvim_xplr .. ";" .. deps_luaclient .. ";" .. deps_coxpcall .. ";" .. deps_vim
package.cpath = package.cpath .. ";" .. cdeps_mpack .. ";" .. cdeps_luv

vim = require("shared")
vim.inspect = require("inspect")

local Client = require("nvim-xplr.client")
local client = Client:new(os.getenv("NVIM_LISTEN_ADDRESS"))

client:request(
  "nvim_set_client_info",
  "xplr",
  {},
  "remote",
  {},
  { website = "https://github.com/neovim/lua-client", license = "Apache License 2.0" }
)

local opts = client:exec_lua([[return require'xplr.actions'._host_is_ready(...)]], {})[3][1]


if opts.preview.enabled then
  os.execute("[ ! -p '" .. opts.preview.fifo_path .. "' ] && mkfifo '" .. opts.preview.fifo_path .. "'")

  xplr.fn.custom.nvim_preview = function(app)
    if enabled then
      enabled = false
      client:exec_lua(
        [[return require'xplr.manager'._toggle_preview(...)]],
        { fifo_path = opts.preview.fifo_path, enabled = enabled }
      )
      messages = { "StopFifo" }
    else
      enabled = true
      client:exec_lua(
        [[return require'xplr.manager'._toggle_preview(...)]],
        { fifo_path = opts.preview.fifo_path, enabled = enabled }
      )
      messages = {
        { StartFifo = opts.preview.fifo_path },
      }
    end
    return messages
  end

  xplr.config.modes.builtin[opts.preview.mode].key_bindings.on_key[opts.preview.key] = {
    help = "toggle nvim preview",
    messages = {
      "PopMode",
      { CallLua = "custom.nvim_preview" },
    },
  }
end

if opts.open_selection.enabled then
  xplr.fn.custom.nvim_open_selection = function(app)
    client:exec_lua([[return require'xplr.actions'.open_selection(...)]], app.selection)
  end

  xplr.config.modes.builtin[opts.open_selection.mode].key_bindings.on_key[opts.open_selection.key] = {
    help = "nvim open_selection",
    messages = {
      "PopMode",
      { CallLua = "custom.nvim_open_selection" },
    },
  }
end
