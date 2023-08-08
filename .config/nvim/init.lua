-- keymaps needs set before lazy
require("user.globals")
require("user.keymaps")
require("user.settings")
require("user.lazy_bootstrap")
require("user.lsp-keybindings")

-- load plugins in lsp/plugins
require("lazy").setup("plugins", {
	install = {
		missing = false,
		colorscheme = { "dracula" },
	},
	checker = {
		enabled = true,
		notify = false,
		frequency = 14400, -- 4 hours
	},
})
