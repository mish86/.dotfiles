return {
  -- https://github.com/catppuccin/nvim
  -- https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
  "catppuccin/nvim",
  flavour = "mocha",
  name = "catppuccin",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}
