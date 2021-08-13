-- https://github.com/nvim-telescope/telescope.nvim/pull/1066/files
-- thank you @sunjon
local fn = vim.fn
local extension_info = require("telescope").extensions
local is_win = vim.api.nvim_call_function("has", { "win32" }) == 1

local health_start = vim.fn["health#report_start"]
local health_ok = vim.fn["health#report_ok"]
local health_warn = vim.fn["health#report_warn"]
local health_error = vim.fn["health#report_error"]
local health_info = vim.fn["health#report_info"]

local hererocks_url = "https://github.com/luarocks/hererocks"
local hererocks_url_wget = "https://raw.githubusercontent.com/luarocks/hererocks/latest/hererocks.py"
local nvim_client_url_luarocks = "https://luarocks.org/modules/justinmk/nvim-client"
local nvim_client_url_github = "https://github.com/neovim/lua-client"


local optional_dependencies = {
  {
    name = "luarocks",
    url = "https://github.com/luarocks/luarocks",
    optional = true,
  },
}

local required_plugins = {
  { lib = "popup", optional = true },
  { lib = "plenary", optional = false },
  { lib = "telescope", optional = true },
  {
    lib = "nvim-treesitter",
    optional = true,
    info = "",
  },
  { lib = "nui.popup", optional = false },
}

local check_binary_installed = function(package)
  local file_extension = is_win and ".exe" or ""
  local filename = package.name .. file_extension
  if fn.executable(filename) == 0 then
    return
  else
    local handle = io.popen(filename .. " --version")
    local binary_version = handle:read("*a")
    handle:close()
    return true, binary_version
  end
end

local function lualib_installed(lib_name)
  local res, _ = pcall(require, lib_name)
  return res
end

local function check_luarocks_installed_packages()
  local handle = io.popen("luarocks list --porcelain")
  local output = handle:read("*a")
  handle:close()
  local packages = vim.split(output, "[\r]?\n")

  local xplr_required_packages = { "coxpcall", "luv", "mpack", "nvim-client" }
  local xplr_installed_packages = {}
  local xplr_uninstalled_packages = {}
  local luarocks_installed_packages = {}

  for _, package in ipairs(packages) do
    local package = vim.split(package, "\t")
    local name = package[1]
    local installed = package[3] == "installed"

    if installed then
      table.insert(luarocks_installed_packages, name)
    end
  end

  -- find installed required packages
  for _, req_pkg in ipairs(xplr_required_packages) do
    if vim.tbl_contains(luarocks_installed_packages, req_pkg) then
      table.insert(xplr_installed_packages, req_pkg)
    end
  end

  -- find uninstalled required packages
  for _, req_pkg in ipairs(xplr_required_packages) do
    if not vim.tbl_contains(xplr_installed_packages, req_pkg) then
      table.insert(xplr_uninstalled_packages, req_pkg)
    end
  end

  if vim.tbl_isempty(xplr_uninstalled_packages) then
    return true, "Luarocks packages are installed"
  else
    local missing = ""
    for _, name  in ipairs(xplr_uninstalled_packages) do
      missing = missing .. name .. " "
    end
    return false, missing
  end
end

local M = {}

M.check_health = function()
  -- Required lua libs
  health_start("Checking for required nvim plugins")
  for _, plugin in ipairs(required_plugins) do
    if lualib_installed(plugin.lib) then
      health_ok(plugin.lib .. " installed.")
    else
      local lib_not_installed = plugin.lib .. " not found."
      if plugin.optional then
        health_warn(("%s %s"):format(lib_not_installed, plugin.info))
      else
        health_error(lib_not_installed)
      end
    end
  end

  health_start("Checking luarocks installation")

  for _, package in ipairs(optional_dependencies) do
    local installed, version = check_binary_installed(package)

    if package.name == "luarocks" and not installed then
      health_error("No luarocks found on PATH.")
      health_info("Lua msgpack client (installed with luarocks) needed for opening xplr selection in nvim.")

      health_info(
        "If you use Packer.nvim as your plugin manager, you can install Luarocks with it (uses Hererocks to install)"
      )
      health_info(("Luarocks: %s"):format(package.url))
      health_info(("Hererocks: %s"):format(hererocks_url))
      health_info(("Hererocks wget: %s"):format(hererocks_url_wget))
      else
      health_ok("luarocks found on PATH")
      end

      if package.name == "luarocks" and installed then
      local ok, status = check_luarocks_installed_packages()
      if not ok then
        health_error(("missing luarocks packages for opening files in nvim: %s"):format(status))
        health_info("if using luarocks install these with: luarocks install nvim-client")
             else
        health_ok("luarocks and required packages installed")
      end

    end
  end
end

return M
