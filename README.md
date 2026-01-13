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
        },
        -- Optional: Define the order in which tasks from different providers are displayed
        provider_order = { "make", "just", "rake", "invoke", "cargo" },
      })
    end,
}
```

## Configuration

### Provider Order

By default, tasks are displayed in the order they are discovered. You can control the display order by setting the `provider_order` option in your configuration:

```lua
require("task_runner").setup({
  providers = {
    make = true,
    cargo = true,
    just = true,
  },
  provider_order = { "cargo", "make", "just" },  -- cargo tasks first, then make, then just
})
```

Tasks from providers not listed in `provider_order` will appear at the end. Tasks within the same provider maintain their original order.

## Usage

Inside your project, use the command `:TaskRunner`

Which will show a list of tasks you can execute.

![Display](https://raw.githubusercontent.com/cetanu/taskrunner.nvim/refs/heads/master/img/display.png)

Navigate using regular vim motions and select task with `<enter>`

Upon selection, a window will display the output

![Output](https://raw.githubusercontent.com/cetanu/taskrunner.nvim/refs/heads/master/img/output.png)
