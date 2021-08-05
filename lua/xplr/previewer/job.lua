-- starts async job to read xplr pipe and sends data to previewer 
local Job = require('plenary.job')

local Previewer = {}

-- simplified telescope/finders
function Previewer:new(opts)
  opts = opts or {}

  return setmetatable({
  fifo_path = opts.fifo_path
  }, self)
end


function Previewer:start(opts)



 local on_output = function(_, line, _)
    if not line or line == "" then
      return
    end
    process_result(line)
  end




self.job = Job:new {
    command = opts.command,
    args = opts.args,
    cwd = opts.fifo_path,
    enable_recording = false,

    on_stdout = on_output,
    on_stderr = on_output,

    on_exit = function()
      process_complete()
    end,
  }

end





return Previewer
