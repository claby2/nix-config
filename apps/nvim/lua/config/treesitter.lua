local M = {}

local languages = {
	"python",
	"lua",
	"rust",
	"go",
	"c",
	"cpp",
	"ocaml",
}

M.setup = function()
	require("nvim-treesitter").install(languages)

	vim.api.nvim_create_autocmd("FileType", {
		pattern = languages,
		callback = function()
			vim.treesitter.start()
		end,
	})
end

return M
