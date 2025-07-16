local M = {}

M.file_pattern = "Makefile"

function M.parse(file_path)
    local tasks = {}
    local file_content = vim.fn.readfile(file_path)
    for _, line in ipairs(file_content) do
        local task_name = line:match("^(%S+):")
        if task_name and not task_name:find("#") and not task_name:find("%.PHONY") and not task_name:find("%.SILENT") then
            table.insert(tasks, {name = task_name, file_type = "make"})
        end
    end
    return tasks
end

return M