-- wrapper around Telescope previewers that provides switching previewer based on file extension of xplr hovered file
local previewers = require'telescope.previewers'

local previewer = {}

function previewer:new(opts)

  return setmetatable({
  job = job:new({ fifo_path = '/tmp'}),
  previewer = previewers
  }, self)
end


function previewer:open()
  -- if not job is started then
  self.job:start()
end



return previewer
