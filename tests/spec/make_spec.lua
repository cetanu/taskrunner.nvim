local Path = require("plenary.path")

describe("make provider", function()
	it("parses a Makefile correctly", function()
		local tmp_file = Path:new(vim.fn.tempname())
		tmp_file:touch()

		tmp_file:write("build: ## Build the project\n\tcargo build\n", "w")
		tmp_file:write("test: build ## Run the tests\n\tcargo test\n", "a")
		tmp_file:write("deploy: ## Deploy the project\n\tcargo publish\n", "a")

		local make_provider = require("task_runner.providers.make")
		local tasks = make_provider.parse(tmp_file:absolute())

		assert.are.same({
			{ name = "build", file_type = "make" },
			{ name = "test", file_type = "make" },
			{ name = "deploy", file_type = "make" },
		}, tasks)

		tmp_file:rm()
	end)
end)
