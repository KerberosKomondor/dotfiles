return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
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
			})
		end,
	},
}
