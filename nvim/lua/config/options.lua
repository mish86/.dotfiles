-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- http://www.lazyvim.org/extras/lang/python#nvim-lspconfig
-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff_lsp"

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- vim.opt.relativenumber = false -- Relative line numbers
vim.opt.scrolloff = 10 -- Lines of context
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
