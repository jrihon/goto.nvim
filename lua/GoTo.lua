-- protected call to see if nvim-tree is available to us
local nvimtree_status_ok, _ = pcall(require, "nvim-tree")
if not nvimtree_status_ok then
  print("Nvim-tree is not installed, cannot use goto.nvim plugin")
  return
end

-- All functions from utils_goto.lua are only imported in this local file
-- This means that utils cannot be utilised outside of this file!
local utils = require('utils_goto')


-- The only accessible function for this plugin is GoTo()
-- map this to a keystroke to activate
function GoTo()
  -- initialise current state of affairs
  local CurrentWorkingDir = utils.get_path_of_file()
  local CurrentLine  = utils.get_cursor_line()

  -- if line does not have a require function, end the function. Else return the parsed contents of `require`
  local require_bool = utils.has_require(CurrentLine)
  if not require_bool then
    print('No `require` function found! Exiting ...')
    do
      return
    end
  end

  local t_RequireContents = utils.parse_require_contents(CurrentLine)   -- returns contents of require( ) in a table
  local cwd_dirname = utils.dirname(CurrentWorkingDir)                  -- returns string
  local require_t_length = utils.tablelength(t_RequireContents)
  local lsdir = utils.lsdir(cwd_dirname)                                -- returns table

  -- Check if file is in current working directory
  for _, v in pairs(lsdir) do
    for _, w in pairs(t_RequireContents) do
      if v == w..'.lua' then
        utils.open_file_in_buffer(cwd_dirname, w) do return end     -- end GoTo.nvim when found file of interest
      -- if the first value is a directory, check if the directory has an init.lua file
      elseif utils.is_dir(cwd_dirname..w) then
        local init_ok = utils.search_initlua(cwd_dirname..w)
        if init_ok then utils.open_file_in_buffer(cwd_dirname..w, 'init') do return end end -- if the directory contains init.lua, open it
      end
    end
  end

  -- Check if there is a lua/ directory here. Append it to the cwd. Else return from the function
  for _, v in pairs(lsdir) do if v == 'lua' and utils.is_dir(cwd_dirname..'lua') then cwd_dirname = cwd_dirname..'lua' end end
  if string.match(cwd_dirname, "lua$") ~= 'lua' then print("FileNotFound/DirNotFound. Aborting ...") do return end end
  print(cwd_dirname)








end



--[[    PSEUO CODE

1. Parse the contents of the require("")
2. Check if the imported module is in the current working directory
  a. -> Either this is a file or a directory :
        If file -> open file in buffer
        If directory -> list of directory and search
            then check if files or directories match description
  b. -> If it is not present, check if there is a lua/ directory
        repeat step a.

3. If the final target is a directory : 
  a. -> search for an init.lua file in the directory and open this in the buffer

  b. If this is not the case, open Nvim-tree open in the buffer


  Current problem : an elegant way to iteratively check all directories and append pathnames while doing it.

  I think I need two parts. When where I check everything in the current directory iteratively and so forth.
    And one where I do the same, but starting from the lua/ directory in the cwd.
        THE END ]]




-- string indexes is doing by string.sub(s, int start, int end)
-- MIND YOU THAT LUA STARTS INDEXING AT 1 AND HAS INCLUSIVE RANGES!
-- make a table of only files that end in lua

-- make a table of only directories in the cwd
-- first check if there is a lua/ directory present
-- also check if the directory you are going into has an init.lua file
-- if it does not, check for other directories with name matching
