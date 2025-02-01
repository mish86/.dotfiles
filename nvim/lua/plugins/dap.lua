return {
  "mfussenegger/nvim-dap",
  -- https://stackoverflow.com/questions/77495184/nvim-failed-to-run-config-for-nvim-dap-loader-lua369-attemp-to-call-field-s
  config = function() end,
  optional = true,
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = { ensure_installed = { "delve" } },
    },
    {
      "leoluz/nvim-dap-go",
      opts = {},
    },
  },
}
