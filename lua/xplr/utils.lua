local utils = {}

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


return utils
