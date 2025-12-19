-- Helper function to generate keybindings for tasks (extracted from main logic)
-- This mirrors the logic in lua/task_runner/init.lua display() function lines 137-155
local function generate_keybindings(tasks)
	local keybindings = {}
	for i, task in ipairs(tasks) do
		local key
		if i <= 9 then
			key = tostring(i)
		elseif i <= 35 then
			key = string.char(string.byte('a') + i - 10)
		else
			break -- Don't create bindings for tasks beyond 'z'
		end
		table.insert(keybindings, { key = key, task = task })
	end
	return keybindings
end

-- Helper function to generate key labels for display (mirrors lines 91-98)
local function generate_key_label(i)
	local key_label
	if i <= 9 then
		key_label = tostring(i)
	elseif i <= 35 then
		key_label = string.char(string.byte('a') + i - 10)
	else
		key_label = "·" -- bullet point for tasks beyond z
	end
	return key_label
end

describe("task_runner keybindings", function()
	it("creates numeric keybindings 1-9 for first 9 tasks", function()
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

	it("creates alphabetic keybindings a-z for tasks 10-35", function()
		local tasks = {}
		for i = 1, 35 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		assert.are.equal(35, #keybindings)

		-- First 9 should be numeric
		for i = 1, 9 do
			assert.are.equal(tostring(i), keybindings[i].key)
		end

		-- Next 26 should be a-z
		for i = 10, 35 do
			local expected_key = string.char(string.byte('a') + i - 10)
			assert.are.equal(expected_key, keybindings[i].key)
		end
	end)

	it("does not create keybindings for tasks beyond 35", function()
		local tasks = {}
		for i = 1, 40 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		assert.are.equal(35, #keybindings)
		assert.are.equal("z", keybindings[35].key)
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

	it("transitions correctly from numeric to alphabetic keys at position 10", function()
		local tasks = {}
		for i = 1, 12 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		assert.are.equal("9", keybindings[9].key)
		assert.are.equal("a", keybindings[10].key)
		assert.are.equal("b", keybindings[11].key)
		assert.are.equal("c", keybindings[12].key)
	end)

	it("generates correct key labels for display", function()
		-- Test numeric labels
		for i = 1, 9 do
			assert.are.equal(tostring(i), generate_key_label(i))
		end

		-- Test alphabetic labels
		for i = 10, 35 do
			local expected = string.char(string.byte('a') + i - 10)
			assert.are.equal(expected, generate_key_label(i))
		end

		-- Test bullet point for tasks beyond z
		assert.are.equal("·", generate_key_label(36))
		assert.are.equal("·", generate_key_label(100))
	end)

	it("correctly maps all 26 alphabetic keys from a-z", function()
		local expected_keys = {
			"a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
			"k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
			"u", "v", "w", "x", "y", "z"
		}

		for i = 10, 35 do
			local expected_key = expected_keys[i - 9]
			assert.are.equal(expected_key, generate_key_label(i))
		end
	end)

	it("creates exactly 35 keybindings for 35 tasks (1-9, a-z)", function()
		local tasks = {}
		for i = 1, 35 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		assert.are.equal(35, #keybindings)
		assert.are.equal("1", keybindings[1].key)
		assert.are.equal("z", keybindings[35].key)
	end)

	it("respects the boundary between numeric and alphabetic at exactly position 10", function()
		local tasks = {}
		for i = 1, 11 do
			table.insert(tasks, { name = "task" .. i, file_type = "make" })
		end

		local keybindings = generate_keybindings(tasks)

		-- Verify the exact boundary
		assert.are.equal("9", keybindings[9].key)
		assert.are.equal("a", keybindings[10].key)
		assert.are.equal("b", keybindings[11].key)

		-- Verify they map to correct tasks
		assert.are.equal("task9", keybindings[9].task.name)
		assert.are.equal("task10", keybindings[10].task.name)
		assert.are.equal("task11", keybindings[11].task.name)
	end)
end)
