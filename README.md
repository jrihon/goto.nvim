# GoTo.nvim
Go to file or directory when you hover over a `require( )` function in any lua file that is in the `cwd` path.


## Installation
### Packer.nvim
```lua
require "jrihon/goto.nvim"
```

### Vim-plug
Although less useful if you have vim configuration, technically it is possible
```vim
Plug 'jrihon/goto.nvim'
```


## Keymap
### Lua
```lua
vim.api.nvim_set_keymap('n', '<leader>gt',':lua GoTo()<CR>',{noremap = true})
```
### Vim
```vim
nnoremap <leader>gt :lua GoTo()<CR>
```
