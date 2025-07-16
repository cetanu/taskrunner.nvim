local M = {}

M.file_pattern = "Cargo.toml" -- a cargo manifest exists in the repo

function M.parse(_)
	local tasks = {
		{ name = "check", file_type = "cargo" },
		{ name = "clippy", file_type = "cargo" },
		{ name = "test", file_type = "cargo" },
		{ name = "build", file_type = "cargo" },
		{ name = "build --release", file_type = "cargo" },
	}
	return tasks
end

return M
