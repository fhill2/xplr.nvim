local log = require'log1'

config = {
ui = {
  border = {
    style = "rounded",
    highlight = "FloatBorder",
    text = { 
      top = "xplr",
      top_align = "center",
    }
  },
  position = "50%",
  size = {
    width = "80%",
    height = "60%",
  },
  opacity = 1,
},
preview = true,
previewer_fifo_path = '/tmp/nvim-xplr.fifo'
}




function config.setup(opts)

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

return config
