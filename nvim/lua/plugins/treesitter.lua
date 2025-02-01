return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "diff",
        "gitignore",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "html",
        "http",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        -- "tsx",
        -- "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
  },
  -- {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   lazy = true,
  --   config = function()
  --     require("nvim-treesitter.configs").setup({
  --       textobjects = {
  --         select = {
  --           enable = true,
  --
  --           -- Automatically jump forward to textobj, similar to targets.vim
  --           lookahead = true,
  --
  --           keymaps = {
  --             -- You can use the capture groups defined in textobjects.scm
  --             ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
  --             ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
  --             ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
  --             ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
  --           },
  --         },
  --         move = {
  --           enable = true,
  --           set_jumps = true, -- whether to set jumps in the jumplist
  --           goto_next_start = {
  --             ["]f"] = { query = "@call.outer", desc = "Next function call start" },
  --             ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
  --             ["]c"] = { query = "@class.outer", desc = "Next class start" },
  --             ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
  --             ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
  --
  --             ["]]"] = { query = "@assignment.outer", desc = "Next outer part of an assignment" },
  --           },
  --           goto_next_end = {
  --             ["]F"] = { query = "@call.outer", desc = "Next function call end" },
  --             ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
  --             ["]C"] = { query = "@class.outer", desc = "Next class end" },
  --             ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
  --             ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
  --           },
  --           goto_previous_start = {
  --             ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
  --             ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
  --             ["[c"] = { query = "@class.outer", desc = "Prev class start" },
  --             ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
  --             ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
  --
  --             ["[["] = { query = "@assignment.outer", desc = "Prev outer part of an assignment" },
  --           },
  --           goto_previous_end = {
  --             ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
  --             ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
  --             ["[C"] = { query = "@class.outer", desc = "Prev class end" },
  --             ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
  --             ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
  --           },
  --         },
  --       },
  --     })
  --   end,
  -- },
}
