-- All functions from utils_goto.lua are only imported in this local file
-- This means that utils cannot be utilised outside of this file!
local utils = require('goto.utils')


-- The only accessible function for this plugin is GoTo()
function GoTo()

  local CurrentLine  = utils.get_cursor_line() -- initialise current state of affairs

  -- if line does not have a require function, end the function. Else return the parsed contents of `require`
  local require_bool = utils.has_require(CurrentLine)
  if not require_bool then
    print('No `require` function found! Exiting ...')
    do return end
  end

  local CurrentWorkingDir = utils.get_path_of_file()                    -- returns pathname of the file itself
  local cwd_dirname = utils.dirname(CurrentWorkingDir)                  -- returns dirname of the file itself

  local t_RequireContents = utils.parse_require_contents(CurrentLine)   -- returns contents of require( ) in a table
  local max_depth = utils.tableSize(t_RequireContents, 1)               -- max search depth of require( )

  -- Return all subdirectories and the lua files within until `max_depth` is reached
  local t_luafiles, t_dirs = utils.dirs_and_luafiles(cwd_dirname, max_depth)

  -- See if it matches with a lua file
  local matched_lua_file = utils.match_lua_file(t_RequireContents, t_luafiles)
  if matched_lua_file ~= nil then
    utils.open_file_in_buffer(matched_lua_file)
    do return end
  end

  -- See if it matches with a directory
  -- If directory contains an init.lua file, open that
  -- If not, open the directory in Nvim-Tree
  local matched_directory = utils.match_directory(t_RequireContents, t_dirs)
  if utils.is_lua_file(matched_directory) then
    utils.open_file_in_buffer(matched_directory)
    return
  else print("Not corresponding `.lua` or `init.lua` found! Exiting ...")
  end
end
