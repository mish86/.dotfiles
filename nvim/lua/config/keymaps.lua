-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "x", '"_x')

local nvim_tmux_nav = require("nvim-tmux-navigation")

vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft, { desc = "tmux Navigate Left" })
vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, { desc = "tmux Navigate Down" })
vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, { desc = "tmux Navigate Up" })
vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight, { desc = "tmux Navigate Right" })

vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent line" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Outdent line" })

-- vim.keymap.set("n", "<M-Left>", "b", { desc = "backward-word" })
-- vim.keymap.set("n", "<M-Right>", "w", { desc = "forward-word" })
-- vim.keymap.set("n", "<M-Up>", ":m -2<CR>", { desc = "move line up" })
-- vim.keymap.set("n", "<M-Down>", ":m +1<CR>", { desc = "move line down" })
