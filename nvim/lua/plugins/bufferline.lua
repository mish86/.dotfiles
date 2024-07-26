return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
  opts = function(_, opts)
    opts.options = vim.tbl_extend("force", opts.options, {
      separator_style = "slant",
    })
  end,
}
