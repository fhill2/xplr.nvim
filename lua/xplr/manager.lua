local Popup = require'nui.popup'
local utils = require'xplr.utils'
local log = require'log1'
local config = require'xplr.config'
local previewer = require'xplr.previewer'

local manager = {
-- popup = {},
-- previewer = { 
--   ui = {},
--   job = {},
--}
}


function manager.spawn()
manager.popup = Popup(config.ui)
end

function manager.open(opts)
if not manager.popup then 
  log.info('table was empty')
  manager.spawn() end
 -- log.info(ui.state)
  log.info(popup)
  manager.popup:mount()


-- vim.defer_fn(function()
 -- vim.api.nvim_buf_call(ui.popup.bufnr, function()
 --  end)
-- log.info(manager.popup)
 vim.api.nvim_set_current_win(manager.popup.winid)

 vim.fn.termopen([[zsh -c 'xplr']], {
 -- detach = 1,
  cwd = '/home/f1',
  env = { NVIM_XPLR = 1 },
})
vim.cmd('startinsert')
end

function manager.start_preview()
  

  if not manager.previewer then  
  manager.previewer = previewer:new({ fifo_path = config.previewer_fifo_path }):start()
  end
-- previewer open()
end



return manager
