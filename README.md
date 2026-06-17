# taskrunner.nvim

A lightweight, zero-configuration task runner integration for Neovim. Discover and execute project tasks from your favorite task runners in an elegant floating terminal.

![Display](https://raw.githubusercontent.com/cetanu/taskrunner.nvim/refs/heads/master/img/display.png)

## Features

- **Auto-Discovery:** scans your project root (detects `.git` directories or falls back to CWD) for task runners and parses their tasks.
- **Numeric Shortcuts:** Execute tasks instantly by pressing their assigned number (e.g. `1` for task 1, `10` for task 10)
- **Terminal Output:** Runs tasks inside a floating terminal window inside neovim. Automatically scrolls to follow execution.

---

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "cetanu/taskrunner.nvim",
  event = "VeryLazy",
  opts = {
    providers = {
      make = true,
      just = true,
      rake = true,
      invoke = true,
      cargo = true,
      mise = true,
    },
    -- Define the order in which tasks from different providers are displayed
    provider_order = { "make", "just", "rake", "invoke", "cargo", "mise" },
  },
  keys = {
    { "<leader>tr", "<cmd>TaskRunner<cr>", desc = "Open TaskRunner" },
  },
}
```

---

## Configuration

You can customize the enabled providers and their priority. The default setup is:

```lua
require("task_runner").setup({
  -- Enable/disable specific providers
  providers = {
    make = true,
    just = true,
    rake = true,
    invoke = true,
    cargo = true,
    mise = true,
  },
  -- Control display hierarchy (providers not listed here appear at the end)
  provider_order = { "make", "just", "rake", "invoke", "cargo", "mise" },
})
```

### Supported Providers

- **Makefile** (`make`) – parses standard rule targets (ignores `.PHONY`, `.SILENT`).
- **Justfile** (`just`) – parses recipes from `justfile`.
- **Mise** (`mise`) – parses tasks from `mise.toml`/`.mise.toml` as well as task scripts in `.mise/tasks`, `.mise-tasks`, `mise-tasks`, and `mise/tasks`.
- **Invoke** (`invoke`) – parses task definitions from Python `tasks.py`.
- **Rakefile** (`rake`) – parses rake tasks.
- **Cargo** (`cargo`) – provides shortcut tasks (`check`, `clippy`, `test`, `build`, `build --release`) when a `Cargo.toml` is detected.

---

## Usage

1. Run the user command to list available tasks:
   ```vim
   :TaskRunner
   ```
2. In the floating selection window:
   - **Navigate** using regular Vim motion keys (`j`, `k`, etc.).
   - **Select** a task using `<CR>` (Enter).
   - **Instant Select:** Type the task's corresponding number (e.g. `1` or `12`) to run it immediately without pressing Enter.
   - **Close** the selector menu at any time with `<Esc>` or `q`.
3. In the output window:
   - The task runs inside a floating terminal.
   - **Close** the terminal buffer with `<Esc>` or `q`.


---

## Highlights

Customize the look of the floating windows using standard Neovim highlight groups:

```lua
-- Customize these in your colorscheme config or init.lua
vim.api.nvim_set_hl(0, "TaskRunnerIndexOdd", { fg = "#7AA2F7" })
vim.api.nvim_set_hl(0, "TaskRunnerIndexEven", { fg = "#7DCFFF" })
vim.api.nvim_set_hl(0, "TaskRunnerProvider", { fg = "#888888" })
```

---

## Contributing

If you want to add support for another task runner provider:

1. Create a file under `lua/task_runner/providers/your_provider.lua`.
2. Implement the following interface:
   ```lua
   local M = {}

   -- A string pattern or a table of patterns representing target files
   M.file_pattern = "your_config_file"

   -- Parse function that takes the file path and returns a list of tasks
   -- Each task must be a table with { name = "task_name", file_type = "provider_command" }
   function M.parse(file_path)
       local tasks = {}
       -- ... read file and populate tasks table ...
       return tasks
   end

   return M
   ```
3. Submit a pull request
