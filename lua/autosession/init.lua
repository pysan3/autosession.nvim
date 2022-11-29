local lib = require("autosession.lib")
local session = require("autosession.session")
local config = require("autosession.config")
local window = require("autosession.window")

-- import functions from window, session, lib
local M = vim.tbl_deep_extend("force", {}, window, session)

local function setup_vim_commands()
  vim.cmd([[
  command! -bar AutoSession lua require('autosession').help()
  command! -bar AutoSessionSave lua require('autosession').SaveSession(true)
  command! -bar AutoSessionAuto lua require('autosession').SaveSession(false)
  command! -bar AutoSessionGlobal lua require('autosession').SaveGlobalSession()
  command! -bar AutoSessionDelete lua require('autosession').DeleteSession()
  command! -bar AutoSessionRestore lua require('autosession').RestoreSession()
  ]])
end

---setup function, call on startup
---@param opts autosession.Config: look https://github.com/pysan3/autosession.nvim for config detail
M.setup = function(opts)
  config.set_options(opts)
  if config.msg ~= nil then
    lib.echo(config.msg)
  end
  if config.save_session_global_dir ~= vim.g.startify_session_dir then
    lib.warn(string.format([[
`save_session_global_dir` is different from vim.g.startify_session_dir: %s, %s
This plugin will overwrite it. Do not set save_session_global_dir if use vim.g.startify_session_dir
    ]], config.save_session_global_dir, vim.g.startify_session_dir))
  end
  setup_vim_commands()
  if config.restore_on_setup == true then
    vim.cmd([[
    augroup AutoSessionRestore
      autocmd! VimEnter * nested AutoSessionRestore
    augroup END
    ]])
  end
  if config.autosave_on_quit == true then
    vim.cmd([[
    augroup AutoSessionAutoSave
      autocmd! VimLeave * nested AutoSessionAuto
    augroup END
    ]])
  end
end

return M
