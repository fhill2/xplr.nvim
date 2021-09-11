local utils = require("xplr.utils")
local Job = require("plenary.job")
local uv = vim.loop
local root = utils.get_root()
local health = {}

local health_start = vim.fn["health#report_start"]
local health_ok = vim.fn["health#report_ok"]
local health_warn = vim.fn["health#report_warn"]
local health_error = vim.fn["health#report_error"]
local health_info = vim.fn["health#report_info"]


local function lualib_installed(lib_name)
  local res, _ = pcall(require, lib_name)
  return res
end

local function check_nvim_health()
  local nvim_deps = {
    { lib = "plenary", optional = false },
    { lib = "nui.popup", optional = false},
    { lib = "telescope", optional = true, info = "Telescope needed for file preview (optional)"}
  }

  for _, plugin in ipairs(nvim_deps) do
    if lualib_installed(plugin.lib) then
      health_ok(("%s installed"):format(plugin.lib))
    else
      local lib_not_installed = plugin.lib .. " not found."
      if plugin.optional then
        health_warn(("%s %s"):format(lib_not_installed, plugin.info))
      else
        health_error(lib_not_installed .. ' (required)')
      end
    end
  end

end


-------- check xplr health

local should_exit = false
local xplr_deps = {}
local msgpack = {}
local xplr_id
local health_fifo = '/tmp/nvim-xplr-health.fifo'


local function generate_xplr_deps_msg()
  local failed_msg = {
    nvim_session = { { "error", "lua-client not installed" }},
    coxpcall = { { "error", "coxpcall not installed" } },
    luv = {
      { "error", "luv not installed or built - can't find luv.so" },
      { "info", ("build libmpack with: cd %s/xplr/src/libmpack && make"):format(root) },
    },
    mpack = {
      { "error", "libmpack not installed or built - can't find mpack.so" },
      { "info", ("build luv with: cd %s/xplr/src/luv && make"):format(root) },
    },
  }

  for _, v in ipairs(xplr_deps) do
    if v.found then
      health_ok(v.lib .. " installed")
    else
      vim.tbl_map(function(msg)

        vim.fn["health#report_" .. msg[1]](msg[2])
      end, failed_msg[v.lib])
    end
  end
end

local function check_xplr_health()
  local xplr_out = ""

  local function tobool(str)
    if type(str) == "string" then
      if str == "true" then
        return true
      elseif str == "false" then
        return false
      end
    end
  end

  local xplr_deps_check_completed = vim.schedule_wrap(function()
    local data = vim.split(xplr_out, "\n")

    for i, required in ipairs(data) do
      if required ~= "" then
        local lib, found = required:match("^(.*)=(.*)$")
        local found = tobool(found)
        if found then
          table.insert(xplr_deps, { lib = lib:gsub("%.", "_"), found = found })
        elseif not found then
          should_exit = true
          table.insert(xplr_deps, { lib = lib:gsub("%.", "_"), found = found })
        end
      else
        table.remove(data, i)
      end
    end
  end)

  os.execute(("[ ! -p '%s' ] && mkfifo '%s'"):format(health_fifo, health_fifo))

  local cmd = string.format([[%s -c 'xplr -C "%s"']], vim.o.shell, utils.get_init_health())

  xplr_id = vim.fn.jobstart(cmd, {
    env = { NVIM_XPLR_ROOT = utils.get_root() },
    on_exit = function()
    end,
  })

  local stdout = uv.new_pipe(false)

  local handle, pid = uv.spawn("cat", {
    args = { "/tmp/nvim-xplr-health.fifo" },
    cwd = "/tmp",
    stdio = { nil, stdout, nil },
  }, function(code, signal)
    xplr_deps_check_completed()
  end)

  stdout:read_start(function(err, data)
    if data then
      xplr_out = xplr_out .. data
    end
  end)
end

function health._check_msgpack_health(success)
  if success then
    msgpack = { "ok", "xplr msgpack client ready" }
  end
end



function health.check_health()
  local health_start = vim.fn["health#report_start"]

  health_start("Checking for nvim required plugins")

  check_nvim_health()

  if not utils.check_git_submodule(root) then
    health_warn("msgpack client dependencies not installed")
    health_info("to install:")
    health_info("cd " .. root)
    health_info([[git submodule update --init --recursive && cd xplr/src/luv && make && cd ../libmpack && make]])
    return
  end

  check_xplr_health()

  health_start("Checking xplr required dependencies")
  vim.wait(1000, function()
    if #xplr_deps == 4 then
      return true
    end
  end, 50, false)

  generate_xplr_deps_msg()
  if should_exit then
    return
  end

  health_start("testing Msgpack client - Timeout: 1s")

  vim.wait(1000, function()
    if not vim.tbl_isempty(msgpack) then
      return true
    end
  end, 50, false)
  if not vim.tbl_isempty(msgpack) then
    vim.fn["health#report_" .. msgpack[1]](msgpack[2])
  else
    vim.fn["health#report_error"]("nvim: no msgpack received")
  end

local r = uv.fs_stat(health_fifo)
if r ~= nil then uv.fs_unlink(health_fifo) end
end

return health
