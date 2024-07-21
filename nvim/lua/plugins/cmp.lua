---@diagnostic disable: unused-local
return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")

    opts.completion = {
      autocomplete = false,
    }

    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<C-Space>"] = cmp.mapping.complete(),
    })

    opts.window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    }
  end,
}
