
config = {
xplr = {
ui = {
  border = {
   style = "none"
  },
  position = "50%",
  size = {
    width = "80%",
    height = "60%",
  },
},
},
previewer = {
split = true,
split_percent = 0.5
--ui = {}
}
}




function config.setup(opts)




-- disable setting border on xplr window
if opts.xplr.ui.border then 
opts.xplr.ui.border = {
style = "none"
}



for key, val in pairs(opts) do
  
  if not config[key] then 
  elseif type(val) == 'table' then
      config[key] = vim.tbl_deep_extend('force', config[key], val)
  else
   config[key] = val
  end
end
end


end

return config
