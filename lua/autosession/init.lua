local M = {}

local lib = require("autosession.lib")
local window = require("autosession.window")

local function setup_vim_commands()
  vim.cmd([[
  command! -bar AutoSession lua require('autosession.lib').help()
  command! -bar AutoSessionSave lua require('autosession.session').SaveSession(true)
  command! -bar AutoSessionAuto lua require('autosession.session').SaveSession(false)
  command! -bar AutoSessionGlobal lua require('autosession.session').SaveGlobalSession()
  command! -bar AutoSessionDelete lua require('autosession.session').DeleteSession()
  command! -bar AutoSessionRestore lua require('autosession.session').RestoreSession()
  ]])
end

local DEFAULT_OPTS = {
  msg = nil,
  restore_on_setup = false,
  autosave_on_quit = false,
  save_session_dir = vim.g.startify_session_dir,
}
local function merge_options(opts)
  return vim.tbl_deep_extend("force", DEFAULT_OPTS, opts or {})
end

M.setup = function(opts)
  merge_options(opts)
  window.init_win_open_safe()
  if opts.msg ~= nil then
    lib.echo(opts.msg)
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
end

return M
