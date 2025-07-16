-- Plugin entry point

-- Define the user command
vim.api.nvim_create_user_command(
    'TaskRunner',
    function()
        require('task_runner').run()
    end,
    {}
)

vim.api.nvim_set_hl(0, "TaskRunnerProvider", { fg = "#888888" })

-- Call the setup function
require('task_runner').setup()