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

## Usage

Inside your project, use the command `:TaskRunner`

Which will show a list of tasks you can execute.

![Display](https://raw.githubusercontent.com/cetanu/taskrunner.nvim/refs/heads/master/img/display.png)

Navigate using regular vim motions and select task with `<enter>`

Upon selection, a window will display the output

![Output](https://raw.githubusercontent.com/cetanu/taskrunner.nvim/refs/heads/master/img/output.png)
