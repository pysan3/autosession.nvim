local M = {
  win_open_counter = 0,
}

local lib = require("autosession.lib")

---initializes `win_open_counter` which is an inner variable that counts fake windows
M.init_win_open_safe = function()
  if M.win_open_counter == nil then
    M.win_open_counter = 0
  end
end

---create a timer that deletes counter after `wait_for_ms`
---@param wait_for_ms integer timer erased time. in milliseconds
---@param msg string: message to notify after timer is closed
M.add_win_open_timer = function(wait_for_ms, msg)
  M.add_win_open()
  vim.fn.timer_start(wait_for_ms, function()
    M.close_win_open(msg)
  end)
end

---add a new fake window
---@param msg string: message to notify after success
M.add_win_open = function(msg)
  M.init_win_open_safe()
  M.win_open_counter = M.win_open_counter + 1
  if msg ~= nil then
    lib.echo(msg)
  end
end

---delete a registered fake window
---@param msg string: message to notify after success
M.close_win_open = function(msg)
  M.init_win_open_safe()
  M.win_open_counter = M.win_open_counter - 1
  if msg ~= nil then
    lib.echo(msg)
  end
end

---return true if there are no fake windows now
---@return boolean: whether there are no fake windows
M.valid_win_open_counter = function()
  return M.win_open_counter <= 0
end

return M
