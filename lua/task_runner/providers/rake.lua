local M = {}

M.file_pattern = "Rakefile"

function M.parse(file_path)
    local tasks = {}
    local file_content = vim.fn.readfile(file_path)
    for _, line in ipairs(file_content) do
        local task_name = line:match("^task%s+:([%w_:]+)")
        if task_name then
            table.insert(tasks, {name = task_name, file_type = "rake"})
        end
    end
    return tasks
end

return M