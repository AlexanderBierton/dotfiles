-- vim.opt.clipboard = "unnamedplus"
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- adds the bar to the right
-- vim.opt.colorcolumn = 80

vim.g.mapleader = " "

vim.g.netrw_liststyle = 3

--disable netrw at the very start of your init.lia
-- vim.g.loaded_netrw = 1
-- vim.g.loadednetrwPlugin = 1

-- Force Node.js (and ts_ls) to garbage collect when it hits ~1GB of RAM
vim.env.NODE_OPTIONS = "--max-old-space-size=1024"
