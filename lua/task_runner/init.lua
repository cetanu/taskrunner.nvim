local M = {}

local config = {
	providers = {
		make = true,
		just = true,
		rake = true,
		invoke = true,
		cargo = true,
	},
	provider_order = { "make", "just", "rake", "invoke", "cargo" },
}

local providers = {}

local function load_providers()
	for provider_name, _ in pairs(config.providers) do
		local ok, provider = pcall(require, "task_runner.providers." .. provider_name)
		if ok then
			provider.name = provider_name
			table.insert(providers, provider)
		else
			print("Error loading provider '" .. provider_name .. "': " .. provider)
		end
	end
end

local function find_root()
	local git_root = vim.fn.fnamemodify(vim.fn.finddir(".git", ";"), ":h")
	if git_root ~= "" and git_root ~= "." then
		return git_root
	else
		-- Fall back to current working directory if no git repo found
		return vim.fn.getcwd()
	end
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

local function sort_tasks_by_provider(tasks)
	-- Create a lookup table for provider order
	local order_map = {}
	for index, provider_name in ipairs(config.provider_order) do
		order_map[provider_name] = index
	end

	-- Sort tasks based on provider order
	table.sort(tasks, function(a, b)
		local order_a = order_map[a.file_type] or 9999
		local order_b = order_map[b.file_type] or 9999
		return order_a < order_b
	end)

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
	local win = vim.api.nvim_open_win(buf, true, win_opts)
	vim.fn.termopen(cmd)
	-- Position cursor at the bottom and follow output
	vim.api.nvim_win_call(win, function()
		vim.cmd("normal! G")
	end)
end

local function display(tasks)
	local lines = {}
	if #tasks == 0 then
		table.insert(lines, "No tasks found.")
	else
		for i, task in ipairs(tasks) do
			-- Generate numeric key label for display
			local key_label = tostring(i)
			table.insert(lines, string.format("%s [%s] %-20s", key_label, task.file_type, task.name))
		end
	end

	local width = 60 -- Increased width to accommodate numbers
	local height = math.max(#lines, 1) -- Ensure minimum height of 1
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe") -- Clean up buffer when hidden
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
		-- Keep the original Enter key binding for cursor-based selection
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

		-- Add numeric keybindings for direct task execution
		-- Users type the task number (e.g., "1" for task 1, "1" "0" for task 10)
		for i, task in ipairs(tasks) do
			local key = tostring(i)
			vim.api.nvim_buf_set_keymap(buf, "n", key, "", {
				noremap = true,
				silent = true,
				callback = function()
					vim.api.nvim_win_close(win, true)
					run_task(task)
				end,
			})
		end
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
		local provider_patterns = {}
		for _, provider in ipairs(providers) do
			table.insert(provider_patterns, provider.file_pattern)
		end
		local debug_msg = string.format(
			"No task files found.\nRoot: %s\nLooking for: %s\nProviders loaded: %d",
			root,
			table.concat(provider_patterns, ", "),
			#providers
		)
		vim.notify(debug_msg, vim.log.levels.WARN)
		return
	end

	local tasks = parse_tasks(files)
	tasks = sort_tasks_by_provider(tasks)
	display(tasks)
end

M.run_task = run_task
M._sort_tasks_by_provider = sort_tasks_by_provider -- Exposed for testing

return M
