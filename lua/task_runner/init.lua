local M = {}

local config = {
	providers = {
		make = true,
		just = true,
		rake = true,
		invoke = true,
		cargo = true,
	},
}

local providers = {}

local function load_providers()
	local provider_files = vim.fn.globpath("lua/task_runner/providers", "*.lua", false, true)
	for _, file_path in ipairs(provider_files) do
		local provider_name = vim.fn.fnamemodify(file_path, ":t:r")
		if config.providers[provider_name] then
			local ok, provider = pcall(require, "task_runner.providers." .. provider_name)
			if ok then
				provider.name = provider_name
				table.insert(providers, provider)
			else
				print("Error loading provider '" .. provider_name .. "': " .. provider)
			end
		end
	end
end

local function find_root()
	return vim.fn.fnamemodify(vim.fn.finddir(".git", ";"), ":h")
end

local function find_tasks(root)
	local files = {}
	for _, provider in ipairs(providers) do
		local file_path = root .. "/" .. provider.file_pattern
		if vim.fn.filereadable(file_path) == 1 then
			table.insert(files, { path = file_path, provider = provider })
		end
	end
	return files
end

local function parse_tasks(task_files)
	local tasks = {}
	for _, file in ipairs(task_files) do
		local provider = file.provider
		local ok, parsed_tasks = pcall(provider.parse, file.path)
		if ok then
			for _, task in ipairs(parsed_tasks) do
				table.insert(tasks, task)
			end
		else
			print("Error parsing with provider '" .. provider.name .. "': " .. parsed_tasks)
		end
	end
	return tasks
end

local function run_task(task)
	local width = 120
	local height = 40
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = " Task Output ",
	}
	local cmd = task.file_type .. " " .. task.name
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
	local _ = vim.api.nvim_open_win(buf, true, win_opts)
	vim.fn.termopen(cmd)
end

local function display(tasks)
	local lines = {}
	if #tasks == 0 then
		table.insert(lines, "No tasks found.")
	else
		for _, task in ipairs(tasks) do
			table.insert(lines, string.format("[%s] %-20s", task.file_type, task.name))
		end
	end

	local width = 50
	local height = #lines
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
		title = "Task Runner",
	}
	local win = vim.api.nvim_open_win(buf, true, win_opts)

	if #tasks > 0 then
		vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
			noremap = true,
			silent = true,
			callback = function()
				local line_nr = vim.api.nvim_win_get_cursor(0)[1]
				local task = tasks[line_nr]
				vim.api.nvim_win_close(win, true)
				run_task(task)
			end,
		})
	end
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	load_providers()
end

function M.run()
	local root = find_root()
	if not root then
		print("No project root found.")
		return
	end

	local files = find_tasks(root)
	if #files == 0 then
		print("No task files found.")
		return
	end

	local tasks = parse_tasks(files)
	display(tasks)
end

M.run_task = run_task

return M
