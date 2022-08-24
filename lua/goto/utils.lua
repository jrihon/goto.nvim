--[[ Util file for the functions required for the GoTo.nvim plugin

  Understand that a file that is being required actually returns a table.
  That table returns a list of functions! ]]

-- initialise table
local M = {}


--[[ LOCAL FUNCTIONS]]
-- code for if it is a directory : 21
local function is_dir(path)
    local fileHandler = io.open(path, "r")
    if fileHandler ~= nil then
      local _, _, code = fileHandler:read(1)
      fileHandler:close()
      return code == 21             -- returns boolean value
    end
end

-- Use gmatch to capture strings which contain at least one character of anything other than
-- the desired separator
-- https://stackoverflow.com/questions/1426954/split-string-in-lua
-- https://www.tutorialspoint.com/how-to-split-a-string-in-lua-programming
local function split (inputstr, sep)
  local t = {} -- make a table
  local count = 1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[count] = str -- instance the keys as index integers
    count = count + 1
  end
  return t
end

-- make a list of all the items in the directory
-- returns only the basename of all the files in the cwd
local function lsdir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls "'..directory..'"') -- ls in cwd to find all files
    if pfile ~= nil then
      for filename in pfile:lines() do
          i = i + 1
          t[i] = filename       -- extend list with filenames
      end
      io.close(pfile)
      return t
    end
end

--  Check if file exists
-- if the file opening does not return a `nil` value, return true, else false
local function file_exists(name)
  local fileHandler, _ = io.open(name, "r")
  if fileHandler ~= nil then io.close(fileHandler) return true else return false end
end

-- Check if the string contains a regex sensitive character
-- In this case, since these are file and dirnames, we only check for `-`
local function escape_regex(str)
  local split_str, final_str = split(str, '-'), ''
  -- iterate over the table
  for _, v in pairs(split_str) do
    final_str = final_str..v..'%-' --apparently this is an escape character in lua?? Instead of the ubiquitous `\` character kek
  end
  return string.sub(final_str, 1, -3) -- chop off the last two characters a.k.a `string indexing` kek 
end

--[[ M.FUNCTIONS]]
-- Get size of a table
function M.tableSize(table, start)
    local count = start
    for _ in pairs(table) do count = count + 1 end
    return count
end

-- get line contents of the cursor position
function M.get_cursor_line()
  return vim.api.nvim_get_current_line()
end

-- get cwd of the file we are in
function M.get_path_of_file()
  return vim.fn.expand('%:p')
end

-- check if the `require` function is used in the queried line
function M.has_require(str)
  local require_start, _ = string.find(str, 'require')
  if type(require_start) == "number" then return true else return false end
end

-- parse contents of the require function
function M.parse_require_contents(linestr)
  -- https://stackoverflow.com/questions/42206244/lua-find-and-return-string-in-double-quotes
  -- parse from after require on
  local _, require_end = string.find(linestr, 'require')
  local parsestr = string.sub(linestr, require_end + 1, string.len(linestr))

  -- double quotes
  local quotedstr_d = string.match(parsestr, '"([^"]+)')
  if quotedstr_d ~= nil then return split(quotedstr_d, '.') end

  -- single quotes
  local quotedstr_s = string.match(parsestr, '\'([^\']+)')
  if quotedstr_s ~= nil then return split(quotedstr_s, ".") end
end

-- if the match is successful, it returns the match as a variable
function M.is_lua_file(fname)
  if fname == nil then return false end  -- guarding the returned nil value from matching a directory

  local match = string.match(fname, ".lua$") --regex magic
  if match == ".lua" then return true else return false end   -- if true else false
end

-- get the dirname
function M.dirname(path)
    local t_path = split(path, '/')
    local t_size = M.tableSize(t_path, 0) - 1

    local dirname = '/'
    for i = 1, t_size do dirname = dirname..t_path[i]..'/' end
    return dirname
end

function M.dirs_and_luafiles(cwd, max_depth)

  local t_luafiles, t_dirs = {}, {}
  local lsdir1 = lsdir(cwd)
  -- Storing the different filenames and directorynames as keys in the table
  -- automatically gives us unique values for the strings we want.
  -- This way we do not have to filter ourselves.
  for _, v in pairs(lsdir1) do
    if is_dir(cwd..v..'/') then
        local d = cwd..v..'/'
        t_dirs[d] = 1
    elseif M.is_lua_file(cwd..v) then
        local f = cwd..v
        t_luafiles[f] = 1
    end
  end

  -- if there was but one depth, then return the tables
  if max_depth == 1 then
    return t_luafiles, t_dirs
  end

  -- This part is the heart of the plugin
  -- We check all the already queried directories and check their contents (ls command)
  -- We update the table of dirs and luafiles and then we iterated over the updated t_dirs
  --
  -- Eventually we get all the files and directories we want to continue our search
  for _ = 1, max_depth - 1 do
    for k, _ in pairs(t_dirs) do
      local lsdir2 = lsdir(k)

      for _, w in pairs(lsdir2) do
        local d = k..w..'/'
        local f = k..w
        if is_dir(d) then t_dirs[d] = 1 end
        if M.is_lua_file(f) then t_luafiles[f] = 1 end
      end
    end
  end

  return t_luafiles, t_dirs
end

function M.match_lua_file(t_RequireContent, t_luafiles)
  -- Let string be the suffix of the file to match
  local match_to_contents = ''
  for _, v in pairs(t_RequireContent) do match_to_contents = match_to_contents..'/'..v end
  match_to_contents = escape_regex(match_to_contents..'.lua')

  -- search for the file
  for k, _ in pairs(t_luafiles) do
    local match = string.match(k, match_to_contents..'$')       -- regex magix
    if match ~= nil then return k end
  end
end

function M.match_directory(t_RequireContent, t_dirs)
  -- Let string be the suffix of the file to match
  local match_to_contents = ''
  for _, v in pairs(t_RequireContent) do match_to_contents = match_to_contents..'/'..v end
  match_to_contents = escape_regex(match_to_contents..'/')

  -- search for the directory
  for k, _ in pairs(t_dirs) do
    local match = string.match(k, match_to_contents..'$')       -- regex magix
    if match ~= nil then
      -- check if directory contains a file
      local match_init = k..'init.lua'
      print(match_init)
      if file_exists(match_init) then return match_init else return match end
    return match end
  end
end

function M.open_file_in_buffer(fname_path)
  vim.cmd('e '..fname_path)
end

function M.open_dir_in_nvimtree(matched_directory)
    vim.cmd('NvimTreeOpen '..matched_directory)
end

return M -- return table
