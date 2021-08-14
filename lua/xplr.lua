local xplr = {}
local config = require("xplr.config")
local manager = require("xplr.manager")

function xplr.selection(sel)
  print(sel)
end

function xplr.start_preview() end

function xplr.toggle()
  manager.toggle()
end

function xplr.close()
  manager.close()
end

function xplr.open(opts)
  manager.open(opts)
end

function xplr.focus()
  manager.focus()
end

function xplr.toggle_preview_window()
  -- does not start preview, only toggles preview win ui before after preview is started within xplr
  manager.toggle_preview_window()
end

function xplr.setup(opts)
  config.setup(opts)
end

-- function xplr.setup_keymap(...)
-- config.setup_keymap(...)
-- end

function xplr.load_command(cwd)
  manager.open({ cwd = cwd })
end

return xplr
