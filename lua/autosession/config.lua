---@class autosession.Config
---@field msg string | nil: printed when startup is completed
---@field restore_on_setup boolean: If true, automatically restore session on nvim startup
---@field warn_on_setup boolean: If true, warning shown when no `.session.vim` is found
---@field autosave_on_quit boolean: If true, automatically overwrites sessionfile if exists
---@field save_session_global_dir string
--                        dir path to where global session files should be stored.
--                        global sessions will show up in startify screen as dirname of the session
---@field sessionfile_name string: default name of sessionfile. better be .gitignored
---@field disable_envvar string: name of environment variable to disable this plugin altogether

---@type autosession.Config
local DEFAULT_OPTS = {
  msg = nil,
  restore_on_setup = false,
  warn_on_setup = false,
  autosave_on_quit = false,
  save_session_global_dir = vim.g.startify_session_dir or vim.fn.stdpath("data") .. "/session",
  sessionfile_name = ".session.vim",
  disable_envvar = "NVIM_DISABLE_AUTOSESSION",
}

---@type autosession.Config
local M = {}

local merge_options = function(opts, default)
  return vim.tbl_deep_extend("force", default, opts or {})
end

---load_opts
-- Merge user opts to DEFAULT_OPTS
---@param opts autosession.Config | nil: Options from user setup
M.set_options = function(opts)
  for key, value in pairs(merge_options(opts, DEFAULT_OPTS)) do
    M[key] = value
  end
end

return M
