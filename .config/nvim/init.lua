-- keymaps needs set before lazy
require 'user.keymaps'
require 'user.settings'
require 'user.lazy_bootstrap'

-- load plugins in lsp/plugins
require 'lazy'.setup 'plugins'
