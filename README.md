# autosession.nvim

## Plugin to Save and Restore Sessions Per-directory

This plugin allows saving sessions per-directory, which will be resumed next time you open nvim in that directory.

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

## Demo

`:AutoSessionSave`

<!-- ![autosession-save-demo](./figures/demo-gif/restore-session.GIF) -->

## Tips

### Recommended Dependencies

### [Startify](https://github.com/mhinz/vim-startify)

By calling `AutoSessionGlobal`, this plugin will register the current session as a session in Startify's menu screen.

<!-- ![autosession-global-demo](./figures/demo-gif/as-global.gif) -->

### [nvim-notify](https://github.com/rcarriga/nvim-notify)

Enhances help menu for this plugin

<!-- ![nvim-notify-notification-capture](./figures/notifications/nvim-notify.png) -->

## Please Read

### Known Issues - Notifications Cause Weird Session

This plugin has an issue that fails to restore the session when `AutoSessionSave` is called when a notification is on the screen. Notifications are created with plugins such as.

- [Neogit](https://github.com/TimUntersberger/neogit)
  <!-- - <img src="./figures/notifications/neogit.png" alt="neogit-notification-capture" height="100"/> -->
- [fidget.nvim](https://github.com/j-hui/fidget.nvim)
  <!-- - <img src="./figures/notifications/fidget.png" alt="fidget-notification-capture" height="100"/> -->
- [nvim-notify](https://github.com/rcarriga/nvim-notify)
  <!-- - <img src="./figures/notifications/nvim-notify.png" alt="nvim-notify-notification-capture" height="100"/> -->

When notification is detected, this will be prompt.
Please press _ENTER_ or `y` after the notifications are gone.

```text
May crush. Please wait until all Notification are gone. Continue? [Y/n]:
```

#### How to Fix

In order for this plugin to detect these notifications, please add these commands in their configs.

- `require("autosession").add_win_open()`
  - When notification opens
- `require("autosession").close_win_open()`
  - When notification closes
- `require("autosession").add_win_open_timer(<wait_time>)`
  - When notification will close in `<wait_time>` milliseconds

The following scripts will be a recommended config to add to the setup of the plugins above.

- [Neogit](https://github.com/TimUntersberger/neogit)
  ```lua
  require("neogit").setup({
    disable_builtin_notifications = true
  })
  ```
- [fidget.nvim](https://github.com/j-hui/fidget.nvim)

  ```lua
  require("fidget").setup({
    -- https://github.com/j-hui/fidget.nvim/blob/main/doc/fidget.txt#L102
    fmt = {
      fidget = function(fig_name, spinner)
        require("autosession").add_win_open_timer(2000)
        return string.format("%s %s", spinner, fig_name)
      end,
      task = function(task_name, message, percentage)
        require("autosession").add_win_open_timer(1000)
        return string.format(
          "%s%s [%s]",
          message,
          percentage and string.format(" (%s%%)", percentage) or "",
          task_name
        )
      end,
    },
  })
  ```

- [nvim-notify](https://github.com/rcarriga/nvim-notify)
  ```lua
  require("notify").setup({
    on_open = function()
      require("autosession").add_win_open()
    end,
    on_close = function()
      require("autosession").close_win_open()
    end,
  })
  ```
