-- keymaps needs set before lazy
require("user.globals")
require("user.keymaps")
require("user.settings")
require("user.lazy_bootstrap")

-- load plugins in lsp/plugins
require("lazy").setup("plugins", {
	install = {
		missing = false,
		colorscheme = { "dracula" },
	},
	checker = {
		enabled = true,
		notify = true,
		frequency = 7200, -- 2 hours
	},
})
