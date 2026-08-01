return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
  },
  {
    -- snacks explorer binds <c-j>/<c-k> in its list window, shadowing the
    -- global TmuxNavigate mappings above; drop them so navigation passes through
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["<c-j>"] = false,
                  ["<c-k>"] = false,
                  -- explorer is the leftmost window but lives in a floating win,
                  -- where TmuxNavigateLeft's edge detection fails (wincmd h lands
                  -- on the editor); go straight to the left tmux pane
                  ["<c-h>"] = function()
                    if vim.env.TMUX then
                      vim.fn.system({ "tmux", "select-pane", "-L" })
                    end
                  end,
                },
              },
            },
          },
        },
      },
    },
  },
}
