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

local optional_dependencies = {
      {
        name = "luarocks",
        url = "https://github.com/luarocks/luarocks",
        optional = true,
      },
}

--   {
--     finder_name = "live-grep",
--     package = {
--       {
--         name = "rg",
--         url = "[BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep)",
--         optional = false,
--       },
--     },
--   },
--   {
--     finder_name = "find-files",
--     package = {
--       {
--         name = "fd",
--         url = "[sharkdp/fd](https://github.com/sharkdp/fd)",
--         optional = true,
--       },
--     },
--   },
-- }

local required_plugins = {
  { lib = "popup", optional = true },
  { lib = "plenary", optional = false },
  { lib = "telescope", optional = true },
  {
    lib = "nvim-treesitter",
    optional = true,
    info = "",
  },
  { lib = "nui", optional = false }
}

local check_binary_installed = function(package)
  local file_extension = is_win and ".exe" or ""
  local filename = package.name .. file_extension
  if fn.executable(filename) == 0 then
    return
  else
    local handle = io.popen(filename .. " --version")
    local binary_version = handle:read "*a"
    handle:close()
    return true, binary_version
  end
end

local function lualib_installed(lib_name)
  local res, _ = pcall(require, lib_name)
  return res
end

-- local function get_healthcheck(ext_name)
--   local has_check, check = pcall(require, "telescope.extensions"[ext_name]['health'])
--     if(has_check) then return check end
--   return
-- end

local function check_luarocks_installed_packages()

end

local M = {}

M.check_health = function()
  -- Required lua libs
  health_start "Checking for required plugins"
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

  -- external dependencies
  -- TODO: only perform checks if user has enabled dependency in their config
  health_start "Checking external dependencies"

    for _, package in ipairs(optional_dependencies) do
      local installed, version = check_binary_installed(package)

      if package.name == 'luarocks' and not installed then
        -- local err_msg = ("%s: not found."):format(package.name)
        local hererocks_url = 'https://github.com/luarocks/hererocks'
        local hererocks_url_wget = 'https://raw.githubusercontent.com/luarocks/hererocks/latest/hererocks.py'
    
          health_error("No luarocks found in PATH. Lua msgpack client needed for opening files in nvim (installed with luarocks). You can install luarocks with Packer.nvim, or manually (I would recommend Hererocks) %s %s wget: %s"):format(package.url, hererocks_url, hererocks_url_wget)

      
       
      elseif package.name == 'luarocks' and installed then
        
      local luarocks_pkgs_installed = check_luarocks_installed_pkgs()
      if not luarocks_pkgs_installed then
      local nvim_client_url_luarocks = 'https://luarocks.org/modules/justinmk/nvim-client'
      local nvim_client_url_github = "https://github.com/neovim/lua-client"
        health_error("luarocks found in PATH but Lua msgpack client not installed. luarocks install nvim_client --> for opening files within nvim")
      else
    -- local eol = version:find "\n"
  --       health_ok(("%s: found %s"):format(package.name, version:sub(0, eol - 1) or "(unknown version)"))
        end
            end

  

  end

end

return M
