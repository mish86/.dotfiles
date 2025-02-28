return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })

      local cmp = require("cmp")

      -- opts.completion = {
      --   autocomplete = false,
      -- }

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<C-Space>"] = cmp.mapping.complete(),
      })

      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
    end,
  },
}
