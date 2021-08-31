local Popup = require("nui.popup")
local utils = require("xplr.utils")
local config = require("xplr.config")
local Previewer = require("xplr.previewer")
local nui_utils = require("nui.utils")
local mappings = require("xplr.mappings")

local manager = {}
manager.state = {
  --ui = {}
  -- previewer = {
  --   ui = {},
  --   job = {},
  --}
  -- job = int
}

local xplr = manager.state

function manager.toggle()
  if not xplr.ui then
    manager.open()
    return
  end

  if xplr.ui.winid then
    manager.close()
  else
    manager.open()
  end
end

function manager.close()
  if not xplr.ui then
    return
  end

  if xplr.previewer then
    manager._close_preview_window()
  end

  xplr.ui:unmount()
  xplr.parent_winnr = nil
end

function manager.open(opts)
  opts = opts or {}

  if not xplr.ui then
    xplr.ui = Popup(config.ui)
  end

  if xplr.ui.winid then
    manager.focus()
    return
  end

  local cd = opts.cwd or vim.fn.getcwd()

  -- parent_winnr stays the same until close()
  xplr.parent_winnr = vim.api.nvim_get_current_win()
  -- last_editor_winnr is changed by focus()
  xplr.last_editor_winnr = vim.api.nvim_get_current_win()

  xplr.ui:mount()

  -- setup keymaps on xplr window
  for _, keymap in ipairs(mappings.xplr) do
    vim.api.nvim_buf_set_keymap(xplr.ui.bufnr, keymap[1], keymap[2], keymap[3], keymap[4])
  end

  vim.api.nvim_set_current_win(xplr.ui.winid)

  local cmd = string.format([[%s -c 'xplr -C "%s" "%s"']], vim.o.shell, utils.get_init(), cd)
  vim.fn.termopen(cmd, {
    env = { NVIM_XPLR_ROOT = utils.get_root() },
  })

  vim.cmd("startinsert")
end

-- only meant to be called from xplr msgpack
function manager._toggle_preview(opts)
  opts = opts or {}

  if opts.enabled then
    -- start fifo listen
    manager._start_preview({ fifo_path = opts.fifo_path })
  else
    -- stop fifo listen
    manager._stop_preview({ fifo_path = opts.fifo_path })
  end
end

function manager._start_preview(opts)
  opts = opts or {}

  if xplr.ui then
  opts.xplr_winid = xplr.ui.winid
  else
  -- opened from a neovim terminal
  opts.xplr_winid = vim.api.nvim_get_current_win()
end

  if not xplr.previewer then
    xplr.previewer = Previewer:new(opts)
  end

  manager._open_preview_window()
  xplr.previewer:start(opts)
end

function manager._stop_preview(opts)
  manager._close_preview_window() --end
  vim.defer_fn(function()
    xplr.previewer:stop(opts)
  end, 0)
end

function manager.toggle_preview_window()
  if not xplr.previewer then
    return
  end

  if not xplr.previewer.ui.winid then
    manager._open_preview_window()
  else
    manager._close_preview_window()
  end
end

function manager._open_preview_window()
  -- TODO: change when when nui.nvim has split()
  --

  --fix for terminal nui floating windows
  local relative
  if config.ui.relative == "win" then
    relative = { type = "win", winid = xplr.parent_winnr }
  else
    relative = config.ui.relative
  end

  xplr.previewer.ui:mount()

  if xplr.ui and config.previewer.split then
    local split_percent = config.previewer.split_percent

    local x_win = vim.deepcopy(vim.api.nvim_win_get_config(xplr.ui.winid))
    local p_win = vim.deepcopy(x_win)

    if type(x_win.col) == "table" then
      x_win.col = x_win.col[false]
    end
    if type(p_win.col) == "table" then
      p_win.col = p_win.col[false]
    end
    if type(x_win.row) == "table" then
      x_win.row = x_win.row[false]
    end
    if type(p_win.row) == "table" then
      p_win.row = p_win.row[false]
    end

    x_win.width = math.floor(x_win.width * split_percent)
    p_win.width = math.floor(p_win.width * (1 - split_percent))
    p_win.col = math.floor(x_win.col + x_win.width) + 2
    p_win.height = x_win.height
    p_win.row = x_win.row

    vim.api.nvim_win_set_config(xplr.ui.winid, x_win)
    xplr.previewer.ui:set_position({ row = p_win.row, col = p_win.col - 2 }, relative)
    xplr.previewer.ui:set_size({ width = p_win.width, height = p_win.height - 2 })
  end

  -- setup xplr buf autocmd once on 1 buffer
  if xplr.ui and xplr.ui.bufnr then
    vim.cmd(
      [[autocmd WinClosed <buffer=]] .. xplr.ui.bufnr .. [[> ++nested ++once :silent lua require('xplr').close()]]
    )
  end

  vim.api.nvim_win_set_var(xplr.previewer.ui.winid, "XplrPreviewer", true)

  -- setup previewer autocmd on every winclosed as previewer bufnr changes for every previewed file
  if xplr.previewer.ui.bufnr then
    vim.cmd("augroup XplrPreviewer")
    vim.cmd([[autocmd WinClosed * lua require('xplr.manager')._previewer_autocmd('<afile>')]])
    vim.cmd("augroup END")

  if xplr.ui then
    -- setup keymaps on xplr window when previewer opens
    for _, keymap in ipairs(mappings.previewer_xplr) do
      vim.api.nvim_buf_set_keymap(xplr.ui.bufnr, keymap[1], keymap[2], keymap[3], keymap[4])
    end
 vim.api.nvim_set_current_win(xplr.ui.winid)

  end


end

 end

function manager._previewer_autocmd(winid)
  local ok, status = pcall(vim.api.nvim_win_get_var, winid, "XplrPreviewer")

  if ok then
    manager.close()
  end

  vim.cmd("autocmd! XplrPreviewer")
end

function manager._close_preview_window()
  local relative
  if config.ui.relative == "win" and config.ui.relative == "table" then
    relative = { type = "win", winid = xplr.ui.popup_state.parent_winid }
  else
    relative = config.ui.relative
  end
  xplr.previewer.ui:unmount()

  if config.previewer.split then
    -- NO SPLIT
    xplr.ui:set_position(config.ui.position, relative)
    xplr.ui:set_size(config.ui.size)

    xplr.previewer.ui:set_position(config.previewer.ui.position, relative)
    xplr.previewer.ui:set_size(config.previewer.ui.size)
  end
end

function manager.focus()
  if not xplr.ui.winid then
    return
  end
  local c_win = vim.api.nvim_get_current_win()
  local xplr_focused = c_win == xplr.ui.winid or false

  if xplr_focused then
    if xplr.last_editor_winnr then
      vim.api.nvim_set_current_win(xplr.last_editor_winnr)
    end
  else
    xplr.last_editor_winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(xplr.ui.winid)
    vim.cmd("startinsert")
  end
end

return manager
