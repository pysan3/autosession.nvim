local M = {}

local lib = require("autosession.lib")
local session = require("autosession.session")
local window = require("autosession.window")

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

-- import functions from window, session, lib
for key, value in pairs(window) do
  M[key] = value
end
for key, value in pairs(session) do
  M[key] = value
end
M.help = lib.help

local DEFAULT_OPTS = {
  msg = nil,
  restore_on_setup = false,
  autosave_on_quit = false,
  save_session_global_dir = vim.g.startify_session_dir or vim.fn.stdpath("data") .. "/session",
  sessionfile_name = ".session.vim",
}
---setup function, call on startup
---@param opts table: look https://github.com/pysan3/autosession.nvim for config detail
M.setup = function(opts)
  lib.merge_options(opts, DEFAULT_OPTS)
  window.init_win_open_safe()
  if opts.msg ~= nil then
    lib.echo(opts.msg)
  end
  if opts.save_session_global_dir ~= nil and opts.save_session_global_dir ~= vim.g.startify_session_dir then
    print("save_session_global_dir is different from vim.g.startify_session_dir: " .. vim.g.startify_session_dir)
    print("This plugin will overwrite it. Do not set save_session_global_dir if use vim.g.startify_session_dir")
  end
  setup_vim_commands()
  if opts.restore_on_setup == true then
    vim.cmd([[
    augroup AutoSessionRestore
      autocmd! VimEnter * nested AutoSessionRestore
    augroup END
    ]])
  end
  if opts.autosave_on_quit == true then
    vim.cmd([[
    augroup AutoSessionAutoSave
      autocmd! VimLeave * nested AutoSessionAuto
    augroup END
    ]])
  end
  window.init_win_open_safe()
  session.setup(opts)
end

return M
