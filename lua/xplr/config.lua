
config = {
  ui = {
    border = {
      style = "none",
    },
 position = {
     row = "90%",
     col = "50%",
    },
    relative = "editor",
    size = {
      width = "80%",
      height = "30%",
    },
  },
  close_after_opening_files = false,
  previewer = {
    split = true,
    split_percent = 0.5,
    --ui = {}
  },
  xplr = {
    open_selection = {
      enabled = true,
      mode = "action",
      key = "e",
    },
    preview = {
      enabled = true,
      mode = "action",
      key = "i",
      fifo_path = "/tmp/nvim-xplr.fifo",
    },
    set_nvim_cwd = {
      enabled = true,
      mode = "action",
      key = "j",
    },
    set_xplr_cwd = {
      enabled = true,
      mode = "action",
      key = "h",
    },

  },
}

function config.setup(opts)
  -- disable setting border on xplr window
  -- might re enable this
  -- if opts.ui then
  --   if opts.ui.border then
  --     opts.ui.border = {
  --       style = "none",
  --     }
  --   end
  -- end

  -- if no separate previewer config, set main xplr ui config to previewer config
  if opts.ui and not opts.previewer.ui then
    config.previewer.ui = vim.deepcopy(opts.ui)
  end

  for key, val in pairs(opts) do
    if not config[key] then
    elseif type(val) == "table" then
      config[key] = vim.tbl_deep_extend("force", config[key], val)
    else
      config[key] = val
    end
  end
end

return config
