--[[
  Util file for the functions required for the GoTo.nvim plugin

  Understand that a file that is being required actually returns a table.
  That table returns a list of functions!
  ]]

-- initialise table
local M = {}



--[[ LOCAL FUNCTIONS]]
-- Get size of a table
function M.tableLength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end




--[[ GLOBAL FUNCTIONS]]
-- get line contents of the cursor position
function M.get_cursor_line()
  return vim.api.nvim_get_current_line()
end

-- get cwd of the file we are in
function M.get_path_of_file()
  return vim.fn.expand('%:p')
end

-- Use gmatch to capture strings which contain at least one character of anything other than
-- the desired separator
-- https://stackoverflow.com/questions/1426954/split-string-in-lua
-- https://www.tutorialspoint.com/how-to-split-a-string-in-lua-programming
function M.split (inputstr, sep)
  local t = {}
  local count = 1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
  -- make a table and instance the keys as index values
    t[count] = str
    count = count + 1
  end
  return t
end


-- parse contents of the require function
function M.parse_require_contents(linestr)
  -- https://stackoverflow.com/questions/42206244/lua-find-and-return-string-in-double-quotes
  -- parse from after require on
  local _, require_end = string.find(linestr, 'require')
  local parsestr = string.sub(linestr, require_end + 1, string.len(linestr))

  -- double quotes
  local quotedstr_d = string.match(parsestr, '"([^"]+)')
  if quotedstr_d ~= nil then return M.split(quotedstr_d, '.') end

  -- single quotes
  local quotedstr_s = string.match(parsestr, '\'([^\']+)')
  if quotedstr_s ~= nil then return M.split(quotedstr_s, ".") end
end

--  Check if file exists
-- if the file opening does not return a `nil` value, return true, else false
function M.file_exists(name)
  local fileHandler, _ = io.open(name, "r")
  if fileHandler ~= nil then io.close(fileHandler) return true else return false end
end


-- if the match is successful, it returns the match as a variable
function M.is_lua_file(fname)
  local match = string.match(fname, ".lua$") --regex magic
    if match == ".lua" then return true else return false end
end

-- make a list of all the items in the directory
-- returns only the basename of all the files in the cwd
function M.lsdir(directory)
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


-- check if the `require` function is used in the queried line
function M.has_require(str)
  local require_start, _ = string.find(str, 'require')
  if type(require_start) == "number" then return true else return false end
end


-- code for if it is a directory : 21
function M.is_dir(path)
    local fileHandler = io.open(path, "r")
    if fileHandler ~= nil then
      local _, _, code = fileHandler:read(1)
      fileHandler:close()
      return code == 21             -- returns boolean value
    end
end

-- get the dirname
function M.dirname(path)
    local t_path = M.split(path, '/')
    local t_size = M.tableLength(t_path) - 1

    local dirname = '/'
    for i = 1, t_size do dirname = dirname..t_path[i]..'/' end
    return dirname
end


function M.open_file_in_buffer(path, fname)
  local fname_path = path..'/'..fname..'.lua'
  vim.cmd('e '..fname_path)
end

function M.search_initlua(path)
    if M.file_exists(path..'/init.lua') then return true else return false end
end

-- return table
return M
