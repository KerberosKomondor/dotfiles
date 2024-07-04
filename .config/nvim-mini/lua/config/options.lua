-- mini.basics does this
-- vim.g.mapleader = ""
-- make all keymaps silent by default
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
	opts = opts or {}
	opts.silent = opts.silent ~= false
	return keymap_set(mode, lhs, rhs, opts)
end

vim.cmd([[highlight clear]])
vim.cmd([[colorscheme dracula]])
