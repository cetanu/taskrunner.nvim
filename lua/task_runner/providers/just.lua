local M = {}

M.file_pattern = "justfile"

function M.parse(file_path)
    local tasks = {}
    local file_content = vim.fn.readfile(file_path)
    for _, line in ipairs(file_content) do
        local task_name = line:match("^([%w_-]+):")
        if task_name and not task_name:find("#") then
            table.insert(tasks, {name = task_name, file_type = "just"})
        end
    end
    return tasks
end

return M