local getOpts = function(desc)
  return { noremap = true, silent = true, desc = desc }
end

-- Shorten function name
local keymap = vim.keymap.set

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", getOpts(''))
keymap("", "<C-Space>", "<Nop>", getOpts(''))
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Close buffer
keymap("n", "C", "<cmd>bdelete<cr>", getOpts('close buffer'))

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", getOpts('move left'))
keymap("n", "<C-j>", "<C-w>j", getOpts('move down'))
keymap("n", "<C-l>", "<C-w>l", getOpts('move right'))
keymap("n", "<C-k>", "<C-w>k", getOpts('move up'))

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", getOpts('resize -2'))
keymap("n", "<C-Down>", ":resize +2<CR>", getOpts('resize +2'))
keymap("n", "<C-Left>", ":vertical resize -2<CR>", getOpts('vertical resize -2'))
keymap("n", "<C-Right>", ":vertical resize +2<CR>", getOpts('vertical resize +2'))

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", getOpts('next buffer'))
keymap("n", "<S-h>", ":bprevious<CR>", getOpts('previous buffer'))

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", getOpts('move text up'))
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", getOpts('move text down'))

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", getOpts('indent left'))
keymap("v", ">", ">gv", getOpts('indent right'))

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", getOpts('move text up'))
keymap("v", "<A-k>", ":m .-2<CR>==", getOpts('move text down'))

-- Terminal --
-- Better terminal navigation
-- keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
