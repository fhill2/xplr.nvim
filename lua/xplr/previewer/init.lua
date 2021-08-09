-- wrapper around Telescope previewers that provides switching previewer based on file extension of xplr hovered file
local previewers = require'telescope.previewers'
local Popup = require'nui.popup'
local Job = require'plenary.job'
local config = require'xplr.config'
--local job = require'xplr.previewer.job'
local log = require'log1'

local Previewer = {}
Previewer.__index = Previewer


 



function Previewer:new(opts)

  return setmetatable({
  ui = Popup(vim.deepcopy(config.previewer.ui or config.xplr.ui)), -- pass xplr opts then change w set_position
  file = previewers.vim_buffer_cat.new({}),
  xplr_winid = opts.xplr_winid
  }, Previewer)
end


function Previewer:start(opts)
  opts = opts or {}

   log.info('previewer job started')


local on_output = vim.schedule_wrap(function(_, line, _)
    if not line or line == "" then return end
    -- log.info('===== NEW PREVIEW =====')
    -- log.info('at on_output:', line)
    -- log.info(line)
    self.file:preview({ path = line }, {
    preview_win = self.ui.winid, prompt_win = self.xplr_winid
    }) 
 end)
 

self.job = Job:new({
  command = 'cat',
  args = { opts.fifo_path },
  enable_recording = false,
  on_stdout = on_output,
  on_stderr = on_output,
  })
self.job:start()
end

function Previewer:stop(opts)
self.job:shutdown()
end

-- function Previewer:open_preview_window()


-- log.info('open preview window called!!')
-- -- TODO: change when when nui.nvim has split()
-- --

-- --fix for terminal nui floating windows
-- local relative
-- if config.xplr.ui.relative == 'win' then
-- relative = { type = 'win', winid = xplr.ui.popup_state.parent_winid }
-- else
-- relative = config.xplr.ui.relative
-- end


-- xplr.previewer.ui:mount()


-- if not config.previewer.split and config.previewer.ui then
--   log.info('picked this')
--   log.info(config.previewer.ui)
--   -- still need set position because of terminal nui fix
-- -- xplr.previewer.ui:set_position({row = config.previewer.ui.position.row, col = config.previewer.ui.position.col }, { type = 'win', winid = xplr.ui.popup_state.parent_winid }
-- -- )
-- --xplr.previewer.ui:set_size(config.ui.previewer.size)
-- else
-- local split_percent = config.previewer.split_percent

-- log.info('previewer mount()')

-- local x_win = vim.api.nvim_win_get_config(xplr.ui.winid)
-- local p_win = vim.deepcopy(x_win)

-- if type(x_win.col) == 'table' then x_win.col = x_win.col[false] end
-- if type(p_win.col) == 'table' then p_win.col = p_win.col[false] end
-- if type(x_win.row) == 'table' then x_win.row = x_win.row[false] end
-- if type(p_win.row) == 'table' then p_win.row = p_win.row[false] end


-- x_win.width = math.floor(x_win.width * split_percent)
-- p_win.width = math.floor(p_win.width * (1 - split_percent))
-- p_win.col = math.floor(x_win.col + x_win.width) + 2
-- p_win.height = x_win.height
-- p_win.row = x_win.row + 1

-- vim.api.nvim_win_set_config(xplr.ui.winid, x_win)



-- xplr.previewer.ui:set_position({ row = p_win.row, col = p_win.col - 2}, relative)
-- xplr.previewer.ui:set_size({ width = p_win.width, height = p_win.height - 2})
-- end

-- -- setup autocmds
-- if xplr.ui.bufnr then
-- vim.cmd([[autocmd WinClosed <buffer=]] .. xplr.ui.bufnr .. [[> ++nested ++once :silent lua require('xplr').close()]])
-- end

-- if xplr.previewer.ui.bufnr then
--   log.info('PREVIEWER AUTOCMD RAN')
-- vim.cmd([[autocmd WinClosed <buffer=]] .. xplr.previewer.ui.bufnr .. [[> ++nested ++once :silent lua require('xplr').close()]])
-- end



-- end


-- function Previewer:preview(opts)
-- self.file:preview({ path = }. )
-- end

return Previewer


