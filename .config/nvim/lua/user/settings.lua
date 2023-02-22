vim.cmd([[set fcs=eob:\ ]])
vim.cmd([[filetype plugin indent on]])

local options = {
	termguicolors = true,
	fileencoding = "utf-8",
	backup = false,
	swapfile = false,
	hlsearch = true,
	incsearch = true,
	showmode = false,
	expandtab = true,
	shiftwidth = 2,
	tabstop = 2,
	scrolloff = 5,
	sidescrolloff = 5,
	smartindent = true,
	signcolumn = "yes",
	hidden = true,
	ignorecase = true,
	timeoutlen = 1000,
	shiftround = true,
	smartcase = true,
	splitbelow = true,
	splitright = true,
	number = true,
	relativenumber = true,
	clipboard = "unnamedplus",
	cursorline = true,
	mouse = "a",
	cmdheight = 1,
	undodir = "/tmp/.nvimdid",
	undofile = true,
	pumheight = 10,
	laststatus = 3,
	updatetime = 250,
	background = "dark",
  colorcolumn = "120",
  completeopt = { 'menu', 'menuone', 'noselect' },
}

vim.opt.shortmess:append("c")

for key, value in pairs(options) do
	vim.opt[key] = value
end
