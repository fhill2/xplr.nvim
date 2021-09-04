local utils = {}
local uv = vim.loop

function utils.defaults(v, default_value)
  return type(v) == "nil" and default_value or v
end

-- simplified from nui.utils without conversion to decimal
function utils.parse_number_input(v)
  local parsed = {}

  parsed.is_percentage = type(v) == "string" and string.sub(v, -1) == "%"

  if parsed.is_percentage then
    parsed.value = tonumber(string.sub(v, 1, #v - 1))
  else
    parsed.value = tonumber(v)
  end

  return parsed
end

-- xplr only utils

-- extracts all absolute paths from selection table received from xplr
function utils.get_absolute_paths(selection)
  local filepaths = {}
  for k, v in ipairs(selection) do
    table.insert(filepaths, v.absolute_path)
  end
  return filepaths
end

function utils.get_root()
  -- removed cause nvim_get_option is not "fast", might add back in
  -- get path to nvim_xplr
  --local rtp = vim.split(vim.api.nvim_get_option("rtp"), ",")  
  -- for _, path in ipairs(rtp) do
  --   if path:match("xplr.nvim$") then
  --     return path
  --   end
  -- end
-- if calling this at startup (workaround for toggleterm config)
return debug.getinfo(1).source:match('@(.*/xplr.nvim)/')
end

function utils.get_init()
  return ("%s/xplr/init.lua"):format(utils.get_root())
end

function utils.get_init_health()
  return ("%s/xplr/init-health.lua"):format(utils.get_root())
end


utils.check_git_submodule = function(root)
  local scan_result = {}
  local fd = uv.fs_scandir(root .. "/xplr/src/luv")
  if fd then
    while true do
      local name, typ = uv.fs_scandir_next(fd)
      if name == nil then
        break
      end
      table.insert(scan_result, name)
    end
  end
  if not vim.tbl_isempty(scan_result) then
    return true
  else
    return false
  end
end


return utils
