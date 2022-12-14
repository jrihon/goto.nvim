# GoTo.nvim
Go to file or directory when you hover over a `require( )` function in any lua file that is in the `cwd` of the file in which GoTo.nvim is called.

Essentially, when `require( )`, a file or directory is called.</br>
- Either a `.lua` file is opened, in the case of `require(path/to/file)`
- Either an `init.lua` file is opened, in the case of `require(path/to/directory/)`


### Installation (packer.nvim)
```lua
  use "jrihon/goto.nvim"        -- Easy way to navigate through nvim's lua filesystem
```

### Keymap
```lua
vim.api.nvim_set_keymap('n', '<leader>gt',':lua GoTo()<CR>',{noremap = true})
```
### Dependencies
Makes use of `kyazdani42/nvim-tree.lua` as a dependency.

### Nota bene
Only valid for subdirectories! 
I made this plugin to fix my own troubles of navigating my `init.lua`.
This plugin will not search the entire `runtimepath` to search for the contents of the queried `require( )` function.
