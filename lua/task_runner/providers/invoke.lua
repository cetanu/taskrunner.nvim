local M = {}

M.file_pattern = "tasks.py"

function M.parse(file_path)
    local tasks = {}
    local file_content = vim.fn.readfile(file_path)
    for i, line in ipairs(file_content) do
        if line:match("^@task") then
            local next_line = file_content[i + 1]
            if next_line then
                local task_name = next_line:match("^def%s+([%w_]+)")
                if task_name then
                    table.insert(tasks, {name = task_name, file_type = "invoke"})
                end
            end
        end
    end
    return tasks
end

return M