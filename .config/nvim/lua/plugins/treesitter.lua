local _M = {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
		},
		"windwp/nvim-ts-autotag",
	},
}

function _M.config()
	local ok, treesitter = pcall(require, "nvim-treesitter.configs")
	if not ok then
		return
	end

	require("nvim-autopairs").setup()
	require("nvim-ts-autotag").setup()

	treesitter.setup({
		ensure_installed = {
			"bash",
			"c_sharp",
			"go",
			"graphql",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"regex",
			"rust",
			"sql",
			"tsx",
			"typescript",
			"vim",
			"yaml",
		},
		auto_install = true,
		context_commentstring = {
			enabled = true,
			enable_autocmd = false,
		},
	})
end

return _M
