# taskrunner.nvim

Make it convenient to run your tasks from within Neovim, for many different task runner providers

## Providers

* Makefile
* Justfile
* Rakefile
* Invoke
* Cargo (kinda)

Feel free to contribute your own provider!

## Install

```lua
{
    "cetanu/taskrunner.nvim",
    event = "VeryLazy",
    config = function()
      require("task_runner").setup({
        providers = {
          make = true,
          just = true,
          rake = true,
          invoke = true,
          cargo = true,
        }
      })
    end,
}
```
