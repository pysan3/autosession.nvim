local M = {}

local lib = require("autosession.lib")

M.init_win_open_safe = function()
  if vim.g.autosession_win_opened == nil then
    vim.g.autosession_win_opened = 0
  end
end

M.add_win_open_timer = function(wait_for_ms, msg)
  M.add_win_open()
  vim.fn.timer_start(wait_for_ms, function()
    M.close_win_open(msg)
  end)
end

M.add_win_open = function(msg)
  M.init_win_open_safe()
  vim.g.autosession_win_opened = vim.g.autosession_win_opened + 1
  if msg ~= nil then
    lib.echo(msg)
  end
end

M.close_win_open = function(msg)
  M.init_win_open_safe()
  vim.g.autosession_win_opened = vim.g.autosession_win_opened - 1
  if msg ~= nil then
    lib.echo(msg)
  end
end

return M
