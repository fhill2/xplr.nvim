local log = require'log1'

local Mappings = {
xplr = {},
previewer_xplr = {},
}

function Mappings.set_keymap(mode, lhs, rhs, opts)
table.insert(Mappings.xplr, {mode, lhs, rhs, opts})
end

function Mappings.on_previewer_set_keymap(mode, lhs, rhs, opts)
table.insert(Mappings.previewer_xplr, {mode, lhs, rhs, opts})
end



--function(self, key, value)
--log.info('mappings __index called:', self, key, value)
--end


return Mappings




-- Mappings.meta.__index = function(self, key, value)
-- log.info('mappings __index called:', self, key, value)
-- end

