local root = os.getenv("NVIM_XPLR_ROOT")

local deps_vim = "/usr/share/nvim/runtime/lua/vim/?.lua"
local deps_nvim_xplr = ("%s%s"):format(root, "/xplr/?.lua")

local deps_luaclient = ("%s%s"):format(root, "/xplr/src/lua-client/?.lua")
local deps_coxpcall = ("%s%s"):format(root, "/xplr/src/coxpcall/src/?.lua")
local cdeps_mpack = ("%s%s"):format(root, "/xplr/src/libmpack/?.so")
local cdeps_luv = ("%s%s"):format(root, "/xplr/src/luv/?.so")
package.path = package.path .. ";" .. deps_nvim_xplr .. ";" .. deps_luaclient .. ";" .. deps_coxpcall .. ";" .. deps_vim
package.cpath = package.cpath .. ";" .. cdeps_mpack .. ";" .. cdeps_luv

_, vim = pcall(require, "shared")
_, vim.inspect = pcall(require, "inspect")

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

local opts = client:exec_lua([[return require'xplr.actions'._host_is_ready(...)]], {})[1]

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
    help = "nvim: toggle previewer",
    messages = {
      "PopMode",
      { CallLua = "custom.nvim_preview" },
    },
  }
end

if opts.open_selection.enabled then
  xplr.fn.custom.open_selection_in_nvim = function(app)
    client:exec_lua([[return require'xplr.actions'.open_selection(...)]], app.selection)
  end

  xplr.config.modes.builtin[opts.open_selection.mode].key_bindings.on_key[opts.open_selection.key] = {
    help = "nvim: open_selection",
    messages = {
      "PopMode",
      { CallLua = "custom.open_selection_in_nvim" },
    },
  }
end

if opts.set_nvim_cwd.enabled then
  xplr.fn.custom.set_nvim_cwd = function(app)
    client:exec_lua([[return require'xplr.actions'.set_nvim_cwd(...)]], app.pwd)
  end

  xplr.config.modes.builtin[opts.set_nvim_cwd.mode].key_bindings.on_key[opts.set_nvim_cwd.key] = {
    help = "nvim: set nvim cwd to xplr",
    messages = {
      "PopMode",
      { CallLua = "custom.set_nvim_cwd" },
    },
  }
end

if opts.set_xplr_cwd.enabled then
  xplr.fn.custom.set_xplr_cwd = function(app)
    local cwd = client:exec_lua([[return require'xplr.actions'.get_nvim_cwd(...)]], {})[1]
    return { { ChangeDirectory = cwd } }
  end

  xplr.config.modes.builtin[opts.set_xplr_cwd.mode].key_bindings.on_key[opts.set_xplr_cwd.key] = {
    help = "nvim: set xplr cwd to nvim",
    messages = {
      "PopMode",
      { CallLua = "custom.set_xplr_cwd" },
    },
  }
end
