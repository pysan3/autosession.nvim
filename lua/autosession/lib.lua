local M = {}

local basef = require("autosession.base-functions")

M.plugin_name = "AutoSession Plugin"
M.plugin_icon = ""
M.plugin_commands = {
  AutoSessionRestore = "Restore previous session from `.session.vim`.",
  AutoSessionSave = "Create `.session.vim` to store current session.",
  AutoSessionAuto = "Update `.session.vim` if exists.",
  AutoSessionGlobal = "Resigter current session for vim-startify.",
  AutoSessionDelete = "Delete a global session.",
}

M.help = function()
  local str = "Available Commands:\n\n"
  for command, com_help in pairs(M.plugin_commands) do
    str = str .. "- " .. command .. ": " .. com_help .. "\n"
  end
  M.echo(str, "warn", { title = M.plugin_name .. " Help" })
end

---wrapper of base-functions.echo: adds title and icon
---@param msg string
---@param level integer | string | nil: ("info", "warn", "error")
---@param ... any: any options to pass to vim.notify
M.echo = function(msg, level, ...)
  local opts = { ... }
  opts.title = opts.title or M.plugin_name
  opts.icon = opts.icon or M.plugin_icon
  basef.echo(msg, level, opts)
end

---wrapper of base-functions.echo: adds title and icon
---@param msg string
---@param ... any: any options to pass to vim.notify
M.info = function(msg, ...)
  local opts = { ... }
  opts.title = opts.title or M.plugin_name
  opts.icon = opts.icon or M.plugin_icon
  basef.echo(msg, "info", opts)
end

---wrapper of base-functions.echo: adds title and icon
---@param msg string
---@param ... any: any options to pass to vim.notify
M.warn = function(msg, ...)
  local opts = { ... }
  opts.title = opts.title or M.plugin_name
  opts.icon = opts.icon or M.plugin_icon
  basef.echo(msg, "warn", opts)
end

---wrapper of base-functions.echo: adds title and icon
---@param msg string
---@param ... any: any options to pass to vim.notify
M.error = function(msg, ...)
  local opts = { ... }
  opts.title = opts.title or M.plugin_name
  opts.icon = opts.icon or M.plugin_icon
  basef.echo(msg, "error", opts)
end

---safely run vim.cmd
---@param cmd string: command to execute. passed to vim.cmd
---@param error_msg string: error message to notify if command failed
---@return boolean, any: result of vim.cmd(cmd)
M.safe_cmd = function(cmd, error_msg)
  local suc, res = pcall(vim.cmd, cmd) ---@diagnostic disable-line
  if not suc then
    M.error(string.format("%s: %s", error_msg, res))
  end
  return suc, res
end

return M
