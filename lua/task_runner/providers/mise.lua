local M = {}

M.file_pattern = { "mise.toml", ".mise.toml" }

local function clean_name(name)
	name = name:match("^%s*(.-)%s*$")
	if (name:sub(1, 1) == '"' and name:sub(-1, -1) == '"') or
	   (name:sub(1, 1) == "'" and name:sub(-1, -1) == "'") then
		name = name:sub(2, -2)
	end
	return name
end

function M.parse(file_path)
	local tasks = {}
	local seen = {}

	-- 1. Parse from mise.toml / .mise.toml
	if vim.fn.filereadable(file_path) == 1 then
		local file_content = vim.fn.readfile(file_path)
		local in_tasks_section = false

		for _, line in ipairs(file_content) do
			if line:match("^%s*$") then
				-- empty line
			elseif line:match("^%s*#") then
				-- comment line
			else
				-- Strip comment for header check
				local clean_line = line:gsub("%s*#.*$", "")
				local header = clean_line:match("^%s*%[%s*(.-)%s*%]%s*$")
				if header then
					local rest = header:match("^tasks%.(.*)$")
					if rest then
						local task_name
						local first_char = rest:sub(1, 1)
						if first_char == '"' or first_char == "'" then
							local closing_pos = rest:find(first_char, 2, true)
							if closing_pos then
								task_name = rest:sub(2, closing_pos - 1)
							else
								task_name = rest
							end
						else
							task_name = rest:match("^([^%.]+)")
						end
						if task_name then
							task_name = clean_name(task_name)
							if not seen[task_name] then
								seen[task_name] = true
								table.insert(tasks, { name = task_name, file_type = "mise run" })
							end
						end
						in_tasks_section = false
					elseif header == "tasks" then
						in_tasks_section = true
					else
						in_tasks_section = false
					end
				elseif in_tasks_section then
					local raw_key = line:match("^%s*([^=]+)%s*=")
					if raw_key then
						local task_name = clean_name(raw_key)
						if not seen[task_name] then
							seen[task_name] = true
							table.insert(tasks, { name = task_name, file_type = "mise run" })
						end
					end
				end
			end
		end
	end

	-- 2. Scan tasks directory
	local root = vim.fn.fnamemodify(file_path, ":h")
	local task_dirs = {
		root .. "/.mise/tasks",
		root .. "/.mise-tasks",
		root .. "/mise-tasks",
		root .. "/mise/tasks",
	}

	for _, dir in ipairs(task_dirs) do
		if vim.fn.isdirectory(dir) == 1 then
			local files = vim.fn.readdir(dir)
			for _, file in ipairs(files) do
				if not file:match("^%.") then
					-- Extract task name (strip extension)
					local task_name = file:match("^([^%.]+)")
					if task_name then
						task_name = clean_name(task_name)
						if not seen[task_name] then
							seen[task_name] = true
							table.insert(tasks, { name = task_name, file_type = "mise run" })
						end
					end
				end
			end
		end
	end

	return tasks
end

return M
