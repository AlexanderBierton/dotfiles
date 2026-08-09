vim.g.mapleader = " "
vim.keymap.set("n", "<leader>fv", ":Ex<CR>")

vim.keymap.set("x", "<leader>p", "\"_dP")

-- This will allow yanking to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")


vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")
