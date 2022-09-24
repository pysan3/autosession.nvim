# autosession.nvim

## Plugin to Save and Restore Sessions Per-directory

This plugin allows saving sessions per-directory, which will be resumed next time you open nvim in that directory.

## Demo

`:AutoSessionSave`

<img src="https://user-images.githubusercontent.com/41065736/155856720-f9367491-c4ba-47ed-973c-d1e1ac424c65.GIF" alt="restore-session" width="100%"/>

## Install

Install with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'pysan3/autosession.nvim'
```

Install with [packer](https://github.com/wbthomason/packer.nvim):

```lua
use { "pysan3/autosession.nvim" }
```

## Setup

This plugin will only be loaded after `setup` is called. The `setup` function should be called with a lua table with the following keys.

The following values are the default which will be chosen if the keys do not exist.

```lua
require("autosession").setup({
  msg = nil, -- string: printed when startup is completed
  restore_on_setup = false, -- boolean: If true, automatically restore session on nvim startup
  autosave_on_quit = false, -- boolean: If true, automatically overwrites sessionfile if exists
  force_autosave = false, -- boolean: If true, automatically closes session without confirmation
  save_session_global_dir = vim.g.startify_session_dir or vim.fn.stdpath("data") .. "/session", -- string
      -- dir path to where global session files should be stored.
      -- global sessions will show up in startify screen as dirname of the session
  sessionfile_name = ".session.vim", -- string: default name of sessionfile. better be .gitignored
})
```

## Usage

Use the following commands.

- `AutoSession`
  - Show help
- `AutoSessionRestore`
  - Restore previous session from `.session.vim`.
- `AutoSessionSave`
  - Create `.session.vim` to store current session.
- `AutoSessionAuto`
  - Update `.session.vim` **only if exists**.
  - This is called on nvim shutdown (`VimLeave`) if `autosave_on_quit == true`
- `AutoSessionGlobal`
  - Resigter current session for vim-startify.
  - Runs `AutoSessionSave` along the way.
- `AutoSessionDelete`
  - Delete a global session.

## Tips

### Recommended Dependencies

### [Startify](https://github.com/mhinz/vim-startify)

By calling `AutoSessionGlobal`, this plugin will register the current session as a session in Startify's menu screen.

![as-global](https://user-images.githubusercontent.com/41065736/155856692-cf709368-bd24-42d8-8a75-8a45a068a529.gif)

### [nvim-notify](https://github.com/rcarriga/nvim-notify)

Enhances help menu for this plugin

![nvim-notify](https://user-images.githubusercontent.com/41065736/155856293-59d1c3ad-fec6-4008-add8-326fd83ca153.png)
