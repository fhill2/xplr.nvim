local xplr = {}
local log = require'log1'
local config = require'xplr.config'
local manager = require'xplr.manager'


function xplr.selection(sel)
print(sel)
log.info(sel)
end

function xplr.start_preview()

end

function xplr.open(opts)
manager.open(opts)
end


function xplr.setup(opts)
config.setup(opts)
end

return xplr
