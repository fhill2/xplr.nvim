local log = require'log1'

config = {
xplr = {
ui = {
  -- border = {
  --   style = "rounded",
  --   highlight = "FloatBorder",
  --   text = { 
  --     top = "xplr",
  --     top_align = "center",
  --   }
  -- },

  border = {
   style = "none"
  },
  position = "50%",
  size = {
    width = "80%",
    height = "60%",
  },
  opacity = 1,
},
keymaps = {}
},
previewer = {
split = 0.5
--ui = {}, -- dynamically merged at setup, leave off
}
}




function config.setup(opts)


-- validate previewer being table here


-- disable setting border on xplr window
if opts.xplr.ui.border then 
opts.xplr.ui.border = {
style = "none"
}


-- if opts.previewer.ui then
-- opts.previewer.ui.border = {

-- }
-- end

for key, val in pairs(opts) do
  
  if not config[key] then 
  log.info(string.format('xplr.nvim: %s - unsupported option', config[key]))
  elseif type(val) == 'table' then
      config[key] = vim.tbl_deep_extend('force', config[key], val)
  else
   config[key] = val
  end
end
end


--config.previewer.ui = vim.deepcopy(config.xplr.ui)

-- config.previewer.ui.border = {
-- style = "single",
-- highlight = "FloatBorder",
-- text = { top = "Preview" }
-- }
end

-- function config.setup_keymap(mode, lhs, rhs, opts)
-- table.insert(config.xplr.keymaps, {mode, lhs, rhs, opts})
-- end
-- table.insert(config.xplr.keymaps, function() 
--   vim.api.nvim_buf_set_keymap(mode, lhs, rhs, opts) end)
-- end

return config
