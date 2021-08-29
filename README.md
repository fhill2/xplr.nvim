# xplr.nvim
opens xplr inside nvim, and hosts a msgpack client inside xplr.

Provides these features:

- [xplr.vim](https://github.com/sayanarijit/xplr.vim) features: layout, mappings

- preview hovered file in preview window (using Telescope previewer)

- open selection in nvim

- set cwd: nvim <--> xplr 

- a simple API that wraps nvim lua msgpack client customized for xplr. This is so you can call nvim API functions or your own lua functions from xplr. Also allows communication without using shell / pipes / neovim remote.

![nvim-xplr4](https://user-images.githubusercontent.com/16906982/129458538-ba41fc00-c940-4d53-b299-6bf9fdeeb2ad.gif)

## Installation
#### Install plugin
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'fhill2/xplr.nvim',
  requires = {{'nvim-lua/plenary.nvim'}, {'MunifTanjim/nui.nvim'}, {'nvim-telescope/telescope.nvim'}},
  run = "git submodule update --init --recursive && cd src/luv && make && cd ../libmpack && make"
}
```
Using [vim-plug](https://github.com/junegunn/vim-plug)
```lua
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'fhill2/xplr.nvim'
```



## Configuration
```lua
require("xplr").setup({
    ui = {
      border = {
        style = "single",
        highlight = "FloatBorder",
      },
      position = "30%",

      size = {
        width = "40%",
        height = "60%",
      },
    },
  previewer = {
    split = true,
    split_percent = 0.5,
    ui = {
      border = {
        style = "single",
        highlight = "FloatBorder",
      },
      position = { row = "1%", col = "99%" },
      relative = "editor", -- editor only supported for now
      size = {
        width = "30%",
        height = "99%",
      },
    },
  },
 xplr = {
    open_selection = {
      enabled = true,
      mode = "action",
      key = "o",
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
})

local opts = { noremap = true, silent = true }
local nvim_set_keymap = vim.api.nvim_set_keymap
local mappings = require("xplr.mappings")
local set_keymap = mappings.set_keymap
local on_previewer_set_keymap = mappings.on_previewer_set_keymap



nvim_set_keymap("n", "<space>xx", '<Cmd>lua require"xplr".open()<CR>', opts) -- open/focus cycle
set_keymap("t", "<space>xx", '<Cmd>lua require"xplr".focus()<CR>', opts) -- open/focus cycle

nvim_set_keymap("n", "<space>xc", '<Cmd>lua require"xplr".close()<CR>', opts)
set_keymap("t", "<space>xc", '<Cmd>lua require"xplr".close()<CR>', opts)

nvim_set_keymap("n", "<space>xv", '<Cmd>lua require"xplr".toggle()<CR>', opts)
set_keymap("t", "<space>xv", '<Cmd>lua require"xplr".toggle()<CR>', opts)

on_previewer_set_keymap("t", "<space>xb", '<Cmd>lua require"xplr.actions".scroll_previewer_up()<CR>', opts)
on_previewer_set_keymap("t", "<space>xn", '<Cmd>lua require"xplr.actions".scroll_previewer_down()<CR>', opts)
```


## UI Config
`xplr.ui` - [nui.nvim](https://github.com/MunifTanjim/nui.nvim) configuration for xplr window

`previewer.ui`- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) configuration for previewer window


`previewer.split = true` splits xplr win when previewer win opens (currently Horizontal only supported)

`previewer.split = false` uses `previewer.ui` config for previewer win when it opens
 
## Opts
list of available opts to use for `open()`

`cwd`



## Keymap Config

`set_keymap()` keymaps loaded on xplr window when xplr window opens

`on_previewer_set_keymap()` keymaps loaded on xplr window when preview window opens

#### Keymap Conflicts
the default mappings above conflict with the default xplr mappings to select files (space).
You can unset and use `v` default xplr keymap for selection inside xplr instead

To remove this mapping in xplr:

```lua
-- ~/.config/xplr/init.lua
xplr.config.modes.builtin.default.key_bindings.on_key.space = {}
```

#### Vim command
There is no VimL command binded by default

```vim
command! -bar -nargs=? -complete=dir Xplr lua require'xplr'.load_command(<f-args>)

" Usage
:Xplr %:p " current file
:Xplr " cwd
:Xplr / " root
```


#### API
##### Examples for creating custom commands
Creating your own Commands that interact with nvim:

requiring `nvim-xplr` in xplr `init.lua`returns the msgpack client object.

You can then use the msgpack client within your xplr lua functions in `xplr/init.lua` to trigger and send data to functions in nvim like this:

```lua

xplr.fn.custom.nvim_hello = function(app)
 nvim:exec_lua(
          'return require"xplr.actions".hello_world(...)', app)

  
return { LogSuccess = "combine messages and nvim API calls" }
end 

xplr.config.modes.builtin.action.key_bindings.on_key["u"] = {
      help = "hello nvim",
      messages = {
        { CallLuaSilently = "custom.nvim_hello" },
      },
    }

``` 

msgpack client accepts tables, client will nil all userdata/function refs

you can call whatever nvim API method you want, however i've found it easier to send data over to a nvim function and do the work on the nvim side.

```lua

-- call nvim functions from xplr function
 nvim:exec_lua('return require"xplr.actions".hello_world(...)', data)

-- call vimL functions from xplr function
 nvim:command('echo "hello world"')

-- call any nvim API method like this (untested)
nvim:request("nvim_command", "echo v:servername")
```


## TODO

- UI with standard windows instead of floating (nui/split/init.lua)
- Option to register autocmd to close xplr when leaving xplr buf
- file extension dependent preview switching
- improve floating window UI - vertical layout
- send to qflist 
- cwd `open()` opts to support relative file paths
- change xplr CWD via nvim lua function without reopening







