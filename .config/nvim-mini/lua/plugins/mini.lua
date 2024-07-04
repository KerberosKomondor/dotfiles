return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		require("mini.basics").setup({
			options = {
				extra_ui = true,
				win_borders = "single",
			},
			mappings = {
				windows = true,
				move_with_alt = true,
			},
		})

		require("mini.bufremove").setup()

		local miniclue = require("mini.clue")
		miniclue.setup({
			triggers = {
				-- Leader triggers
				{ mode = "n", keys = "<Leader>" },
				{ mode = "x", keys = "<Leader>" },

				-- Built-in completion
				{ mode = "i", keys = "<C-x>" },

				-- `g` key
				{ mode = "n", keys = "g" },
				{ mode = "x", keys = "g" },

				-- Marks
				{ mode = "n", keys = "'" },
				{ mode = "n", keys = "`" },
				{ mode = "x", keys = "'" },
				{ mode = "x", keys = "`" },

				-- Registers
				{ mode = "n", keys = '"' },
				{ mode = "x", keys = '"' },
				{ mode = "i", keys = "<C-r>" },
				{ mode = "c", keys = "<C-r>" },

				-- Window commands
				{ mode = "n", keys = "<C-w>" },

				-- `z` key
				{ mode = "n", keys = "z" },
				{ mode = "x", keys = "z" },
			},

			clues = {
				-- Enhance this by adding descriptions for <Leader> mapping groups
				miniclue.gen_clues.builtin_completion(),
				miniclue.gen_clues.g(),
				miniclue.gen_clues.marks(),
				miniclue.gen_clues.registers(),
				miniclue.gen_clues.windows(),
				miniclue.gen_clues.z(),
			},
		})

		require("mini.colors").setup()

		require("mini.comment").setup()

		require("mini.diff").setup()

		require("mini.doc").setup()

		require("mini.files").setup()

		require("mini.fuzzy").setup()

		require("mini.git").setup()

		require("mini.icons").setup()

		require("mini.indentscope").setup()

		require("mini.move").setup()

		require("mini.pairs").setup()

		require("mini.sessions").setup()

		require("mini.splitjoin").setup()

		require("mini.starter").setup()

		require("mini.statusline").setup()

		require("mini.surround").setup()

		require("mini.tabline").setup()
		vim.cmd([[highlight BufferCurrent guibg=#44475a]])
		vim.cmd([[highlight BufferInactive guibg=#282a36]])
		vim.cmd([[highlight BufferVisible guibg=#282a36]])

		vim.cmd([[highlight BufferCurrentMod guifg=#bd93f9]])
		vim.cmd([[highlight BufferInactiveMod guifg=#bd93f9]])
		vim.cmd([[highlight BufferVisibleMod guifg=#bd93f9]])

		vim.cmd([[highlight link BufferCurrentIcon BufferCurrent]])
		vim.cmd([[highlight link BufferInactiveIcon BufferInactive]])
		vim.cmd([[highlight link BufferVisibleIcon BufferVisible]])

		require("mini.trailspace").setup()

		require("mini.visits").setup()
	end,
}
