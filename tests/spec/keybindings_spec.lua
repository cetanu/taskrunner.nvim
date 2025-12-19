-- Helper function to generate numeric keybindings for tasks (extracted from main logic)
-- This mirrors the logic in lua/task_runner/init.lua display() function
-- Now uses numeric-only keybindings (1, 2, 3, ... 10, 11, ...)
local function generate_keybindings(tasks)
	local keybindings = {}
	for i, task in ipairs(tasks) do
		local key = tostring(i)
		table.insert(keybindings, { key = key, task = task })
	end
	return keybindings
end

-- Helper function to generate numeric key labels for display
-- This mirrors the logic in lua/task_runner/init.lua display() function
local function generate_key_label(i)
	return tostring(i)
end

describe("task_runner keybindings", function()
	it("creates numeric keybindings for all tasks", function()
		local tasks = {
			{ name = "task1", file_type = "make" },
			{ name = "task2", file_type = "make" },
			{ name = "task3", file_type = "make" },
			{ name = "task4", file_type = "make" },
			{ name = "task5", file_type = "make" },
			{ name = "task6", file_type = "make" },
			{ name = "task7", file_type = "make" },
			{ name = "task8", file_type = "make" },
			{ name = "task9", file_type = "make" },
		}

		local keybindings = generate_keybindings(tasks)

		assert.are.equal(9, #keybindings)
		for i = 1, 9 do
			assert.are.equal(tostring(i), keybindings[i].key)
			assert.are.equal("task" .. i, keybindings[i].task.name)
		end
	end)

	it("creates numeric keybindings for tasks beyond 9", function()
		local tasks = {}
		for i = 1, 50 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		-- All 50 tasks should have numeric keybindings
		assert.are.equal(50, #keybindings)

		-- First 9 should be 1-9
		for i = 1, 9 do
			assert.are.equal(tostring(i), keybindings[i].key)
		end

		-- Next tasks should be 10, 11, 12, ...
		for i = 10, 50 do
			assert.are.equal(tostring(i), keybindings[i].key)
		end
	end)

	it("creates keybindings for unlimited number of tasks", function()
		local tasks = {}
		for i = 1, 100 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		-- All 100 tasks should have numeric keybindings
		assert.are.equal(100, #keybindings)
		assert.are.equal("1", keybindings[1].key)
		assert.are.equal("100", keybindings[100].key)
	end)

	it("correctly maps keybindings to tasks", function()
		local tasks = {
			{ name = "build", file_type = "make" },
			{ name = "test", file_type = "make" },
			{ name = "deploy", file_type = "make" },
			{ name = "archive", file_type = "cargo" },
		}

		local keybindings = generate_keybindings(tasks)

		assert.are.equal("1", keybindings[1].key)
		assert.are.equal("build", keybindings[1].task.name)

		assert.are.equal("2", keybindings[2].key)
		assert.are.equal("test", keybindings[2].task.name)

		assert.are.equal("3", keybindings[3].key)
		assert.are.equal("deploy", keybindings[3].task.name)

		assert.are.equal("4", keybindings[4].key)
		assert.are.equal("archive", keybindings[4].task.name)
	end)

	it("handles single task correctly", function()
		local tasks = {
			{ name = "build", file_type = "make" },
		}

		local keybindings = generate_keybindings(tasks)

		assert.are.equal(1, #keybindings)
		assert.are.equal("1", keybindings[1].key)
		assert.are.equal("build", keybindings[1].task.name)
	end)

	it("handles empty task list", function()
		local tasks = {}

		local keybindings = generate_keybindings(tasks)

		assert.are.equal(0, #keybindings)
	end)

	it("transitions correctly to double-digit keys at position 10", function()
		local tasks = {}
		for i = 1, 12 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		assert.are.equal("9", keybindings[9].key)
		assert.are.equal("10", keybindings[10].key)
		assert.are.equal("11", keybindings[11].key)
		assert.are.equal("12", keybindings[12].key)
	end)

	it("generates correct numeric key labels for display", function()
		-- Test numeric labels for single digits
		for i = 1, 9 do
			assert.are.equal(tostring(i), generate_key_label(i))
		end

		-- Test numeric labels for double digits
		for i = 10, 20 do
			assert.are.equal(tostring(i), generate_key_label(i))
		end

		-- Test numeric labels for large numbers
		assert.are.equal("99", generate_key_label(99))
		assert.are.equal("100", generate_key_label(100))
		assert.are.equal("1000", generate_key_label(1000))
	end)

	it("maps numeric keys sequentially for many tasks", function()
		local tasks = {}
		for i = 1, 100 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		-- Verify sequential numeric mapping
		for i = 1, 100 do
			assert.are.equal(tostring(i), keybindings[i].key)
			assert.are.equal("task" .. i, keybindings[i].task.name)
		end
	end)

	it("creates numeric keybindings without gaps or limits", function()
		local tasks = {}
		for i = 1, 50 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		assert.are.equal(50, #keybindings)
		assert.are.equal("1", keybindings[1].key)
		assert.are.equal("10", keybindings[10].key)
		assert.are.equal("25", keybindings[25].key)
		assert.are.equal("50", keybindings[50].key)
	end)

	it("handles task 10 correctly at the double-digit boundary", function()
		local tasks = {}
		for i = 1, 12 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		-- Verify single-digit tasks
		assert.are.equal("9", keybindings[9].key)
		assert.are.equal("task9", keybindings[9].task.name)

		-- Verify transition to double digits
		assert.are.equal("10", keybindings[10].key)
		assert.are.equal("task10", keybindings[10].task.name)

		assert.are.equal("11", keybindings[11].key)
		assert.are.equal("task11", keybindings[11].task.name)
	end)
end)
