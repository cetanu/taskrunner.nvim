describe("task ordering", function()
	it("orders tasks by provider according to provider_order config", function()
		local task_runner = require("task_runner")

		-- Setup with custom provider order
		task_runner.setup({
			providers = {
				make = true,
				cargo = true,
				just = true,
			},
			provider_order = { "cargo", "make", "just" },
		})

		-- Create mock tasks from different providers
		local tasks = {
			{ name = "build", file_type = "make" },
			{ name = "test", file_type = "cargo" },
			{ name = "lint", file_type = "just" },
			{ name = "deploy", file_type = "make" },
			{ name = "check", file_type = "cargo" },
		}

		-- Sort using the internal function
		local sorted = task_runner._sort_tasks_by_provider(tasks)

		-- Expected order: cargo tasks first, then make, then just
		assert.are.equal("cargo", sorted[1].file_type)
		assert.are.equal("cargo", sorted[2].file_type)
		assert.are.equal("make", sorted[3].file_type)
		assert.are.equal("make", sorted[4].file_type)
		assert.are.equal("just", sorted[5].file_type)
	end)

	it("handles providers not in provider_order list", function()
		local task_runner = require("task_runner")

		task_runner.setup({
			providers = {
				make = true,
				cargo = true,
			},
			provider_order = { "make" }, -- cargo not specified
		})

		local tasks = {
			{ name = "build", file_type = "cargo" },
			{ name = "test", file_type = "make" },
		}

		local sorted = task_runner._sort_tasks_by_provider(tasks)

		-- make should come first (in order list), cargo should be last
		assert.are.equal("make", sorted[1].file_type)
		assert.are.equal("cargo", sorted[2].file_type)
	end)

	it("preserves task order within same provider", function()
		local task_runner = require("task_runner")

		task_runner.setup({
			providers = {
				make = true,
			},
			provider_order = { "make" },
		})

		local tasks = {
			{ name = "build", file_type = "make" },
			{ name = "test", file_type = "make" },
			{ name = "deploy", file_type = "make" },
		}

		local sorted = task_runner._sort_tasks_by_provider(tasks)

		-- Order should be preserved
		assert.are.equal("build", sorted[1].name)
		assert.are.equal("test", sorted[2].name)
		assert.are.equal("deploy", sorted[3].name)
	end)
end)
