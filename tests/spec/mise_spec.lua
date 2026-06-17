local Path = require("plenary.path")

describe("mise provider", function()
	it("parses mise.toml tasks correctly", function()
		local tmp_file = Path:new(vim.fn.tempname())
		tmp_file:touch()

		tmp_file:write([=[
[tasks]
build = "cargo build"
test = 'cargo test'

[tasks.deploy]
run = "cargo publish"

[tasks."release-prod"]
run = "cargo release"

[tasks.'lint:check']
run = "cargo clippy"

[tools]
node = "20"
]=], "w")

		local mise_provider = require("task_runner.providers.mise")
		local tasks = mise_provider.parse(tmp_file:absolute())

		assert.are.same({
			{ name = "build", file_type = "mise run" },
			{ name = "test", file_type = "mise run" },
			{ name = "deploy", file_type = "mise run" },
			{ name = "release-prod", file_type = "mise run" },
			{ name = "lint:check", file_type = "mise run" },
		}, tasks)

		tmp_file:rm()
	end)

	it("scans task directories correctly", function()
		-- Create a temporary project directory
		local tmp_dir = Path:new(vim.fn.tempname() .. "_proj")
		tmp_dir:mkdir({ parents = true })

		local toml_file = tmp_dir:joinpath("mise.toml")
		toml_file:write("[tasks]\nhello = 'echo hello'\n", "w")

		-- Create a task directory .mise/tasks
		local tasks_dir = tmp_dir:joinpath(".mise", "tasks")
		tasks_dir:mkdir({ parents = true })

		-- Create mock scripts in it
		local script_build = tasks_dir:joinpath("build-app.sh")
		script_build:write("echo build", "w")
		local script_deploy = tasks_dir:joinpath("deploy-app")
		script_deploy:write("echo deploy", "w")

		local mise_provider = require("task_runner.providers.mise")
		local tasks = mise_provider.parse(toml_file:absolute())

		-- Sort tasks by name to make assertion order independent of file listing order
		table.sort(tasks, function(a, b) return a.name < b.name end)

		assert.are.same({
			{ name = "build-app", file_type = "mise run" },
			{ name = "deploy-app", file_type = "mise run" },
			{ name = "hello", file_type = "mise run" },
		}, tasks)

		-- Clean up
		script_build:rm()
		script_deploy:rm()
		tasks_dir:rm()
		toml_file:rm()
		tmp_dir:rm()
	end)
end)
