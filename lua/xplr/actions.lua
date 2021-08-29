local actions = {}
local utils = require("xplr.utils")
local manager = require("xplr.manager")
local xplr = manager.state
local config = require("xplr.config")

local xplr_chan_id

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

  if config.close_after_opening_files then
    manager.close()
  end
end

function actions.set_nvim_cwd(cwd)
vim.api.nvim_set_current_dir(cwd) 
end

function actions.get_nvim_cwd()
vim.fn.rpcnotify(xplr_chan_id, "nvim_cwd", vim.fn.getcwd())
end



-- telescope/actions/init.lua

function actions.scroll_previewer_up()
  actions.scroll_previewer(-1)
end

function actions.scroll_previewer_down()
  actions.scroll_previewer(1)
end

actions.scroll_previewer = function(direction)
  local default_speed = vim.api.nvim_win_get_height(xplr.previewer.ui.winid) / 2
  local speed = config.previewer.scroll_speed or default_speed
  xplr.previewer.file:scroll_fn(math.floor(speed * direction))
end


function actions._host_is_ready(arg)
  local channels = vim.api.nvim_list_chans()

  local chan_id
  for _, chan in ipairs(channels) do
    if chan.client and chan.client.name == "xplr" then
      chan_id = chan.id
    end
  end
  xplr_chan_id = chan_id

  vim.fn.rpcnotify(xplr_chan_id, "config", config.xplr)
end

return actions
