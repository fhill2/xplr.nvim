local actions = {}
local utils = require("xplr.utils")
local manager = require("xplr.manager")
local xplr = manager.state
local config = require("xplr.config")

function actions.hello_world(data)
  print(vim.inspect(data))
end

function actions.open_selection(selection)
  local filepaths = utils.get_absolute_paths(selection)

  vim.tbl_map(function(filepath)
    vim.api.nvim_win_call(1000, function()
      vim.cmd(string.format("%s %s", "e", filepath))
    end)
  end, filepaths)

  if config.xplr.close_after_opening_files then
  manager.close()
  end
end

-- telescope/actions/init.lua

function actions.scroll_previewer_up()
  actions.scroll_previewer(-1)
end

function actions.scroll_previewer_down()
  actions.scroll_previewer(1)
end

actions.scroll_previewer = function(direction)
  -- local state = require('telescope.state')
  -- --local status = state.get_status(prompt_bufnr)
  local default_speed = vim.api.nvim_win_get_height(xplr.previewer.ui.winid) / 2
  local speed = config.previewer.scroll_speed or default_speed
  xplr.previewer.file:scroll_fn(math.floor(speed * direction))
end

return actions
