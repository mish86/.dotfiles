---@diagnostic disable: unused-local
return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    return {
      completion = {
        autocomplete = false,
      },
      -- mapping = cmp.mapping.preset.insert({
      --   ["<C-Space>"] = cmp.mapping.complete(),
      -- }),
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      sources = {},
    }
  end,
}
