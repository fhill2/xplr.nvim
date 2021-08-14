# xplr.nvim
simply opens xplr in a floating window, providing these features:

- [xplr.vim](https://github.com/sayanarijit/xplr.vim) features: layout, mappings

- preview hovered file in preview window (using Telescope previewer)

- open selection in nvim

- a simple API that wraps nvim lua msgpack client customized for xplr. This is so you can call nvim API functions or your own lua functions from xplr. 

![nvim-xplr4](https://user-images.githubusercontent.com/16906982/129458538-ba41fc00-c940-4d53-b299-6bf9fdeeb2ad.gif)

## Installation
#### Install plugin
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'nvim-telescope/telescope.nvim',
  requires = {{'nvim-lua/plenary.nvim'}, {'MunifTanjim/nui.nvim'}}
}
```
Using [vim-plug](https://github.com/junegunn/vim-plug)
```lua
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-telescope/telescope.nvim'
```


#### Installation for optional features

- previewed hovered file - requires: [nvim.xplr](https://github.com/fhill2/nvim.xplr) [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- open selection in nvim - requires: [nvim.xplr](https://github.com/fhill2/nvim.xplr)
- calling nvim lua & vim functions from xplr lua functions - requires: [nvim.xplr](https://github.com/fhill2/nvim.xplr)



## Configuration
```lua
require("xplr").setup({
  xplr = {
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
 

## Keymap Config
`set_keymap()` keymaps loaded on xplr window when xplr window opens

`on_previewer_set_keymap()` keymaps loaded on xplr window when preview window opens

Keymaps configured in the [nvim.xplr](https://github.com/fhill2/nvim.xplr) plugin:

- open xplr selection in nvim
- previewer hovered selection in Telescope driven previewer


#### Keymap Conflicts
the default mappings above conflict with the default xplr mappings to select files (space).
You can unset and use `v` default xplr keymap for selection inside xplr instead

To remove this mapping in xplr:

```lua
-- ~/.config/xplr/init.lua
xplr.config.modes.builtin.default.key_bindings.on_key.space = {}
```



### Usage

Git project root

```
command XplrProjectRoot :Xplr `git rev-parse --show-toplevel`

:XplrProjectRoot
```

Current file

```
:Xplr %:p
```

Current working directory

```
:Xplr
```

Root
```
:Xplr /
```

## TODO

- UI with standard windows instead of floating (nui/split/init.lua)
- Option to register autocmd to close xplr when leaving xplr buf
- file extension dependent preview switching
- improve floating window UI - vertical layout
- send to qflist 







