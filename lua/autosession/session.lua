local M = {}

local basef = require("autosession.base-functions")
local lib = require("autosession.lib")

M.SaveSession = function(create_new_if_not_exist)
  local cwd = vim.fn.getcwd()
  if basef.FullPath(cwd) == basef.FullPath(vim.env.HOME) then
    lib.echo("Currently working in $HOME directory. Not saving session.")
    return nil
  end
  local sessionpath = basef.FullPath(cwd .. "/.session.vim")
  if create_new_if_not_exist == true or basef.file_exist(sessionpath) then
    local wait_counter = 1000
    while vim.g.autosession_win_opened > 0 and wait_counter > 0 do
      wait_counter = wait_counter - 1
    end
    local confirm_msg = "May crush. Please wait until all Notification are gone. Continue? [Y/n]:"
    if vim.g.autosession_win_opened <= 0 or basef.Confirm(confirm_msg, "y", true) then
      vim.cmd("mksession! " .. sessionpath)
      lib.echo(".session.vim created.")
    else
      lib.echo("Aborted!", "error")
    end
  end
  return sessionpath
end

M.SaveGlobalSession = function()
  local cwd = vim.fn.getcwd()
  if not vim.g.startify_session_dir then
    lib.echo("Please set `g:startify_session_dir`.\nAbort", "error")
    return false
  end
  vim.fn.mkdir(basef.FullPath(vim.g.startify_session_dir), "p")
  local dirname = basef.FullPath(vim.g.startify_session_dir) .. "/" .. basef.SessionName(cwd)
  local sessionpath = M.SaveSession(true)
  if not basef.file_exist(dirname) or basef.Confirm(dirname .. " exists. Overwrite? [y/N]:", "n", false) then
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

M.RestoreSession = function()
  local cwd = vim.fn.getcwd()
  local sessionpath = basef.FullPath(cwd .. "/.session.vim")
  if not vim.fn.filereadable(sessionpath) then
    return false
  end
  if basef.file_exist(sessionpath) then
    vim.cmd("so " .. sessionpath)
  else
    print("AutoSession WARN: Last session not found. Run :AutoSessionSave to save session.")
    vim.cmd("redraws")
  end
  local current_session = basef.SessionName(cwd)
  for buf = 1, vim.fn.bufnr("$") do
    local bufname = vim.fn.bufname(buf)
    if string.match(bufname, "^.*/$") then
      vim.cmd("bd " .. bufname)
    elseif string.match(bufname, "^\\[.*\\]$") then
      vim.cmd("bd " .. bufname)
    elseif basef.SessionName(bufname) == current_session then
      vim.cmd("bd " .. bufname)
    end
  end
  return true
end

M.DeleteSession = function()
  local cwd = vim.fn.getcwd()
  local session_list = {}
  for line in vim.fn.globpath(basef.FullPath(vim.g.startify_session_dir), "[^_]*"):gmatch("([^\n]+)") do
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
    local quest = "Delete which session? (Default: " .. (current >= 1 and current or "None") .. ") (q: quit): "
    local c = vim.fn.input(quest)
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
    local sessionpath = basef.FullPath(cwd .. "/.session.vim")
    os.remove(sessionpath)
    lib.echo("Delete " .. session_list[current])
  else
    lib.echo("Aborted")
  end
end

return M
