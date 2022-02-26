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

M.echo = function(msg, level, ...)
  if not level then
    level = "info"
  end
  local opts = { ... }
  opts.title = opts.title or M.plugin_name
  opts.icon = opts.icon or M.plugin_icon
  basef.echo(msg, level, opts)
end

return M
