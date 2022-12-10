local M = {}

local basef = require("autosession.base-functions")
local lib = require("autosession.lib")
local config = require("autosession.config")

---Creates `sessionfile_name` which stores data to restore current session
---Call with `:AutoSessionSave` or `:AutoSessionAuto`.
---@param create_new_if_not_exist boolean: (default: false) false will not create file if not exists
---@return string: absolute path to `sessionfile_name`
M.SaveSession = function(create_new_if_not_exist)
  local cwd = vim.fn.getcwd()
  local sessionpath = basef.FullPath(cwd .. "/" .. config.sessionfile_name)
  if create_new_if_not_exist == true or basef.file_exist(sessionpath) then
    if config.force_autosave then
      local parent_dirname = vim.fn.fnamemodify(sessionpath, ":p:h")
      if vim.fn.isdirectory(parent_dirname) == 0 then
        vim.fn.mkdir(parent_dirname, "p")
      end
      local success, _ = lib.safe_cmd("mksession! " .. sessionpath, "Failed to make session to " .. sessionpath)
      if success then
        print(config.sessionfile_name .. " created.")
        vim.cmd("redraw")
      end
    else
      lib.echo("Aborted!", "error")
    end
  end
  return sessionpath
end

---Adds symlink of current session to `save_session_global_dir` so that startify can load it.
-- WARNING: Only works on *nix systems.
---@return boolean: succeeded or not
M.SaveGlobalSession = function()
  if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1 then
    lib.echo("SaveGlobalSession only works on *nix systems. Aborting on Windows.", "error")
    return false
  end
  local cwd = vim.fn.getcwd()
  if not config.save_session_global_dir then
    lib.echo("Please set `save_session_global_dir` or `g:startify_session_dir`.\nAbort", "error")
    return false
  end
  vim.fn.mkdir(basef.FullPath(config.save_session_global_dir), "p")
  local dirname = basef.FullPath(config.save_session_global_dir) .. "/" .. basef.SessionName(cwd)
  local sessionpath = M.SaveSession(true)
  if not basef.file_exist(dirname) or basef.Confirm(dirname .. " exists. Overwrite?", false) then
    io.popen("ln -sf " .. sessionpath .. " " .. dirname .. " >/dev/null 2>/dev/null"):close()
    if basef.file_exist(dirname) then
      lib.echo("Saved session as: " .. dirname)
      return true
    else
      lib.echo("Something went wrong.", "error")
      return false
    end
  end
  lib.echo("Abort", "error")
  return false
end

---Call to restore the session from `sessionfile_name`
---In order to restore session on VimEnter, set `restore_on_setup` = true
---@return boolean: success
M.RestoreSession = function()
  local cwd = vim.fn.getcwd()
  local sessionpath = basef.FullPath(cwd .. "/" .. config.sessionfile_name)
  if not basef.file_exist(sessionpath) then
    return false
  end
  -- memorize files specified in the arguments
  local memory = {}
  for buf = 1, vim.fn.bufnr("$") do ---@diagnostic disable-line
    local suc, bufname = pcall(vim.api.nvim_buf_get_name, buf)
    if suc then
      table.insert(memory, 0, bufname)
    end
  end
  if basef.file_exist(sessionpath) then
    lib.safe_cmd("so " .. sessionpath, "`:RestoreSession` failed")
  elseif config.warn_on_setup then
    lib.echo("AutoSession WARN: Last session not found. Run :AutoSessionSave to save session.")
  end
  -- load the files specified in the arguments after loading the session
  for _, bufname in ipairs(memory) do
    if bufname ~= nil and string.len(bufname) > 0 then
      vim.cmd.edit(bufname)
    end
  end
  local current_session = basef.SessionName(cwd)
  for buf = 1, vim.fn.bufnr("$") do ---@diagnostic disable-line
    local bufname = vim.api.nvim_buf_get_name(buf)
    if string.match(bufname, "^.*/$") or string.match(bufname, "^\\[.*\\]$") or
        basef.SessionName(bufname) == current_session then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  return true
end

---Call to delete Global sessions
---@return boolean: success
M.DeleteSession = function()
  local cwd = vim.fn.getcwd()
  local session_list = {}
  for line in vim.fn.globpath(basef.FullPath(config.save_session_global_dir), "[^_]*"):gmatch("([^\n]+)") do
    table.insert(session_list, line)
  end
  local session_len = #session_list
  local current = -1
  local current_session = basef.SessionName(cwd)
  if session_len == 0 then
    lib.echo("No sessions to delete!\nNice and clean 😄")
    return false
  end
  for index, value in ipairs(session_list) do
    if basef.s_trim(basef.basename(value)):lower() == current_session:lower() then
      current = index
    end
    print(index - 1 .. ": " .. value)
  end
  while true do
    local question = "Delete which session? (Default: " .. (current >= 1 and current or "None") .. ") (q: quit): "
    local c = vim.fn.input({ prompt = question })
    if c:len() == 0 and current >= 1 then
      break
    elseif c:match("^q$") then
      current = 0
      break
    elseif c:match("^%d$") and tonumber(c, 10) < session_len then
      current = tonumber(c, 10) + 1
      break
    else
      lib.echo("Please input an integer or nothing for default value (available only if not None).", "error")
    end
    vim.cmd("redraw")
  end
  if current >= 1 then
    os.remove(basef.s_trim(session_list[current]))
    local sessionpath = basef.FullPath(cwd .. "/" .. config.sessionfile_name)
    os.remove(sessionpath)
    lib.echo("Delete " .. session_list[current])
  else
    lib.echo("Aborted")
  end
end

return M
