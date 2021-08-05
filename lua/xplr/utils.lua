local utils = {}

function utils.defaults(v, default_value)
  return type(v) == "nil" and default_value or v
end

return utils
