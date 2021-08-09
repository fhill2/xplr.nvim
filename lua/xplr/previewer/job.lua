-- starts async job to read xplr pipe and sends data to previewer 
local plenary_job = require('plenary.job')
local log = require'log1'

local Job = {}
Job.__index = Job

-- simplified telescope/finders
function Job:new(opts)
  opts = opts or {}

  return setmetatable({}, Job)
end


function Job:start(opts)



 local on_output = function(_, line, _)
    if not line or line == "" then
      return
    end
    log.info(line)
    process_result(line)
  end




self.job = plenary_job:new {
    command = opts.command,
    args = opts.args,
    cwd = opts.cwd,
    enable_recording = false,

    on_stdout = on_output,
    on_stderr = on_output,

    on_exit = function()
      process_complete()
    end,
  }

end





return Job
